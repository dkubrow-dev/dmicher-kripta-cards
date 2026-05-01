// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

using KriptaCards.WebApi.Domain.Users;

namespace KriptaCards.WebApi.Services.Users;

/// <summary>
/// Секция настроек appsettings с данными о зарегистрированных пользователях
/// </summary>
public class UserSettingsSection
{
    /// <summary>
    /// Название секции в настройках
    /// </summary>
    public const string SectionName = "UserAuth";

    /// <summary>
    /// Список пользователей из настроек
    /// </summary>
    public List<User> Users { get; set; } = [];
}
