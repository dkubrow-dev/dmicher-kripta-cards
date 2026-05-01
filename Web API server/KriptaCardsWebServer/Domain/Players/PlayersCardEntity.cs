// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

namespace KriptaCards.WebApi.Domain.Players;

/// <summary>
/// Карточка, выданная игроку
/// </summary>
public class PlayersCardEntity
{
    /// <summary>
    /// Идентификатор записи
    /// </summary>
    public Guid Id { get; set; }

    /// <summary>
    /// Идентификатор уровня карточки
    /// </summary>
    public int Level { get; set; }

    /// <summary>
    /// Номер карточки в уровне
    /// </summary>
    public int Number { get; set; }

    /// <summary>
    /// Игрок, которому принадлежит карточка
    /// </summary>
    public Guid PlayerId { get; set; }

    /// <summary>
    /// Количество выданных карточек
    /// </summary>
    public int Count { get; set; }

    /// <summary>
    /// Игрок, владеющий карточкой
    /// </summary>
    public PlayerEntity? Owner { get; set; }
}
