// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

using System.Data;
using System.Data.Common;
using KriptaCards.WebApi.Services.Players;
using Microsoft.EntityFrameworkCore;

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
        await EnsureSchema120Async(cancellationToken);

        _logger.LogInformation("Players database EnshureCreated.");
    }

    private async Task EnsureSchema120Async(CancellationToken cancellationToken)
    {
        DbConnection connection = _dbContext.Database.GetDbConnection();
        bool closeConnection = connection.State == ConnectionState.Closed;
        if (closeConnection)
        {
            await connection.OpenAsync(cancellationToken);
        }

        try
        {
            HashSet<string> playerColumns = await GetColumnsAsync(connection, "players", cancellationToken);

            if (!playerColumns.Contains("Login"))
            {
                await ExecuteNonQueryAsync(connection, "ALTER TABLE players ADD COLUMN Login TEXT;", cancellationToken);
                _logger.LogWarning("Players database migrated: added players.Login column.");
            }

            if (!playerColumns.Contains("Pin"))
            {
                await ExecuteNonQueryAsync(connection, "ALTER TABLE players ADD COLUMN Pin TEXT;", cancellationToken);
                _logger.LogWarning("Players database migrated: added players.Pin column.");
            }

            await ExecuteNonQueryAsync(
                connection,
                """
                CREATE TABLE IF NOT EXISTS player_sessions (
                    Id TEXT NOT NULL CONSTRAINT PK_player_sessions PRIMARY KEY,
                    PlayerId TEXT NOT NULL,
                    CreatedAtUtc TEXT NOT NULL,
                    ExpiresAtUtc TEXT NOT NULL,
                    CONSTRAINT FK_player_sessions_players_PlayerId FOREIGN KEY (PlayerId) REFERENCES players (Id) ON DELETE CASCADE
                );
                """,
                cancellationToken);

            await ExecuteNonQueryAsync(connection, "CREATE INDEX IF NOT EXISTS IX_players_Login ON players (Login);", cancellationToken);
            await ExecuteNonQueryAsync(connection, "CREATE INDEX IF NOT EXISTS IX_player_sessions_PlayerId ON player_sessions (PlayerId);", cancellationToken);
            await ExecuteNonQueryAsync(connection, "CREATE INDEX IF NOT EXISTS IX_player_sessions_ExpiresAtUtc ON player_sessions (ExpiresAtUtc);", cancellationToken);

            await FillMissingCredentialsAsync(connection, cancellationToken);
        }
        finally
        {
            if (closeConnection)
            {
                await connection.CloseAsync();
            }
        }
    }

    private static async Task<HashSet<string>> GetColumnsAsync(DbConnection connection, string tableName, CancellationToken cancellationToken)
    {
        HashSet<string> result = new(StringComparer.OrdinalIgnoreCase);

        await using DbCommand command = connection.CreateCommand();
        command.CommandText = $"PRAGMA table_info({tableName});";

        await using DbDataReader reader = await command.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            result.Add(reader.GetString(1));
        }

        return result;
    }

    private async Task FillMissingCredentialsAsync(DbConnection connection, CancellationToken cancellationToken)
    {
        List<(string Id, string? Name, string? Login, string? Pin)> rows = [];

        await using (DbCommand command = connection.CreateCommand())
        {
            command.CommandText = "SELECT Id, Name, Login, Pin FROM players;";
            await using DbDataReader reader = await command.ExecuteReaderAsync(cancellationToken);
            while (await reader.ReadAsync(cancellationToken))
            {
                rows.Add((
                    Convert.ToString(reader["Id"]) ?? string.Empty,
                    Convert.ToString(reader["Name"]),
                    Convert.ToString(reader["Login"]),
                    Convert.ToString(reader["Pin"])));
            }
        }

        foreach ((string id, string? name, string? login, string? pin) in rows)
        {
            string nextLogin = PlayerCredentials.IsValidLogin(login)
                ? PlayerCredentials.NormalizeLogin(login)
                : PlayerCredentials.NormalizeLogin(name);

            if (!PlayerCredentials.IsValidLogin(nextLogin))
            {
                nextLogin = PlayerCredentials.GenerateLogin();
            }

            string nextPin = PlayerCredentials.IsValidPin(pin)
                ? PlayerCredentials.NormalizePin(pin)
                : PlayerCredentials.GeneratePin();

            if (nextLogin == PlayerCredentials.NormalizeLogin(login) && nextPin == PlayerCredentials.NormalizePin(pin))
            {
                continue;
            }

            await using DbCommand updateCommand = connection.CreateCommand();
            updateCommand.CommandText = "UPDATE players SET Login = $login, Pin = $pin WHERE Id = $id;";
            AddParameter(updateCommand, "$login", nextLogin);
            AddParameter(updateCommand, "$pin", nextPin);
            AddParameter(updateCommand, "$id", id);
            await updateCommand.ExecuteNonQueryAsync(cancellationToken);

            _logger.LogWarning("Players database migrated: credentials filled for player {PlayerId}.", id);
        }
    }

    private static async Task ExecuteNonQueryAsync(DbConnection connection, string commandText, CancellationToken cancellationToken)
    {
        await using DbCommand command = connection.CreateCommand();
        command.CommandText = commandText;
        await command.ExecuteNonQueryAsync(cancellationToken);
    }

    private static void AddParameter(DbCommand command, string name, object? value)
    {
        DbParameter parameter = command.CreateParameter();
        parameter.ParameterName = name;
        parameter.Value = value ?? DBNull.Value;
        command.Parameters.Add(parameter);
    }
}
