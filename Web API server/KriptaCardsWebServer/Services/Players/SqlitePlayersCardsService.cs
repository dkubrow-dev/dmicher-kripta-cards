// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

using KriptaCards.WebApi.Contracts.Players;
using KriptaCards.WebApi.DataBases.Players;
using KriptaCards.WebApi.Domain.Players;
using KriptaCards.WebApi.Services.CardCatalog;
using KriptaCards.WebApi.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace KriptaCards.WebApi.Services.Players;

/// <summary>
/// Сервис управления игроками
/// </summary>
/// <param name="dbContext">Контекст базы данных</param>
/// <param name="cardCatalog">Каталог карточек в файловой системе</param>
public class SqlitePlayersCardsService(PlayersDbContext dbContext, ICardCatalogService cardCatalog) : IPlayersCardsService
{
    /// <summary>
    /// Контекст базы данных
    /// </summary>
    private readonly PlayersDbContext _dbContext = dbContext;

    /// <summary>
    /// Каталог карточек в файловой системе
    /// </summary>
    private readonly ICardCatalogService _cardCatalog = cardCatalog;

    /// <summary>
    /// Получить полный список игроков
    /// </summary>
    public List<PlayerGridRowDto> GetPlayersList => [.. _dbContext.Players
        .AsNoTracking()
        .Include(x => x.Cards)
        .Select(playerEntity => new PlayerGridRowDto()
        {
            Guid = playerEntity.Id.ToString(),
            Name = playerEntity.Name,
            Login = playerEntity.Login,
            Pin = playerEntity.Pin,
            Comments = playerEntity.Comments,
            CardsCount = playerEntity.Cards.Count
        })];

    /// <summary>
    /// Получить список логинов игроков для входа на сайт
    /// </summary>
    public List<string> GetPlayerLogins => [.. _dbContext.Players
        .AsNoTracking()
        .Select(playerEntity => playerEntity.Login ?? string.Empty)
        .Where(login => login != string.Empty)
        .Distinct()
        .OrderBy(login => login)];

    /// <summary>
    /// Выдаёт подробные данные по одному указанному игроку
    /// </summary>
    /// <param name="guid">Идентификатор игрока</param>
    /// <returns>Сущность "Игрок"</returns>
    public async Task<PlayerEntity?> GetPlayerByIdAsync(Guid guid) =>
        await _dbContext.Players
            .AsNoTracking()
            .Include(x => x.Cards)
            .SingleOrDefaultAsync(x => x.Id == guid);

    /// <summary>
    /// Найти игрока по логину и пин-коду для входа на сайт
    /// </summary>
    public async Task<PlayerEntity?> GetPlayerByLoginAndPinAsync(string login, string pin)
    {
        string normalizedLogin = PlayerCredentials.NormalizeLogin(login);
        string normalizedPin = PlayerCredentials.NormalizePin(pin);

        if (!PlayerCredentials.IsValidLogin(normalizedLogin) || !PlayerCredentials.IsValidPin(normalizedPin))
        {
            return null;
        }

        return await _dbContext.Players
            .AsNoTracking()
            .Include(x => x.Cards)
            .FirstOrDefaultAsync(x => x.Login == normalizedLogin && x.Pin == normalizedPin);
    }

    /// <summary>
    /// (асинхронно) Добавляет игрока в базу данных
    /// </summary>
    /// <param name="name">(обязательно) имя</param>
    /// <param name="comment">(опционально) комментарий</param>
    /// <param name="login">(опционально) логин для сайта</param>
    /// <param name="pin">(опционально) пин-код для сайта</param>
    /// <returns>Объект игрока в контексте БД</returns>
    /// <exception cref="ArgumentNullException">Имя обязательно для записи</exception>
    /// <remarks>Не проверяет уникальность имени (можно завести несколько одинаковых имён "мастер" для разрых игр)</remarks>
    public async Task<PlayerEntity> AddPlayerAsync(string name, string? comment = null, string? login = null, string? pin = null)
    {
        if (string.IsNullOrWhiteSpace(name))
        {
            throw new ArgumentNullException(nameof(name));
        }

        string normalizedLogin = await NormalizeOrGenerateLoginAsync(login);
        string normalizedPin = NormalizeOrGeneratePin(pin);

        PlayerEntity newPlayer = new()
        {
            Id = Guid.NewGuid(),
            Name = name,
            Login = normalizedLogin,
            Pin = normalizedPin,
            Comments = comment
        };

        _dbContext.Players.Add(newPlayer);
        await _dbContext.SaveChangesAsync();

        return newPlayer;
    }

    /// <summary>
    /// (асинхронно) Обновляет данные по игроку в базе данных
    /// </summary>
    /// <param name="guid">Идентификатор игрока</param>
    /// <param name="newName">Новое имя игрока</param>
    /// <param name="newComment">Новый комментарий для игрока</param>
    /// <param name="newLogin">Новый логин игрока для сайта</param>
    /// <param name="newPin">Новый пин-код игрока для сайта</param>
    public async Task UpdatePlayerAsync(Guid guid, string? newName = null, string? newComment = null, string? newLogin = null, string? newPin = null)
    {
        PlayerEntity? playerToUpdate = await _dbContext.Players.SingleOrDefaultAsync(x => x.Id == guid);
        if (playerToUpdate == null)
        {
            return;
        }

        if (!string.IsNullOrWhiteSpace(newName))
        {
            playerToUpdate.Name = newName;
        }

        playerToUpdate.Comments = newComment;

        string normalizedLogin = PlayerCredentials.NormalizeLogin(newLogin);
        if (!string.IsNullOrWhiteSpace(normalizedLogin))
        {
            if (!PlayerCredentials.IsValidLogin(normalizedLogin))
            {
                throw new ArgumentException("Player login is invalid.", nameof(newLogin));
            }

            playerToUpdate.Login = normalizedLogin;
        }
        else if (string.IsNullOrWhiteSpace(playerToUpdate.Login))
        {
            playerToUpdate.Login = await NormalizeOrGenerateLoginAsync(null);
        }

        string normalizedPin = PlayerCredentials.NormalizePin(newPin);
        if (!string.IsNullOrWhiteSpace(normalizedPin))
        {
            if (!PlayerCredentials.IsValidPin(normalizedPin))
            {
                throw new ArgumentException("Player pin must contain five digits and must not be 00000.", nameof(newPin));
            }

            playerToUpdate.Pin = normalizedPin;
        }
        else if (string.IsNullOrWhiteSpace(playerToUpdate.Pin))
        {
            playerToUpdate.Pin = PlayerCredentials.GeneratePin();
        }

        await _dbContext.SaveChangesAsync();
    }

    /// <summary>
    /// Получить пин-код игрока
    /// </summary>
    public async Task<string?> GetPlayerPinAsync(Guid guid)
    {
        PlayerEntity? player = await _dbContext.Players
            .AsNoTracking()
            .SingleOrDefaultAsync(x => x.Id == guid);

        return player?.Pin;
    }

    /// <summary>
    /// Изменить пин-код игрока
    /// </summary>
    public async Task UpdatePlayerPinAsync(Guid guid, string pin)
    {
        string normalizedPin = PlayerCredentials.NormalizePin(pin);
        if (!PlayerCredentials.IsValidPin(normalizedPin))
        {
            throw new ArgumentException("Player pin must contain five digits and must not be 00000.", nameof(pin));
        }

        PlayerEntity? playerToUpdate = await _dbContext.Players.SingleOrDefaultAsync(x => x.Id == guid);
        if (playerToUpdate == null)
        {
            throw new ArgumentException($"No player with id {guid} found.", nameof(guid));
        }

        playerToUpdate.Pin = normalizedPin;
        await _dbContext.SaveChangesAsync();
    }

    /// <summary>
    /// (асинхронно) Удаляет игрока из базы данных
    /// </summary>
    /// <param name="guid"></param>
    /// <returns></returns>
    public async Task DeletePlayerByGuidAsync(Guid guid)
    {
        PlayerEntity? playerToDelete = await _dbContext.Players.SingleOrDefaultAsync(x => x.Id == guid);
        if (playerToDelete == null)
        {
            return;
        }

        _dbContext.Players.Remove(playerToDelete);
        await _dbContext.SaveChangesAsync();
    }

    private async Task<string> NormalizeOrGenerateLoginAsync(string? login)
    {
        string normalizedLogin = PlayerCredentials.NormalizeLogin(login);
        if (!string.IsNullOrWhiteSpace(normalizedLogin))
        {
            if (!PlayerCredentials.IsValidLogin(normalizedLogin))
            {
                throw new ArgumentException("Player login is invalid.", nameof(login));
            }

            return normalizedLogin;
        }

        for (int attempt = 0; attempt < 20; attempt++)
        {
            string generatedLogin = PlayerCredentials.GenerateLogin();
            bool exists = await _dbContext.Players.AnyAsync(x => x.Login == generatedLogin);
            if (!exists)
            {
                return generatedLogin;
            }
        }

        return PlayerCredentials.GenerateLogin();
    }

    private static string NormalizeOrGeneratePin(string? pin)
    {
        string normalizedPin = PlayerCredentials.NormalizePin(pin);
        if (string.IsNullOrWhiteSpace(normalizedPin))
        {
            return PlayerCredentials.GeneratePin();
        }

        if (!PlayerCredentials.IsValidPin(normalizedPin))
        {
            throw new ArgumentException("Player pin must contain five digits and must not be 00000.", nameof(pin));
        }

        return normalizedPin;
    }

    /// <summary>
    /// Сгенерировать случайный бросок на карту
    /// </summary>
    /// <param name="level">Уровень, из которого будет выбрана карта</param>
    public RollCardResult RollRandomCard(int level)
    {
        CardLevel existingCardLevel = _cardCatalog.Levels.FirstOrDefault(x => x.Id == level)
            ?? throw new ArgumentException($"There is no level:{level} in cards catalog.");
        List<Card> cards = [.. _cardCatalog.Cards.Where(x => x.Level == level)];
        Card selectedCard = cards[Random.Shared.Next(0, cards.Count)];
        return new RollCardResult()
        {
            TotalCardsCountInLevel = cards.Count,
            RolledCard = selectedCard
        };
    }

    /// <summary>
    /// Дать указанному игроку конкретную карту
    /// </summary>
    /// <param name="player">Идентификатор игрока, кому дать карту</param>
    /// <param name="level">Уровень карты</param>
    /// <param name="card">Номер карты в уровне</param>
    /// <param name="count">Количество выдаваемых карт этого типа</param>
    public async Task GiveCardToPlayer(Guid player, int level, int card, int count = 1)
    {
        PlayerEntity? playerEntity = await _dbContext.Players.Include(x => x.Cards).SingleOrDefaultAsync(x => x.Id == player)
            ?? throw new ArgumentException($"No player with id {player} found.");
        Card? cardInCatalog = _cardCatalog.GetCardById(level, card)
            ?? throw new ArgumentException($"There is no card id:{card} in level:{level}. Can't give this card.");

        PlayersCardEntity? existingCard = playerEntity.Cards.FirstOrDefault(x => x.Level == level && x.Number == card);
        if (existingCard == null)
        {
            PlayersCardEntity newCard = new()
            {
                Id = Guid.NewGuid(),
                Level = level,
                Number = card,
                PlayerId = playerEntity.Id,
                Count = count,
                Owner = playerEntity
            };

            await _dbContext.Cards.AddAsync(newCard);
        }
        else
        {
            existingCard.Count += count;
        }

        await _dbContext.SaveChangesAsync();
    }

    /// <summary>
    /// Забрать у игрока конкретную карту
    /// </summary>
    /// <param name="player">Идентификатор игрока, у которого забрать карту</param>
    /// <param name="level">Уровень карты</param>
    /// <param name="card">Номер карты в уровне</param>
    /// <param name="count">Количество, которое надо забрать</param>
    /// <exception cref="ArgumentException"></exception>
    public async Task TakeCardFromPlayer(Guid player, int level, int card, int count = 1)
    {
        PlayerEntity? playerEntity = await _dbContext.Players.Include(x => x.Cards).SingleOrDefaultAsync(x => x.Id == player)
            ?? throw new ArgumentException($"No player with id {player} found.");
        PlayersCardEntity? existingCard = playerEntity.Cards.FirstOrDefault(x => x.Level == level && x.Number == card)
            ?? throw new ArgumentException($"Player has no card in level:{level} with id:{card}.");

        existingCard.Count -= count;
        if (existingCard.Count < 1)
        {
            _dbContext.Cards.Remove(existingCard);
        }
        await _dbContext.SaveChangesAsync();
    }
}
