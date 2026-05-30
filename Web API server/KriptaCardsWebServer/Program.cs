// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

using KriptaCards.WebApi.DataBases.Players;
using KriptaCards.WebApi.Middleware.Auth;
using KriptaCards.WebApi.Middleware.Logging;
using KriptaCards.WebApi.Pages;
using KriptaCards.WebApi.Services.CardCatalog;
using KriptaCards.WebApi.Services.Interfaces;
using KriptaCards.WebApi.Services.Players;
using KriptaCards.WebApi.Services.Users;

using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Microsoft.OpenApi;

using NLog.Web;

// Собираем настройки и сервисы
WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

builder.Logging.ClearProviders();
builder.Host.UseNLog(new NLogAspNetCoreOptions { IncludeScopes = true });

builder.Services.AddWindowsService();
builder.Services.AddSystemd();

IConfigurationSection usersConfigSection = builder.Configuration.GetSection(UserSettingsSection.SectionName);
builder.Services.Configure<UserSettingsSection>(usersConfigSection);
builder.Services.AddSingleton<IUserService>(sp =>
{
    UserSettingsSection settings = sp.GetRequiredService<IOptions<UserSettingsSection>>().Value;
    return new EasyUserService(settings.Users);
});

ICardCatalogService cardCatalogService = await SimpleCardCatalogService.CreateServiceAsync(CancellationToken.None);
builder.Services.AddSingleton<ICardCatalogService>(cardCatalogService);

string sqlitePathDirectory = Path.Combine(AppContext.BaseDirectory, "Content", "SQLite");
Directory.CreateDirectory(sqlitePathDirectory);
builder.Services.AddDbContext<PlayersDbContext>(options => options.UseSqlite($"Data Source={Path.Combine(sqlitePathDirectory, "players.db")}"));
builder.Services.AddScoped<IPlayersCardsService>(x => new SqlitePlayersCardsService(x.GetRequiredService<PlayersDbContext>(), cardCatalogService));
builder.Services.AddScoped<IPlayerSessionService, SqlitePlayerSessionService>();
builder.Services.AddScoped<PlayersDbInitializer>();

string[] corsAllowedOrigins = builder.Configuration
    .GetSection("Cors:AllowedOrigins")
    .Get<string[]>() ?? [];
builder.Services.AddCors(corsOptions =>
{
    corsOptions.AddPolicy("FoundryCors", policy =>
    {
        policy.WithOrigins(corsAllowedOrigins)
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

builder.Services.AddControllers();
builder.Services.AddAuthorization();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    string baseDir = AppContext.BaseDirectory;
    string xmlSummaryPath = Path.Combine(baseDir, "Content", "artifacts", "docs", "KriptaCardsWebServer.xml");
    if (File.Exists(xmlSummaryPath))
    {
        options.IncludeXmlComments(xmlSummaryPath);
    }

    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Сетевое приложение для \"Карточики крипты\" к модулю Foundry VTT",
        Version = "v1",
        Description = "Пользовательская документация: <a href=\"/readme\">README</a>"
    });

    options.AddSecurityDefinition("BasicAuth", new OpenApiSecurityScheme
    {
        Type = SecuritySchemeType.Http,
        Scheme = "basic",
        Description = "Введите ID в поле username и ключ в поле password"
    });

    options.AddSecurityRequirement(document => new OpenApiSecurityRequirement
    {
        [new OpenApiSecuritySchemeReference("BasicAuth", document)] = []
    });
});

// Запускаем приложение, настраиваем pipeline
WebApplication app = builder.Build();

using (IServiceScope scope = app.Services.CreateScope())
{
    PlayersDbInitializer dbInitializer = scope.ServiceProvider.GetRequiredService<PlayersDbInitializer>();
    await dbInitializer.InitializeAsync();
}

app.MapGet("/readme", async () =>
{
    string readmePath = Path.Combine(AppContext.BaseDirectory, "README.md");

    if (!File.Exists(readmePath))
    {
        const string fallbackHtml =
        """
        <!DOCTYPE html>
        <html lang="ru">
        <head>
            <meta charset="utf-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1" />
            <title>Kripta Cards Web API</title>
        </head>
        <body>
            <h1>Kripta Cards Web API</h1>
            <p>README.md не найден рядом с приложением.</p>
        </body>
        </html>
        """;
        return Results.Content(fallbackHtml, "text/html; charset=utf-8");
    }

    string markdown = await File.ReadAllTextAsync(readmePath);
    string html = ReadmePageBuilder.BuildHtml(markdown, "Kripta Cards Web API");

    return Results.Content(html, "text/html; charset=utf-8");
});

app.UseSwagger();
app.UseSwaggerUI(options =>
{
    options.DocumentTitle = "Kripta Cards Web API";
    options.RoutePrefix = "swagger";
});
app.MapKriptaSite();

app.UseRouting();
app.UseCors("FoundryCors");

app.UseMiddleware<RequestLoggingMiddleware>();
app.UseMiddleware<RequestBaseAuthenticationMeddleware>();

app.UseAuthorization();
app.MapControllers();

app.Run();
