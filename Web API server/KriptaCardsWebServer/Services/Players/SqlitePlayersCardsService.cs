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
            Comments = playerEntity.Comments,
            CardsCount = playerEntity.Cards.Count
        })];

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
    /// (асинхронно) Добавляет игрока в базу данных
    /// </summary>
    /// <param name="name">(обязательно) имя</param>
    /// <param name="comment">(опционально) комментарий</param>
    /// <returns>Объект игрока в контексте БД</returns>
    /// <exception cref="ArgumentNullException">Имя обязательно для записи</exception>
    /// <remarks>Не проверяет уникальность имени (можно завести несколько одинаковых имён "мастер" для разрых игр)</remarks>
    public async Task<PlayerEntity> AddPlayerAsync(string name, string? comment = null)
    {
        if (string.IsNullOrWhiteSpace(name))
        {
            throw new ArgumentNullException(nameof(name));
        }

        PlayerEntity newPlayer = new()
        {
            Id = Guid.NewGuid(),
            Name = name,
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
    public async Task UpdatePlayerAsync(Guid guid, string? newName = null, string? newComment = null)
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

        if (!string.IsNullOrWhiteSpace(newComment))
        {
            playerToUpdate.Comments = newComment;
        }

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
