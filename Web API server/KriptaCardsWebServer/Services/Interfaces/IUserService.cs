// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

using KriptaCards.WebApi.Domain.Users;

namespace KriptaCards.WebApi.Services.Interfaces;

/// <summary>
/// Интерфейс сервиса работы с пользователями
/// </summary>
public interface IUserService
{
    /// <summary>
    /// Получить роль пользователя в системе по его входным данным
    /// </summary>
    /// <param name="guid">Идентификатор пользователя в системе</param>
    /// <param name="key">Ключ пользователя</param>
    /// <returns>Роль в системе: не пользователь, игрок или мастер</returns>
    public UserRoles GetRole(string guid, string key);
}
