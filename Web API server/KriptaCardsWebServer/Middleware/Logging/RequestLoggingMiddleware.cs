// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

using System.Diagnostics;

namespace KriptaCards.WebApi.Middleware.Logging;

/// <summary>
/// Промежуточный слой для логгирования HTTP запросов-ответов через выбранный провайдер логов
/// </summary>
/// <remarks>Отрабатывает только HTTP слой: "запрос поступил", "запрос отдали", коды статуса запроса и время выполнения</remarks>
/// <remarks>
/// Возвращает промежуточный слой логгирования
/// </remarks>
/// <param name="next">Фунция-делегат, фактически обрабатывающая HTTP запрос</param>
/// <param name="logger">Логгер</param>
public sealed class RequestLoggingMiddleware(RequestDelegate next,
    ILogger<RequestLoggingMiddleware> logger)
{
    /// <summary>
    /// Делегат фактической обработки HTTP: пляшем вокруг него
    /// </summary>
    private readonly RequestDelegate _next = next;

    /// <summary>
    /// Логгер для промежуточного слоя
    /// </summary>
    private readonly ILogger<RequestLoggingMiddleware> _logger = logger;

    /// <summary>
    /// Задача на фактическую запись лога поступившего запроса
    /// </summary>
    /// <param name="context">Контекст поступившего HTTP запроса</param>
    public async Task Invoke(HttpContext context)
    {
        string requestId = context.TraceIdentifier;
        string method = context.Request.Method;
        string path = context.Request.Path.HasValue ? context.Request.Path.Value! : "/";

        Stopwatch stopwatch = Stopwatch.StartNew();

        // Открываем scope на весь жизненный цикл HTTP-запроса: лог можно будет проследить пройденному конвейеру
        using (_logger.BeginScope(new List<KeyValuePair<string, object>> { new("RequestId", requestId) }))
        {
            try
            {
                await _next(context);

                stopwatch.Stop();

                LogLevel level = context.Response.StatusCode >= 500
                    ? LogLevel.Error
                    : context.Response.StatusCode >= 400
                        ? LogLevel.Warning
                        : LogLevel.Information;

                _logger.Log(
                    level,
                    "HTTP request completed. Method={Method}, Path={Path}, StatusCode={StatusCode}, ElapsedMs={ElapsedMs}",
                    method,
                    path,
                    context.Response.StatusCode,
                    stopwatch.ElapsedMilliseconds);
            }
            catch (OperationCanceledException ex) when (context.RequestAborted.IsCancellationRequested)
            {
                stopwatch.Stop();

                _logger.LogWarning(
                    ex,
                    "HTTP request canceled by client. Method={Method}, Path={Path}, ElapsedMs={ElapsedMs}",
                    method,
                    path,
                    stopwatch.ElapsedMilliseconds);

                throw;
            }
            catch (Exception ex)
            {
                stopwatch.Stop();

                _logger.LogError(
                    ex,
                    "HTTP request failed with unhandled exception. Method={Method}, Path={Path}, ElapsedMs={ElapsedMs}",
                    method,
                    path,
                    stopwatch.ElapsedMilliseconds);

                throw;
            }
        }
    }
}