// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

namespace KriptaCards.WebApi.Domain.Players;

/// <summary>
/// Сессионный ключ входа игрока непосредственно на сервер
/// </summary>
public sealed class PlayerSessionEntity
{
    /// <summary>
    /// Сессионный ключ
    /// </summary>
    public Guid Id { get; set; }

    /// <summary>
    /// Идентификатор игрока
    /// </summary>
    public Guid PlayerId { get; set; }

    /// <summary>
    /// Дата создания сессии UTC
    /// </summary>
    public DateTime CreatedAtUtc { get; set; }

    /// <summary>
    /// Дата истечения сессии UTC
    /// </summary>
    public DateTime ExpiresAtUtc { get; set; }

    /// <summary>
    /// Игрок, которому принадлежит сессия
    /// </summary>
    public PlayerEntity? Owner { get; set; }
}
