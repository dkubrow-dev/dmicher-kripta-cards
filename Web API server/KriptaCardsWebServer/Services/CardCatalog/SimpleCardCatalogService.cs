// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

using KriptaCards.WebApi.Services.Interfaces;
using System.Collections.Concurrent;
using System.Reflection.Emit;
using System.Text.Json;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace KriptaCards.WebApi.Services.CardCatalog;

/// <summary>
/// Простейший сервис карточек, основанный на файлах данных в Content/Cards
/// </summary>
public class SimpleCardCatalogService : ICardCatalogService
{
    /// <summary>
    /// Объект временной блокировки потоков при обращении к словарям.
    /// </summary>
    private readonly Lock _sycnLock = new();

    /// <summary>
    /// Путь к корневой папке с изображениями
    /// </summary>
    private static readonly string _cardsRootPath = Path.Combine("Content", "Cards");

    /// <summary>
    /// Опции сериализации JSON файла с реестром
    /// </summary>
    private static readonly JsonSerializerOptions jsonOptions = new()
    {
        PropertyNameCaseInsensitive = true,
        ReadCommentHandling = JsonCommentHandling.Skip
    };

    /// <summary>
    /// Конкурентный индекс уровней карточек
    /// </summary>
    private ConcurrentDictionary<int, CardLevel> _levels = new();

    /// <summary>
    /// Конкурентный индекс карточек по (Level, Number)
    /// </summary>
    private ConcurrentDictionary<(int Level, int Number), Card> _cards = new();

    /// <summary>
    /// Конструктор приватный. Объект создаётся через фабричный метод <see cref="CreateServiceAsync(CancellationToken)"/>
    /// </summary>
    private SimpleCardCatalogService() { }

    /// <summary>
    /// (асинхронный, фабричный) Возвращает сервис, подготовленный к работе
    /// </summary>
    /// <param name="cancellationToken">токен отмены операции</param>
    public static async Task<SimpleCardCatalogService> CreateServiceAsync(CancellationToken cancellationToken)
    {
        SimpleCardCatalogService newService = new();
        await newService.ReadDataAsync(cancellationToken);
        return newService;
    }

    /// <summary>
    /// Читает или перечитывает содержимое файла регистра.
    /// </summary>
    /// <param name="cancellationToken">Токен отмены операции</param>
    /// <exception cref="FileNotFoundException"></exception>
    /// <exception cref="FileLoadException"></exception>
    /// <exception cref="FormatException"></exception>
    internal async Task ReadDataAsync(CancellationToken cancellationToken)
    {
        string path = Path.Combine(AppContext.BaseDirectory, "Content", "CardsReg.json");
        if (!File.Exists(path))
        {
            throw new FileNotFoundException("Can't find registry file on: " + path);
        }

        await using FileStream fileStream = File.OpenRead(path);

        CardsRegistry registry = await JsonSerializer.DeserializeAsync<CardsRegistry>(
            fileStream, jsonOptions, cancellationToken)
            ?? throw new FileLoadException("Incorrect file content in registry on: " + path);

        if (registry.Levels == null || registry.Levels.Count == 0
            || registry.Cards == null || registry.Cards.Count == 0)
        {
            throw new FileLoadException("Not enought data in registry on: " + path);
        }

        if (registry.Cards
            .Select(card => card.Level)
            .Any(cardLevelIds => !registry.Levels
                .Select(level => level.Id)
                .Contains(cardLevelIds)))
        {
            throw new FormatException("Regustry is not valid: there is some cards, withs levels not exist.");
        }

        foreach (Card card in registry.Cards)
        {
            int level = card.Level;
            int number = card.Number;
            bool getCommonImage = !string.IsNullOrWhiteSpace(card.ImagePath);

            string imageLevelName = getCommonImage ? "Common" : level.ToString();
            string imageDirectory = Path.Combine(_cardsRootPath, imageLevelName);
            string imageAbsDirecroty = Path.Combine(AppContext.BaseDirectory, imageDirectory);

            if (!Directory.Exists(imageAbsDirecroty))
            {
                throw new FileNotFoundException($"{imageAbsDirecroty} does not exist");
            }

            string[] imageFilePaths = [.. Directory.EnumerateFiles(imageAbsDirecroty, $"{(getCommonImage ? card.ImagePath : number.ToString())}.*")];
            if (imageFilePaths == null || imageFilePaths.Length < 1)
            {
                throw new FileNotFoundException($"{imageFilePaths} does not exist");
            }
            if (imageFilePaths.Length > 1)
            {
                throw getCommonImage
                    ? new FormatException($"There is more than 1 image file for image name in:{card.ImagePath}")
                    : new FormatException($"There is more than 1 image file for card l:{level} n:{number}.");
            }
            card.ImagePath = Path.Combine(imageLevelName, Path.GetFileName(imageFilePaths[0])).Replace('\\', '/');
        }

        ConcurrentDictionary<int, CardLevel> newLevels = new(
            registry.Levels.Select(level => new KeyValuePair<int, CardLevel>(level.Id, level)));

        ConcurrentDictionary<(int Level, int Number), Card> newCards = new(
            registry.Cards.Select(card => new KeyValuePair<(int Level, int Number), Card>((card.Level, card.Number), card)));

        lock (_sycnLock)
        {
            _levels = newLevels;
            _cards = newCards;
        }
    }

    /// <summary>
    /// Выдать перечисление всех уровней карточек (метаданные)
    /// </summary>
    public List<CardLevel> Levels
    {
        get
        {
            lock (_sycnLock)
            {
                return [.. _levels.Values.OrderBy(x => x.Id)];
            }
        }
    }

    /// <summary>
    /// Выдать перечисление всех карточек
    /// </summary>
    public List<Card> Cards
    {
        get
        {
            lock (_sycnLock)
            {
                return [.. _cards.Values.OrderBy(x => x.Level).ThenBy(x => x.Number)];
            }
        }
    }

    /// <summary>
    /// Выдать метаданные одной карты по идентификатору уровня и карты
    /// </summary>
    /// <param name="levelId">Номер уровня</param>
    /// <param name="cardId">Номер карты в уровне</param>
    public Card? GetCardById(int levelId, int cardId)
    {
        lock (_sycnLock)
        {
            return _cards.TryGetValue((levelId, cardId), out Card? card) ? card : null;
        }
    }

    /// <summary>
    /// Получить информацию о файле по пути до него
    /// </summary>
    /// <param name="path">Путь до файла изображения (записан в карточке)</param>
    public FileInfo GetFile(string path)
    {
        if (string.IsNullOrWhiteSpace(path))
        {
            throw new FileNotFoundException("Image path is empty.");
        }

        string normalizedPath = path
            .Replace('\\', Path.DirectorySeparatorChar)
            .Replace('/', Path.DirectorySeparatorChar);
        
        string cardsRootFullPath = Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, _cardsRootPath));

        if (!cardsRootFullPath.EndsWith(Path.DirectorySeparatorChar))
        {
            cardsRootFullPath += Path.DirectorySeparatorChar;
        }

        string fullPath = Path.GetFullPath(Path.Combine(cardsRootFullPath, normalizedPath));

        if (!fullPath.StartsWith(cardsRootFullPath, StringComparison.OrdinalIgnoreCase))
        {
            throw new FileNotFoundException("Image path is outside cards directory.");
        }

        if (!File.Exists(fullPath))
        {
            throw new FileNotFoundException(fullPath);
        }

        return new FileInfo(fullPath);
    }
}