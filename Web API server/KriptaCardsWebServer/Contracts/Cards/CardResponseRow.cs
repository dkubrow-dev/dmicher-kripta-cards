// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

namespace KriptaCards.WebApi.Contracts.Cards;

/// <summary>
/// Строка карточки в таблице вывода
/// </summary>
public sealed record CardResponseRow
{
    /// <summary>
    /// Уровень карточки
    /// </summary>
    public int Level { get; init; }

    /// <summary>
    /// Номер карточки в уровне
    /// </summary>
    public int Number {  get; init; }

    /// <summary>
    /// Название карточки
    /// </summary>
    public string? Name { get; init; }
}
