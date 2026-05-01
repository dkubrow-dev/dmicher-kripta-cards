// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

using KriptaCards.WebApi.Domain.Users;
using KriptaCards.WebApi.Services.Interfaces;
using KriptaCards.WebApi.Services.Users;
using Microsoft.Extensions.Options;
using System.Text;

namespace KriptaCards.WebApi.Middleware.Auth;

/// <summary>
/// Промежуточное ПО для аутентификации пользователя по Base64
/// </summary>
/// <param name="next">Выполняемые запрос</param>
public sealed class RequestBaseAuthenticationMeddleware(RequestDelegate next)
{
    /// <summary>
    /// Будущий запрос к контроллеру
    /// </summary>
    private readonly RequestDelegate _next = next;

    /// <summary>
    /// Характерное название Item в контексте исполнения запроса для идентификации пользователя
    /// </summary>
    public const string HttpContextUserItemKey = "kriptaCards-authUser";

    /// <summary>
    /// Выполняет предобработку запроса по авторизации перед передачей контроллера
    /// </summary>
    /// <param name="context">Контест запроса исполнения</param>
    /// <param name="userSercvice">Сервис работы с пользователями</param>
    public async Task Invoke(
        HttpContext context,
        IUserService userSercvice)
    {
        string authString = context.Request.Headers.Authorization.ToString();
        if (string.IsNullOrWhiteSpace(authString) || !authString.StartsWith("Basic ", StringComparison.OrdinalIgnoreCase))
        {
            await _next(context);
            return;
        }

        string encodedValue = authString["Basic ".Length..].Trim();
        if (string.IsNullOrWhiteSpace(encodedValue))
        {
            await _next(context);
            return;
        }

        string decodedValue;
        try
        {
            decodedValue = Encoding.UTF8.GetString(Convert.FromBase64String(encodedValue));
        }
        catch (FormatException)
        {
            await _next(context);
            return;
        }

        int separatorIndex = decodedValue.IndexOf(':');
        if (separatorIndex <= 0)
        {
            await _next(context);
            return;
        }

        string id = decodedValue[..separatorIndex].Trim();
        string key = decodedValue[(separatorIndex + 1)..];

        context.Items[HttpContextUserItemKey] = new User
        {
            Id = id,
            Key = key,
            Role = userSercvice.GetRole(id, key)
        };
        await _next(context);
    }
}
