// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

using KriptaCards.WebApi.Domain.Users;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace KriptaCards.WebApi.Middleware.Auth;

/// <summary>
/// Атрибут проверки доступа к контроллеру или методу по роли аутентифицированного пользователя
/// </summary>
[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = false, Inherited = true)]
public sealed class Base64AuthorizeAttribute(params UserRoles[] roles) : Attribute, IAsyncAuthorizationFilter
{
    /// <summary>
    /// Роли, допустимые для контроллера/метода
    /// </summary>
    private readonly HashSet<UserRoles> _roles = roles.Length == 0 ? [] : [.. roles];

    /// <summary>
    /// (в момент авторизации в методе/контроллере) Проверяет, что роль аутентифицированного пользователя находится
    /// в списке доступа к методу.
    /// </summary>
    /// <param name="context">Контекст исполнения запроса</param>
    public Task OnAuthorizationAsync(AuthorizationFilterContext context)
    {
        User? authenticatedUser = context.HttpContext.Items
            .TryGetValue(RequestBaseAuthenticationMeddleware.HttpContextUserItemKey, out object? value)
                ? value as User
                : null;

        if (authenticatedUser is null)
        {
            context.Result = new UnauthorizedObjectResult(new { message = "The authentication key is missing or has an invalid format." });
            return Task.CompletedTask;
        }

        if (_roles.Count > 0 && !_roles.Contains(authenticatedUser.Role))
        {
            context.Result = new ObjectResult(new { message = "Current user role is not allowed for this action." })
            {
                StatusCode = StatusCodes.Status403Forbidden
            };
            return Task.CompletedTask;
        }

        return Task.CompletedTask;
    }
}
