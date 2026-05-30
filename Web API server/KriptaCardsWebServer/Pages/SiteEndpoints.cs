// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

using System.Text;
using KriptaCards.WebApi.Contracts.Cards;
using KriptaCards.WebApi.Contracts.Players;
using KriptaCards.WebApi.Domain.Players;
using KriptaCards.WebApi.Services.CardCatalog;
using KriptaCards.WebApi.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.StaticFiles;

namespace KriptaCards.WebApi.Pages;

/// <summary>
/// Маршруты сайта просмотра карточек без Foundry
/// </summary>
public static class SiteEndpoints
{
    private const string SessionCookieName = "kripta-player-session";
    private const string ThemeCookieName = "kripta-site-theme";
    private const string LanguageCookieName = "kripta-site-language";

    /// <summary>
    /// Зарегистрировать маршруты сайта
    /// </summary>
    public static void MapKriptaSite(this WebApplication app)
    {
        app.MapGet("/", async (
            HttpContext context,
            IPlayersCardsService players,
            IPlayerSessionService sessions,
            CancellationToken cancellationToken) =>
        {
            PlayerEntity? player = await GetCurrentPlayerAsync(context, sessions, cancellationToken);
            if (player != null)
            {
                return Results.Redirect("/home");
            }

            return Results.Content(
                SitePageBuilder.BuildLoginPage(players.GetPlayerLogins, GetPreferences(context)),
                "text/html; charset=utf-8");
        });

        app.MapGet("/home", async (
            HttpContext context,
            IPlayerSessionService sessions,
            CancellationToken cancellationToken) =>
        {
            PlayerEntity? player = await GetCurrentPlayerAsync(context, sessions, cancellationToken);
            if (player == null)
            {
                return Results.Redirect("/");
            }

            return Results.Content(
                SitePageBuilder.BuildHomePage(GetPreferences(context), player.Name ?? player.Login ?? string.Empty),
                "text/html; charset=utf-8");
        });

        app.MapGet("/catalog", async (
            HttpContext context,
            IPlayerSessionService sessions,
            CancellationToken cancellationToken) =>
        {
            PlayerEntity? player = await GetCurrentPlayerAsync(context, sessions, cancellationToken);
            if (player == null)
            {
                return Results.Redirect("/");
            }

            return Results.Content(
                SitePageBuilder.BuildBrowserPage("catalog", GetPreferences(context)),
                "text/html; charset=utf-8");
        });

        app.MapGet("/my-cards", async (
            HttpContext context,
            IPlayerSessionService sessions,
            CancellationToken cancellationToken) =>
        {
            PlayerEntity? player = await GetCurrentPlayerAsync(context, sessions, cancellationToken);
            if (player == null)
            {
                return Results.Redirect("/");
            }

            return Results.Content(
                SitePageBuilder.BuildBrowserPage("my-cards", GetPreferences(context)),
                "text/html; charset=utf-8");
        });

        app.MapGet("/card/{level:int}/{number:int}", async (
            HttpContext context,
            int level,
            int number,
            string? from,
            int? sourceLevel,
            string? search,
            IPlayerSessionService sessions,
            ICardCatalogService cards,
            CancellationToken cancellationToken) =>
        {
            PlayerEntity? player = await GetCurrentPlayerAsync(context, sessions, cancellationToken);
            if (player == null)
            {
                return Results.Redirect("/");
            }

            Card? card = cards.GetCardById(level, number);
            if (card == null)
            {
                return Results.NotFound("Card is not registered.");
            }

            string levelName = cards.Levels.FirstOrDefault(x => x.Id == level)?.Name ?? level.ToString();
            return Results.Content(
                SitePageBuilder.BuildCardPage(GetPreferences(context), card, levelName, from, sourceLevel, search),
                "text/html; charset=utf-8");
        });

        app.MapPost("/site/login", async (
            HttpContext context,
            IPlayersCardsService players,
            IPlayerSessionService sessions,
            CancellationToken cancellationToken) =>
        {
            (string Login, string Pin)? credentials = ReadBasicCredentials(context);
            if (credentials == null)
            {
                return Results.Unauthorized();
            }

            PlayerEntity? player = await players.GetPlayerByLoginAndPinAsync(credentials.Value.Login, credentials.Value.Pin);
            if (player == null)
            {
                return Results.Unauthorized();
            }

            DateTime utcNow = DateTime.UtcNow;
            PlayerSessionEntity session = await sessions.CreateSessionAsync(player.Id, utcNow, cancellationToken);
            context.Response.Cookies.Append(
                SessionCookieName,
                session.Id.ToString(),
                BuildSessionCookieOptions(context, session.ExpiresAtUtc));

            return Results.Json(new { ok = true });
        });

        app.MapPost("/site/logout", async (
            HttpContext context,
            IPlayerSessionService sessions,
            CancellationToken cancellationToken) =>
        {
            if (TryReadSessionId(context, out Guid sessionId))
            {
                await sessions.DeleteSessionAsync(sessionId, cancellationToken);
            }

            context.Response.Cookies.Delete(SessionCookieName);
            return Results.Json(new { ok = true });
        });

        app.MapGet("/logout", async (
            HttpContext context,
            IPlayerSessionService sessions,
            CancellationToken cancellationToken) =>
        {
            if (TryReadSessionId(context, out Guid sessionId))
            {
                await sessions.DeleteSessionAsync(sessionId, cancellationToken);
            }

            context.Response.Cookies.Delete(SessionCookieName);
            return Results.Redirect("/");
        });

        app.MapPost("/site/preferences", async (HttpContext context, CancellationToken cancellationToken) =>
        {
            SitePreferencesRequest? request = await context.Request.ReadFromJsonAsync<SitePreferencesRequest>(cancellationToken);
            string language = SitePageBuilder.NormalizeLanguage(request?.Language);
            string theme = SitePageBuilder.NormalizeTheme(request?.Theme);
            CookieOptions options = BuildPreferenceCookieOptions(context);

            context.Response.Cookies.Append(LanguageCookieName, language, options);
            context.Response.Cookies.Append(ThemeCookieName, theme, options);

            return Results.Json(new { ok = true, language, theme });
        });

        app.MapGet("/site/api/me", async (
            HttpContext context,
            IPlayerSessionService sessions,
            CancellationToken cancellationToken) =>
        {
            PlayerEntity? player = await GetCurrentPlayerAsync(context, sessions, cancellationToken);
            if (player == null)
            {
                return Results.Unauthorized();
            }

            return Results.Json(new
            {
                guid = player.Id,
                name = player.Name,
                login = player.Login
            });
        });

        app.MapGet("/site/api/levels", async (
            HttpContext context,
            IPlayerSessionService sessions,
            ICardCatalogService cards,
            CancellationToken cancellationToken) =>
        {
            PlayerEntity? player = await GetCurrentPlayerAsync(context, sessions, cancellationToken);
            return player == null ? Results.Unauthorized() : Results.Json(cards.Levels);
        });

        app.MapGet("/site/api/cards", async (
            HttpContext context,
            int? level,
            string? search,
            IPlayerSessionService sessions,
            ICardCatalogService cards,
            CancellationToken cancellationToken) =>
        {
            PlayerEntity? player = await GetCurrentPlayerAsync(context, sessions, cancellationToken);
            if (player == null)
            {
                return Results.Unauthorized();
            }

            IEnumerable<Card> query = cards.Cards;
            if (level != null && level >= 0)
            {
                query = query.Where(x => x.Level == level.Value);
            }

            if (!string.IsNullOrWhiteSpace(search))
            {
                string normalizedSearch = search.Trim().ToUpperInvariant();
                query = query.Where(x => x.Name.ToUpperInvariant().Contains(normalizedSearch));
            }

            List<CardResponseRow> rows = [.. query.Select(x => new CardResponseRow
            {
                Level = x.Level,
                Number = x.Number,
                Name = x.Name
            })];

            return Results.Json(rows);
        });

        app.MapGet("/site/api/card/{level:int}/{number:int}", async (
            HttpContext context,
            int level,
            int number,
            IPlayerSessionService sessions,
            ICardCatalogService cards,
            CancellationToken cancellationToken) =>
        {
            PlayerEntity? player = await GetCurrentPlayerAsync(context, sessions, cancellationToken);
            if (player == null)
            {
                return Results.Unauthorized();
            }

            Card? card = cards.GetCardById(level, number);
            return card == null ? Results.NotFound("Card is not registered.") : Results.Json(card);
        });

        app.MapGet("/site/api/my-cards", async (
            HttpContext context,
            IPlayerSessionService sessions,
            CancellationToken cancellationToken) =>
        {
            PlayerEntity? player = await GetCurrentPlayerAsync(context, sessions, cancellationToken);
            if (player == null)
            {
                return Results.Unauthorized();
            }

            return Results.Json(new
            {
                guid = player.Id.ToString(),
                name = player.Name,
                playerCards = player.Cards.Select(card => new PlayersCardDto
                {
                    Guid = card.Id.ToString(),
                    Level = card.Level,
                    Number = card.Number,
                    Count = card.Count,
                    OwnerGuid = card.PlayerId.ToString()
                })
            });
        });

        app.MapGet("/site/api/card-image/{**imagePath}", async (
            HttpContext context,
            string imagePath,
            IPlayerSessionService sessions,
            ICardCatalogService cards,
            CancellationToken cancellationToken) =>
        {
            PlayerEntity? player = await GetCurrentPlayerAsync(context, sessions, cancellationToken);
            if (player == null)
            {
                return Results.Unauthorized();
            }

            try
            {
                FileInfo fileInfo = cards.GetFile(Uri.UnescapeDataString(imagePath));
                DateTimeOffset fileLastModified = fileInfo.LastWriteTimeUtc;
                long length = fileInfo.Length;
                string eTag = $"\"{fileLastModified.ToUnixTimeSeconds()}-{length}\"";

                if (context.Request.Headers.IfNoneMatch == eTag)
                {
                    return Results.StatusCode(StatusCodes.Status304NotModified);
                }

                if (context.Request.Headers.IfModifiedSince.Count > 0
                    && DateTimeOffset.TryParse(context.Request.Headers.IfModifiedSince, out DateTimeOffset requestModifiedTime)
                    && fileLastModified <= requestModifiedTime)
                {
                    return Results.StatusCode(StatusCodes.Status304NotModified);
                }

                context.Response.Headers.ETag = eTag;
                context.Response.Headers.LastModified = fileLastModified.ToString("R");
                context.Response.Headers.CacheControl = "public,max-age=86400";

                FileExtensionContentTypeProvider contentTypeProvider = new();
                if (!contentTypeProvider.TryGetContentType(imagePath, out string? contentType))
                {
                    contentType = "application/octet-stream";
                }

                return Results.File(fileInfo.OpenRead(), contentType);
            }
            catch (FileNotFoundException)
            {
                return Results.NotFound("Card image is not registered.");
            }
            catch (IOException ex)
            {
                return Results.BadRequest(ex.Message);
            }
        });
    }

    private static async Task<PlayerEntity?> GetCurrentPlayerAsync(
        HttpContext context,
        IPlayerSessionService sessions,
        CancellationToken cancellationToken)
    {
        if (!TryReadSessionId(context, out Guid sessionId))
        {
            return null;
        }

        PlayerSessionEntity? session = await sessions.GetValidSessionAsync(sessionId, DateTime.UtcNow, cancellationToken);
        if (session?.Owner == null)
        {
            context.Response.Cookies.Delete(SessionCookieName);
            return null;
        }

        return session.Owner;
    }

    private static bool TryReadSessionId(HttpContext context, out Guid sessionId)
    {
        string? value = context.Request.Cookies[SessionCookieName];
        return Guid.TryParse(value, out sessionId);
    }

    private static (string Login, string Pin)? ReadBasicCredentials(HttpContext context)
    {
        string authString = context.Request.Headers.Authorization.ToString();
        if (string.IsNullOrWhiteSpace(authString) || !authString.StartsWith("Basic ", StringComparison.OrdinalIgnoreCase))
        {
            return null;
        }

        string encodedValue = authString["Basic ".Length..].Trim();
        if (string.IsNullOrWhiteSpace(encodedValue))
        {
            return null;
        }

        string decodedValue;
        try
        {
            decodedValue = Encoding.UTF8.GetString(Convert.FromBase64String(encodedValue));
        }
        catch (FormatException)
        {
            return null;
        }

        int separatorIndex = decodedValue.IndexOf(':');
        if (separatorIndex <= 0)
        {
            return null;
        }

        return (decodedValue[..separatorIndex].Trim(), decodedValue[(separatorIndex + 1)..].Trim());
    }

    private static SitePreferences GetPreferences(HttpContext context)
    {
        string language = SitePageBuilder.NormalizeLanguage(context.Request.Cookies[LanguageCookieName]);
        string theme = SitePageBuilder.NormalizeTheme(context.Request.Cookies[ThemeCookieName]);
        return new SitePreferences(language, theme);
    }

    private static CookieOptions BuildSessionCookieOptions(HttpContext context, DateTime expiresAtUtc)
    {
        return new CookieOptions
        {
            HttpOnly = true,
            SameSite = SameSiteMode.Lax,
            Secure = context.Request.IsHttps,
            Expires = new DateTimeOffset(expiresAtUtc, TimeSpan.Zero),
            MaxAge = expiresAtUtc - DateTime.UtcNow
        };
    }

    private static CookieOptions BuildPreferenceCookieOptions(HttpContext context)
    {
        return new CookieOptions
        {
            HttpOnly = false,
            SameSite = SameSiteMode.Lax,
            Secure = context.Request.IsHttps,
            Expires = DateTimeOffset.UtcNow.AddYears(10),
            MaxAge = TimeSpan.FromDays(3650)
        };
    }
}
