// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

namespace KriptaCards.WebApi.Contracts.Players;

/// <summary>
/// Объект для информации о пользователе в таблице пользователей
/// </summary>
public class PlayerGridRowDto
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
    /// Количество уникальных карточек, выданных игроку
    /// </summary>
    /// <remarks>Карточки могут повторяться</remarks>
    public int CardsCount { get; set; }

    /// <summary>
    /// Комментарии пользователя
    /// </summary>
    public string? Comments { get; set; }
}
