// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

namespace KriptaCards.WebApi.Contracts.Players;

/// <summary>
/// Передаваемый объет "Карточка пользователя"
/// </summary>
public class PlayersCardDto
{
    /// <summary>
    /// Глобально уникальный иднетификатор записи о карточке
    /// </summary>
    public string? Guid { get; set; }

    /// <summary>
    /// Уровень карточки
    /// </summary>
    public int? Level { get; set; }

    /// <summary>
    /// Номер карточки в уровне
    /// </summary>
    public int? Number {  get; set; }

    /// <summary>
    /// Идентификатор игрока-владельца карточки
    /// </summary>
    public string? OwnerGuid { get; set; }

    /// <summary>
    /// Количество карточек этого типа в рамках этого владельца
    /// </summary>
    public int? Count { get; set; }
}
