// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

namespace KriptaCards.WebApi.Services.CardCatalog;

/// <summary>
/// Результат случайного выбора карты
/// </summary>
public class RollCardResult
{
    /// <summary>
    /// Выбранная карта
    /// </summary>
    public Card? RolledCard { get; set; }

    /// <summary>
    /// Общее количество карт на запрошенном уровне
    /// </summary>
    public int TotalCardsCountInLevel { get; set; }
}
