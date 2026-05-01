// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

using KriptaCards.WebApi.Domain.Users;
using KriptaCards.WebApi.Middleware.Auth;
using Microsoft.AspNetCore.Mvc;
using System.Reflection;


namespace KriptaCards.WebApi.Controllers;

/// <summary>
/// Контроллер состояния сервера
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class HealthController(ILogger<HealthController> logger) : Controller
{
    /// <summary>
    /// Логгер контроллера
    /// </summary>
    private readonly ILogger<HealthController> _logger = logger;

    /// <summary>
    /// (без аутентификации) Первичная проверка: сервис поднят, работает и отвечает. Доступна всем.
    /// </summary>
    /// <returns></returns>
    [HttpGet("check")]
    [ProducesResponseType<string>(StatusCodes.Status200OK)]
    public ActionResult<string> Check()
    {
        Assembly assembly = Assembly.GetExecutingAssembly();

        string assemblyName = assembly.GetName().Name ?? "UnknownAssembly";

        string version =
            assembly.GetCustomAttribute<AssemblyInformationalVersionAttribute>()?.InformationalVersion
            ?? assembly.GetName().Version?.ToString()
            ?? "0.0.0";

        string answer =
            $"""
            Status: running
            Assembly: {assemblyName}
            Version: {version}
            Author: dmicher abathur kubrow
            """;

        return Ok(answer);
    }

    /// <summary>
    /// (Reader) Вторичная проверка: сервис проводит аутентификацию и авторизацию.
    /// </summary>
    /// <returns></returns>
    [HttpGet("check-me")]
    [Base64Authorize(UserRoles.Reader, UserRoles.Writer)]
    [ProducesResponseType<string>(StatusCodes.Status200OK)]
    [ProducesResponseType<BadRequestObjectResult>(StatusCodes.Status400BadRequest)]
    [ProducesResponseType<UnauthorizedObjectResult>(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType<ObjectResult>(StatusCodes.Status403Forbidden)]
    public ActionResult<string> CheckMe()
    {
        User? user = HttpContext.Items.TryGetValue(RequestBaseAuthenticationMeddleware.HttpContextUserItemKey, out object? value)
                ? value as User
                : null;

        _logger.LogInformation("Health \"check-me\" - ok.");
        if (user == null)
        {
            return BadRequest("Authorised User not found.");
        }

        return Ok($"User: {user.Id}{Environment.NewLine}Role: {user.Role}");
    }
}
