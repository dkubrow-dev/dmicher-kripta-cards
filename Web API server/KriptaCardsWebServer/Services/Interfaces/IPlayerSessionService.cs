// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

using KriptaCards.WebApi.Domain.Players;

namespace KriptaCards.WebApi.Services.Interfaces;

/// <summary>
/// Сервис управления сессионными ключами входа игроков на сайт
/// </summary>
public interface IPlayerSessionService
{
    /// <summary>
    /// Создать новую сессию игрока
    /// </summary>
    public Task<PlayerSessionEntity> CreateSessionAsync(Guid playerId, DateTime utcNow, CancellationToken cancellationToken = default);

    /// <summary>
    /// Получить действующую сессию
    /// </summary>
    public Task<PlayerSessionEntity?> GetValidSessionAsync(Guid sessionId, DateTime utcNow, CancellationToken cancellationToken = default);

    /// <summary>
    /// Удалить сессию
    /// </summary>
    public Task DeleteSessionAsync(Guid sessionId, CancellationToken cancellationToken = default);
}
