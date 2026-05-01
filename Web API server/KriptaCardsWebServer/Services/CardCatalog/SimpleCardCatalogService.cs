// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

using System.Collections.Concurrent;
using System.Text.Json;
using KriptaCards.WebApi.Services.Interfaces;

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
    private static readonly string _cardsRootPath = Path.Combine(AppContext.BaseDirectory, "Content", "Cards");

    /// <summary>
    /// Опции сериализации JSON файла с реестром
    /// </summary>
    private static readonly JsonSerializerOptions jsonOptions = new()
    {
        PropertyNameCaseInsensitive = false,
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

        string cardsImageDirPath = Path.Combine(AppContext.BaseDirectory, "Content", "Cards");
        foreach (Card card in registry.Cards)
        {
            int level = card.Level;
            int number = card.Number;
            string imageDirectory = Path.Combine(cardsImageDirPath, level.ToString());
            if (!Directory.Exists(imageDirectory))
            {
                throw new FileNotFoundException($"{imageDirectory} does not exist");
            }

            string[] imageFilePaths = [.. Directory.EnumerateFiles(imageDirectory, $"{number}.*")];
            if (imageFilePaths == null || imageFilePaths.Length < 1)
            {
                throw new FileNotFoundException($"{imageFilePaths} does not exist");
            }
            if (imageFilePaths.Length > 1)
            {
                throw new FormatException($"There is more than 1 image file for card l:{level} n:{number}.");
            }
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
    /// Выдать ссылку на скачивание изображения для переданной карты
    /// </summary>
    /// <param name="card">Карта, для которой нужен путь к изображению</param>
    public string ImagePathById(Card card)
    {
        string dirPath = Path.Combine(
            _cardsRootPath,
            card.Level.ToString());

        if (!Directory.Exists(dirPath))
        {
            throw new FileNotFoundException();
        }

        string? filePath = Directory.EnumerateFiles(dirPath, $"{card.Number}.*").FirstOrDefault();
        if (!File.Exists(filePath))
        {
            throw new FileNotFoundException();
        }

        return filePath;
    }
}