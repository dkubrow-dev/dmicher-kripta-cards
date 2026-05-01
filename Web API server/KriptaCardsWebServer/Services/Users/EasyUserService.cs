// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

using KriptaCards.WebApi.Domain.Users;
using KriptaCards.WebApi.Services.Interfaces;
namespace KriptaCards.WebApi.Services.Users;

/// <summary>
/// Простейший сервис работы с пользователями.
/// </summary>
/// <param name="users"></param>
public class EasyUserService(List<User> users) : IUserService
{
    /// <summary>
    /// Список пользователей
    /// </summary>
    private List<User> _users = users;

    /// <summary>
    /// Возвращает роль пользователя по его идентификационным данным
    /// </summary>
    /// <param name="guid">Идентификатор пользователя</param>
    /// <param name="key">Ключ пользователя</param>
    /// <returns>Роль пользователя, либо None, если не аутентифицирован</returns>
    public UserRoles GetRole(string guid, string key)
    {
        return _users.FirstOrDefault(x => x.Id == guid && x.Key == key)?.Role ?? UserRoles.None;
    }
}
