// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

namespace KriptaCards.WebApi.Domain.Users;

/// <summary>
/// Роли пользователей Web API
/// </summary>
public enum UserRoles : byte
{
    /// <summary>
    /// Неаутентифицированный пользователь: запрещено почти всё
    /// </summary>
    None = 0,

    /// <summary>
    /// Читатель: может читать записи, не может вносить изменения
    /// </summary>
    /// <remarks>Предназначен для игроков и мастера игры</remarks>
    Reader = 1,

    /// <summary>
    /// Писатель: может читать и менять записи
    /// </summary>
    /// <remarks>Предназначен для мастера игры</remarks>
    Writer = 2
}
