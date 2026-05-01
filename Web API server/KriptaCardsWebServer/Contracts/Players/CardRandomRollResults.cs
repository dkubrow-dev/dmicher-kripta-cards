// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

namespace KriptaCards.WebApi.Contracts.Players;

/// <summary>
/// Результат случайного выбора карты при броске
/// </summary>
public sealed record CardRandomRollResults
{

    /// <summary>
    /// Уровень карты, указанный в запросе
    /// </summary>
    public int RequestedCardLevel { get; set; }

    /// <summary>
    /// Общее количество карт на запрошенном уровне
    /// </summary>
    public int TotalCardsCountInLevel { get; set; }

    /// <summary>
    /// Выбранная карта
    /// </summary>
    public PlayersCardDto? RolledCard { get; set; }
}
