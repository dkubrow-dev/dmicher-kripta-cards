// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

namespace KriptaCards.WebApi.DataBases.Players;

/// <summary>
/// Инициализатор базы данных "Игроки"
/// </summary>
/// <param name="dbContext">Контекст базы данных</param>
/// <param name="logger">Логгер</param>
public class PlayersDbInitializer(PlayersDbContext dbContext, ILogger<PlayersDbInitializer> logger)
{
    /// <summary>
    /// Логгер
    /// </summary>
    private readonly ILogger<PlayersDbInitializer> _logger = logger;

    /// <summary>
    /// Контекст базы данных
    /// </summary>
    private readonly PlayersDbContext _dbContext = dbContext;

    /// <summary>
    /// (асинхронно) инициализирует базу данных игроков
    /// </summary>
    /// <param name="cancellationToken">Токен отмены</param>
    public async Task InitializeAsync(CancellationToken cancellationToken = default)
    {
        await _dbContext.Database.EnsureCreatedAsync(cancellationToken);
        _logger.LogInformation("Players database EnshureCreated.");
    }
}
