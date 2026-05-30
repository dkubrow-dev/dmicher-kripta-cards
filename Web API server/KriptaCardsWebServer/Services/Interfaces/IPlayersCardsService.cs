// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

using KriptaCards.WebApi.Contracts.Players;
using KriptaCards.WebApi.Domain.Players;
using KriptaCards.WebApi.Services.CardCatalog;

namespace KriptaCards.WebApi.Services.Interfaces;

/// <summary>
/// Сервис управления игроками
/// </summary>
public interface IPlayersCardsService
{
    /// <summary>
    /// Получить список всех игроков
    /// </summary>
    public List<PlayerGridRowDto> GetPlayersList { get; }

    /// <summary>
    /// Получить список логинов игроков для входа на сайт
    /// </summary>
    public List<string> GetPlayerLogins { get; }

    /// <summary>
    /// (асинхронно) Получить подробные данные по конкретному игроку
    /// </summary>
    /// <param name="guid">Идентификатор пользователя</param>
    /// <returns>Подробные данные об игроке</returns>
    public Task<PlayerEntity?> GetPlayerByIdAsync(Guid guid);

    /// <summary>
    /// (асинхронно) Найти игрока по логину и пин-коду для входа на сайт
    /// </summary>
    public Task<PlayerEntity?> GetPlayerByLoginAndPinAsync(string login, string pin);

    /// <summary>
    /// Добавить игрока к списку
    /// </summary>
    /// <param name="name">Имя игрока</param>
    /// <param name="comment">Комментарий к игроку</param>
    /// <param name="login">Логин игрока для сайта</param>
    /// <param name="pin">Пин-код игрока для сайта</param>
    /// <returns>Объект игрока</returns>
    public Task<PlayerEntity> AddPlayerAsync(string name, string? comment = null, string? login = null, string? pin = null);

    /// <summary>
    /// Изменить имя игрока
    /// </summary>
    /// <param name="guid">Идентификатор игрока</param>
    /// <param name="newName">Новое имя игрока</param>
    /// <param name="newComment">Новый комментарий к игроку</param>
    /// <param name="newLogin">Новый логин игрока для сайта</param>
    /// <param name="newPin">Новый пин-код игрока для сайта</param>
    public Task UpdatePlayerAsync(Guid guid, string? newName = null, string? newComment = null, string? newLogin = null, string? newPin = null);

    /// <summary>
    /// Получить пин-код игрока
    /// </summary>
    public Task<string?> GetPlayerPinAsync(Guid guid);

    /// <summary>
    /// Изменить пин-код игрока
    /// </summary>
    public Task UpdatePlayerPinAsync(Guid guid, string pin);

    /// <summary>
    /// Удалить игрока по его идентификатору
    /// </summary>
    /// <param name="guid">Глобальный идентификатор пользвателя</param>
    public Task DeletePlayerByGuidAsync(Guid guid);

    /// <summary>
    /// Дать указанному игроку конкретную карту
    /// </summary>
    /// <param name="player">Идентификатор игрока, кому дать карту</param>
    /// <param name="level">Уровень карты</param>
    /// <param name="card">Номер карты в уровне</param>
    /// <param name="count">Количество выдаваемых карт этого типа</param>
    public Task GiveCardToPlayer(Guid player, int level, int card, int count = 1);

    /// <summary>
    /// Забрать у игрока конкретную карту
    /// </summary>
    /// <param name="player">Идентификатор игрока, у которого забрать карту</param>
    /// <param name="level">Уровень карты</param>
    /// <param name="card">Номер карты в уровне</param>
    /// <param name="count">Количество, которое надо забрать</param>
    public Task TakeCardFromPlayer(Guid player, int level, int card, int count = 1);

    /// <summary>
    /// Сгенерировать случайный бросок на карту
    /// </summary>
    /// <param name="level">Уровень, из которого будет выбрана карта</param>
    public RollCardResult RollRandomCard(int level);
}
