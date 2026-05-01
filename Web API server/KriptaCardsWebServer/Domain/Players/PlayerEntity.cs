// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

namespace KriptaCards.WebApi.Domain.Players;

/// <summary>
/// Сущность - "Игрок"
/// </summary>
public sealed record PlayerEntity
{
    /// <summary>
    /// Глобальный идентификатор игрока
    /// </summary>
    public Guid Id { get; set; }

    /// <summary>
    /// Имя игрока для идентификацией человеком
    /// </summary>
    public string? Name { get; set; }

    /// <summary>
    /// Комментарий
    /// </summary>
    public string? Comments { get; set; }

    /// <summary>
    /// Карточки, выданные игроку
    /// </summary>
    public ICollection<PlayersCardEntity> Cards { get; set; } = [];
}
