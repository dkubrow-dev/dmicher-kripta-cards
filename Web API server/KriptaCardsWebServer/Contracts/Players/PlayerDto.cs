// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

namespace KriptaCards.WebApi.Contracts.Players;

/// <summary>
/// Передаваемый объект "Игрок"
/// </summary>
public sealed record PlayerDto
{
    /// <summary>
    /// Глобально уникальный идентификатор пользователя
    /// </summary>
    public string? Guid { get; set; }

    /// <summary>
    /// Имя пользователя
    /// </summary>
    public string? Name { get; set; }

    /// <summary>
    /// Комментарии пользователя
    /// </summary>
    public string? Comments { get; set; }

    /// <summary>
    /// Перечень карточек пользователя
    /// </summary>
    public List<PlayersCardDto>? CardDtos { get; set; }
}
