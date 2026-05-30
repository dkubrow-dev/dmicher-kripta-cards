// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

using KriptaCards.WebApi.DataBases.Players;
using KriptaCards.WebApi.Domain.Players;
using KriptaCards.WebApi.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace KriptaCards.WebApi.Services.Players;

/// <summary>
/// SQLite-сервис управления сессионными ключами игроков
/// </summary>
/// <param name="dbContext">Контекст базы данных игроков</param>
public sealed class SqlitePlayerSessionService(PlayersDbContext dbContext) : IPlayerSessionService
{
    /// <summary>
    /// Срок действия сессии игрока
    /// </summary>
    public static readonly TimeSpan SessionLifetime = TimeSpan.FromDays(31);

    private readonly PlayersDbContext _dbContext = dbContext;

    /// <summary>
    /// Создать новую сессию игрока
    /// </summary>
    public async Task<PlayerSessionEntity> CreateSessionAsync(Guid playerId, DateTime utcNow, CancellationToken cancellationToken = default)
    {
        await _dbContext.PlayerSessions
            .Where(x => x.PlayerId == playerId && x.ExpiresAtUtc <= utcNow)
            .ExecuteDeleteAsync(cancellationToken);

        PlayerSessionEntity session = new()
        {
            Id = Guid.NewGuid(),
            PlayerId = playerId,
            CreatedAtUtc = utcNow,
            ExpiresAtUtc = utcNow.Add(SessionLifetime)
        };

        await _dbContext.PlayerSessions.AddAsync(session, cancellationToken);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return session;
    }

    /// <summary>
    /// Получить действующую сессию
    /// </summary>
    public async Task<PlayerSessionEntity?> GetValidSessionAsync(Guid sessionId, DateTime utcNow, CancellationToken cancellationToken = default)
    {
        PlayerSessionEntity? session = await _dbContext.PlayerSessions
            .AsNoTracking()
            .Include(x => x.Owner)
            .ThenInclude(x => x!.Cards)
            .SingleOrDefaultAsync(x => x.Id == sessionId, cancellationToken);

        if (session == null || session.ExpiresAtUtc <= utcNow)
        {
            return null;
        }

        return session;
    }

    /// <summary>
    /// Удалить сессию
    /// </summary>
    public async Task DeleteSessionAsync(Guid sessionId, CancellationToken cancellationToken = default)
    {
        await _dbContext.PlayerSessions
            .Where(x => x.Id == sessionId)
            .ExecuteDeleteAsync(cancellationToken);
    }
}
