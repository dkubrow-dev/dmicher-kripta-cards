// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

namespace KriptaCards.WebApi.Domain.Users;

/// <summary>
/// Профили пользователей Web API
/// </summary>
public sealed record User
{
    /// <summary>
    /// Глобальный идентификатор пользователя
    /// </summary>
    public string Id { get; init; } = string.Empty;

    /// <summary>
    /// Ключ доступа пользователя
    /// </summary>
    public string Key { get; init; } = string.Empty;

    /// <summary>
    /// Роль пользовател
    /// </summary>
    public UserRoles Role {  get; init; } = UserRoles.None;
}
