// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

namespace KriptaCards.WebApi.Contracts.Players;

/// <summary>
/// Пин-код игрока сервера
/// </summary>
public sealed record PlayerPinDto
{
    /// <summary>
    /// Идентификатор игрока
    /// </summary>
    public string? Guid { get; init; }

    /// <summary>
    /// Пятизначный пин-код
    /// </summary>
    public string? Pin { get; init; }
}
