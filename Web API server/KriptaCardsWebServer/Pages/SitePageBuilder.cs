// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

using System.Text.Encodings.Web;
using System.Text.Json;
using KriptaCards.WebApi.Services.CardCatalog;

namespace KriptaCards.WebApi.Pages;

/// <summary>
/// Простая HTML-оболочка сайта просмотра карточек без Foundry
/// </summary>
public static class SitePageBuilder
{
    private static readonly HtmlEncoder Html = HtmlEncoder.Default;

    private static readonly Dictionary<string, Dictionary<string, string>> Strings = new()
    {
        ["en"] = new()
        {
            ["AppTitle"] = "Kripta Cards",
            ["LoginTitle"] = "Server Login",
            ["LoginHint"] = "Choose a player login and enter the pin code.",
            ["Login"] = "Login",
            ["Pin"] = "Pin code",
            ["Enter"] = "Submit",
            ["LoginFailed"] = "Login failed. Check the login and pin code.",
            ["Required"] = "Login and pin code are required.",
            ["Home"] = "Home",
            ["HomeTitle"] = "Kripta Cards",
            ["HomeHint"] = "Read-only server access.",
            ["Catalog"] = "Card Catalog",
            ["MyCards"] = "My Cards",
            ["CardDetails"] = "Catalog Card",
            ["Logout"] = "Logout",
            ["Theme"] = "Theme",
            ["Dark"] = "Dark",
            ["Light"] = "Light",
            ["Language"] = "Language",
            ["Search"] = "Search",
            ["Table"] = "Table",
            ["Tiles"] = "Tiles",
            ["Empty"] = "Nothing to show.",
            ["Quantity"] = "Quantity",
            ["Back"] = "Back",
            ["Open"] = "Open",
            ["Loading"] = "Loading...",
            ["Error"] = "Failed to load data.",
            ["Player"] = "Player"
        },
        ["ru"] = new()
        {
            ["AppTitle"] = "Карточки Крипты",
            ["LoginTitle"] = "Вход на сервер",
            ["LoginHint"] = "Выберите логин игрока и введите пин-код.",
            ["Login"] = "Пользователь",
            ["Pin"] = "Пин-код",
            ["Enter"] = "Войти",
            ["LoginFailed"] = "Не удалось войти. Проверьте логин и пин-код.",
            ["Required"] = "Нужно выбрать логин и ввести пин-код.",
            ["Home"] = "Главная",
            ["HomeTitle"] = "Карточки Крипты",
            ["HomeHint"] = "Доступ к серверу только для просмотра.",
            ["Catalog"] = "Каталог карточек",
            ["MyCards"] = "Мои карточки",
            ["CardDetails"] = "Карточка каталога",
            ["Logout"] = "Выход",
            ["Theme"] = "Тема",
            ["Dark"] = "Темная",
            ["Light"] = "Светлая",
            ["Language"] = "Язык",
            ["Search"] = "Поиск",
            ["Table"] = "Таблица",
            ["Tiles"] = "Плитки",
            ["Empty"] = "Пока нечего показать.",
            ["Quantity"] = "Количество",
            ["Back"] = "Назад",
            ["Open"] = "Открыть",
            ["Loading"] = "Загрузка...",
            ["Error"] = "Не удалось загрузить данные.",
            ["Player"] = "Игрок"
        }
    };

    /// <summary>
    /// Собрать страницу входа
    /// </summary>
    public static string BuildLoginPage(IEnumerable<string> logins, SitePreferences preferences)
    {
        Dictionary<string, string> t = GetStrings(preferences.Language);
        string options = "<option value=\"\"></option>" + string.Join(
            string.Empty,
            logins.Select(login => $"<option value=\"{Html.Encode(login)}\">{Html.Encode(login)}</option>"));

        string content =
            $$"""
            <main class="login-panel">
                <section class="login-box">
                    <h1>{{Html.Encode(t["LoginTitle"])}}</h1>
                    <p>{{Html.Encode(t["LoginHint"])}}</p>
                    <form id="login-form" autocomplete="off">
                        <label>
                            <span>{{Html.Encode(t["Login"])}}</span>
                            <select name="login" required>{{options}}</select>
                        </label>
                        <label>
                            <span>{{Html.Encode(t["Pin"])}}</span>
                            <input name="pin" inputmode="numeric" maxlength="5" pattern="\d{5}" type="password" required>
                        </label>
                        <div id="login-error" class="error" hidden></div>
                        <button type="submit">{{Html.Encode(t["Enter"])}}</button>
                    </form>
                </section>
            </main>
            """;

        return BuildShell(t["LoginTitle"], preferences, content, BuildLoginScript(t), isAuthenticated: false);
    }

    /// <summary>
    /// Собрать главную страницу
    /// </summary>
    public static string BuildHomePage(SitePreferences preferences, string playerName)
    {
        Dictionary<string, string> t = GetStrings(preferences.Language);
        string content =
            $$"""
            <main class="home">
                <section>
                    <p class="eyebrow">{{Html.Encode(t["Player"])}}: {{Html.Encode(playerName)}}</p>
                    <h1>{{Html.Encode(t["HomeTitle"])}}</h1>
                    <p>{{Html.Encode(t["HomeHint"])}}</p>
                    <div class="home-actions">
                        <a class="button" href="/catalog">{{Html.Encode(t["Catalog"])}}</a>
                        <a class="button" href="/my-cards">{{Html.Encode(t["MyCards"])}}</a>
                    </div>
                </section>
            </main>
            """;

        return BuildShell(t["HomeTitle"], preferences, content, BuildBaseScript(), isAuthenticated: true);
    }

    /// <summary>
    /// Собрать страницу каталога или карточек игрока
    /// </summary>
    public static string BuildBrowserPage(string page, SitePreferences preferences)
    {
        Dictionary<string, string> t = GetStrings(preferences.Language);
        string title = page == "my-cards" ? t["MyCards"] : t["Catalog"];
        string content =
            $$"""
            <main class="browser-page" data-page="{{Html.Encode(page)}}">
                <section class="browser-shell">
                    <aside class="levels" id="levels"></aside>
                    <section class="browser-main">
                        <header class="browser-header">
                            <div>
                                <h1 id="page-title">{{Html.Encode(title)}}</h1>
                                <div id="level-description" class="level-description"></div>
                            </div>
                            <div class="toolbar">
                                <input id="search" type="search" placeholder="{{Html.Encode(t["Search"])}}">
                                <button type="button" data-view="table">{{Html.Encode(t["Table"])}}</button>
                                <button type="button" data-view="tiles">{{Html.Encode(t["Tiles"])}}</button>
                            </div>
                        </header>
                        <div id="cards" class="cards">{{Html.Encode(t["Loading"])}}</div>
                    </section>
                </section>
            </main>
            """;

        return BuildShell(title, preferences, content, BuildBrowserScript(t, page), isAuthenticated: true);
    }

    /// <summary>
    /// Собрать страницу подробностей карточки
    /// </summary>
    public static string BuildCardPage(SitePreferences preferences, Card card, string levelName, string? sourcePage, int? sourceLevel, string? search)
    {
        Dictionary<string, string> t = GetStrings(preferences.Language);
        string image = string.IsNullOrWhiteSpace(card.ImagePath) ? string.Empty : BuildImageUrl(card.ImagePath);
        string imageHtml = string.IsNullOrWhiteSpace(image)
            ? string.Empty
            : $"<div class=\"detail-image\"><img src=\"{Html.Encode(image)}\" alt=\"{Html.Encode(card.Name)}\"></div>";
        string backUrl = BuildCardBackUrl(sourcePage, sourceLevel, search);

        string content =
            $$"""
            <main class="detail-page">
                <article class="detail">
                    <a class="back" href="{{Html.Encode(backUrl)}}">{{Html.Encode(t["Back"])}}</a>
                    <h1>{{Html.Encode(card.Name)}}</h1>
                    <div class="muted">{{Html.Encode(levelName)}}</div>
                    <div class="card-html">{{card.Description}}</div>
                    {{imageHtml}}
                </article>
            </main>
            """;

        return BuildShell(card.Name, preferences, content, BuildBaseScript(), isAuthenticated: true);
    }

    /// <summary>
    /// Построить URL картинки карточки для сайта
    /// </summary>
    public static string BuildImageUrl(string imagePath)
    {
        string normalized = imagePath.Replace('\\', '/').TrimStart('/');
        string encoded = string.Join("/", normalized.Split('/', StringSplitOptions.RemoveEmptyEntries).Select(Uri.EscapeDataString));
        return $"/site/api/card-image/{encoded}";
    }

    private static string BuildCardBackUrl(string? sourcePage, int? sourceLevel, string? search)
    {
        string path = StringComparer.OrdinalIgnoreCase.Equals(sourcePage, "my-cards")
            ? "/my-cards"
            : "/catalog";

        List<string> query = [];
        if (sourceLevel is >= 0)
        {
            query.Add($"level={sourceLevel.Value}");
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            query.Add($"search={Uri.EscapeDataString(search.Trim())}");
        }

        return query.Count > 0 ? $"{path}?{string.Join("&", query)}" : path;
    }

    /// <summary>
    /// Получить строки локализации
    /// </summary>
    public static Dictionary<string, string> GetStrings(string language)
    {
        return Strings.TryGetValue(NormalizeLanguage(language), out Dictionary<string, string>? result)
            ? result
            : Strings["en"];
    }

    /// <summary>
    /// Нормализовать язык
    /// </summary>
    public static string NormalizeLanguage(string? language) => StringComparer.OrdinalIgnoreCase.Equals(language, "ru") ? "ru" : "en";

    /// <summary>
    /// Нормализовать тему
    /// </summary>
    public static string NormalizeTheme(string? theme) => StringComparer.OrdinalIgnoreCase.Equals(theme, "light") ? "light" : "dark";

    private static string BuildShell(string title, SitePreferences preferences, string content, string script, bool isAuthenticated)
    {
        Dictionary<string, string> t = GetStrings(preferences.Language);
        string authNav = isAuthenticated
            ? $$"""
              <a href="/home">{{Html.Encode(t["Home"])}}</a>
              <a href="/catalog">{{Html.Encode(t["Catalog"])}}</a>
              <a href="/my-cards">{{Html.Encode(t["MyCards"])}}</a>
              <button type="button" id="logout">{{Html.Encode(t["Logout"])}}</button>
              """
            : string.Empty;

        return
            $$"""
            <!DOCTYPE html>
            <html lang="{{Html.Encode(preferences.Language)}}" data-theme="{{Html.Encode(preferences.Theme)}}">
            <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <title>{{Html.Encode(title)}} - {{Html.Encode(t["AppTitle"])}}</title>
                <style>{{Css}}</style>
            </head>
            <body>
                <header class="topbar">
                    <a class="brand" href="/home">{{Html.Encode(t["AppTitle"])}}</a>
                    <nav>{{authNav}}</nav>
                    <div class="prefs">
                        <label>{{Html.Encode(t["Theme"])}}
                            <select id="theme-select">
                                <option value="dark"{{(preferences.Theme == "dark" ? " selected" : "")}}>{{Html.Encode(t["Dark"])}}</option>
                                <option value="light"{{(preferences.Theme == "light" ? " selected" : "")}}>{{Html.Encode(t["Light"])}}</option>
                            </select>
                        </label>
                        <label>{{Html.Encode(t["Language"])}}
                            <select id="language-select">
                                <option value="en"{{(preferences.Language == "en" ? " selected" : "")}}>En</option>
                                <option value="ru"{{(preferences.Language == "ru" ? " selected" : "")}}>Ru</option>
                            </select>
                        </label>
                    </div>
                </header>
                {{content}}
                <script>{{script}}</script>
            </body>
            </html>
            """;
    }

    private static string BuildLoginScript(Dictionary<string, string> t)
    {
        string messages = JsonSerializer.Serialize(t);
        return
            $$"""
            const L = {{messages}};
            {{BaseJavascript}}
            function base64Utf8(value) {
                const bytes = new TextEncoder().encode(value);
                let binary = "";
                for (const byte of bytes) binary += String.fromCharCode(byte);
                return btoa(binary);
            }
            document.getElementById("login-form").addEventListener("submit", async (event) => {
                event.preventDefault();
                const form = event.currentTarget;
                const login = String(form.elements.login.value || "").trim();
                const pin = String(form.elements.pin.value || "").trim();
                const error = document.getElementById("login-error");
                error.hidden = true;
                if (!login || !pin) {
                    error.textContent = L.Required;
                    error.hidden = false;
                    return;
                }
                const response = await fetch("/site/login", {
                    method: "POST",
                    headers: { Authorization: `Basic ${base64Utf8(`${login}:${pin}`)}` },
                    credentials: "same-origin"
                }).catch(() => null);
                if (!response || !response.ok) {
                    error.textContent = L.LoginFailed;
                    error.hidden = false;
                    return;
                }
                location.href = "/home";
            });
            """;
    }

    private static string BuildBaseScript()
    {
        return BaseJavascript;
    }

    private static string BuildBrowserScript(Dictionary<string, string> t, string page)
    {
        string messages = JsonSerializer.Serialize(t);
        string pageJson = JsonSerializer.Serialize(page);
        return
            $$"""
            const L = {{messages}};
            const PAGE = {{pageJson}};
            {{BaseJavascript}}
            const initialParams = new URLSearchParams(window.location.search);
            const initialLevel = Number(initialParams.get("level"));
            const initialSearch = String(initialParams.get("search") || "");

            const state = {
                levels: [],
                activeLevel: Number.isInteger(initialLevel) && initialLevel >= 0 ? initialLevel : null,
                cards: [],
                search: initialSearch,
                view: localStorage.getItem(`kripta-view-${PAGE}`) || "tiles"
            };

            async function api(path) {
                const response = await fetch(path, { credentials: "same-origin", cache: "no-store" });
                if (response.status === 401) {
                    location.href = "/";
                    return null;
                }
                if (!response.ok) throw new Error(L.Error);
                return response.json();
            }

            function stripHtml(value) {
                const div = document.createElement("div");
                div.innerHTML = String(value || "");
                return div.textContent || div.innerText || "";
            }

            function escapeHtml(value) {
                return String(value || "")
                    .replaceAll("&", "&amp;")
                    .replaceAll("<", "&lt;")
                    .replaceAll(">", "&gt;")
                    .replaceAll('"', "&quot;")
                    .replaceAll("'", "&#039;");
            }

            function imageUrl(path) {
                return "/site/api/card-image/" + String(path || "")
                    .replace(/\\/g, "/")
                    .replace(/^\/+/, "")
                    .split("/")
                    .filter(Boolean)
                    .map(encodeURIComponent)
                    .join("/");
            }

            function normalizeLevel(level) {
                return {
                    id: Number(level.id ?? level.Id ?? level.level ?? level.Level ?? 0),
                    name: String(level.name ?? level.Name ?? ""),
                    description: String(level.description ?? level.Description ?? "")
                };
            }

            function normalizeCard(card) {
                return {
                    level: Number(card.level ?? card.Level ?? 0),
                    number: Number(card.number ?? card.Number ?? card.card ?? card.Card ?? 0),
                    name: String(card.name ?? card.Name ?? ""),
                    description: String(card.description ?? card.Description ?? ""),
                    imagePath: String(card.imagePath ?? card.ImagePath ?? ""),
                    count: Number(card.count ?? card.Count ?? 1),
                    missing: Boolean(card.missing)
                };
            }

            async function loadMeta(level, number, fallback = {}) {
                try {
                    return normalizeCard(await api(`/site/api/card/${level}/${number}`));
                } catch (_error) {
                    return {
                        level,
                        number,
                        name: fallback.name || `Card ${number}`,
                        description: fallback.description || "",
                        imagePath: "",
                        missing: true
                    };
                }
            }

            async function loadCatalog() {
                state.levels = (await api("/site/api/levels") || []).map(normalizeLevel);
                if (!state.levels.length) return;
                if (state.activeLevel === null || state.activeLevel === undefined || !state.levels.some((item) => Number(item.id) === Number(state.activeLevel))) {
                    state.activeLevel = state.levels[0].id;
                }
                const rows = await api(`/site/api/cards?level=${encodeURIComponent(state.activeLevel)}`) || [];
                state.cards = await Promise.all(rows.map(async (row) => {
                    const card = normalizeCard(row);
                    const meta = await loadMeta(card.level, card.number, card);
                    return { ...card, ...meta };
                }));
            }

            async function loadMyCards() {
                const [levelsRaw, cardsRaw] = await Promise.all([
                    api("/site/api/levels"),
                    api("/site/api/my-cards")
                ]);
                const levels = (levelsRaw || []).map(normalizeLevel);
                const grouped = new Map();
                for (const row of (cardsRaw?.playerCards || [])) {
                    const card = normalizeCard(row);
                    if (!Number.isInteger(card.level) || !Number.isInteger(card.number) || card.count <= 0) continue;
                    const key = `${card.level}:${card.number}`;
                    const existing = grouped.get(key) || { level: card.level, number: card.number, count: 0 };
                    existing.count += card.count;
                    grouped.set(key, existing);
                }
                const extraLevels = [...new Set([...grouped.values()].map((card) => card.level))]
                    .filter((level) => !levels.some((item) => Number(item.id) === Number(level)))
                    .map((level) => ({ id: level, name: `Level ${level}`, description: "" }));
                state.levels = [...levels, ...extraLevels].sort((a, b) => Number(a.id) - Number(b.id));
                if (!state.levels.length) return;
                if (state.activeLevel === null || state.activeLevel === undefined || !state.levels.some((item) => Number(item.id) === Number(state.activeLevel))) {
                    state.activeLevel = state.levels[0].id;
                }
                const currentCards = [...grouped.values()].filter((card) => Number(card.level) === Number(state.activeLevel));
                state.cards = await Promise.all(currentCards.map(async (card) => {
                    const meta = await loadMeta(card.level, card.number, card);
                    return { ...card, ...meta, count: card.count };
                }));
            }

            function renderLevels() {
                const host = document.getElementById("levels");
                host.innerHTML = "";
                for (const level of state.levels) {
                    const button = document.createElement("button");
                    button.type = "button";
                    button.className = Number(level.id) === Number(state.activeLevel) ? "active" : "";
                    button.textContent = level.name || String(level.id);
                    button.title = stripHtml(level.description);
                    button.addEventListener("click", async () => {
                        state.activeLevel = level.id;
                        await reload();
                    });
                    host.appendChild(button);
                }
            }

            function renderCards() {
                const host = document.getElementById("cards");
                const query = state.search.trim().toLowerCase();
                const visible = state.cards.filter((card) => {
                    const haystack = `${stripHtml(card.name)} ${stripHtml(card.description)}`.toLowerCase();
                    return !query || haystack.includes(query);
                });

                host.className = state.view === "table" ? "cards cards-table" : "cards cards-tiles";
                host.innerHTML = "";

                if (!visible.length) {
                    host.textContent = L.Empty;
                    return;
                }

                for (const card of visible) {
                    const article = document.createElement("article");
                    article.className = state.view === "table" ? "card-row" : "card-tile";

                    const img = card.imagePath ? `<img src="${imageUrl(card.imagePath)}" alt="">` : "";
                    const count = PAGE === "my-cards" ? `<span class="badge">${L.Quantity}: ${card.count}</span>` : "";
                    const text = stripHtml(card.description);
                    const preview = text.length > 240 ? `${text.slice(0, 240)}...` : text;
                    const displayName = escapeHtml(card.name || `${card.level}/${card.number}`);
                    const displayPreview = escapeHtml(preview);
                    const cardParams = new URLSearchParams({
                        from: PAGE,
                        sourceLevel: String(state.activeLevel ?? card.level)
                    });
                    if (state.search.trim()) {
                        cardParams.set("search", state.search.trim());
                    }
                    const cardHref = `/card/${card.level}/${card.number}?${cardParams.toString()}`;
                    article.innerHTML = `
                        <a class="card-image" href="${cardHref}">${img}</a>
                        <div class="card-body">
                            <h2><a href="${cardHref}">${displayName}</a></h2>
                            ${count}
                            <p>${displayPreview}</p>
                        </div>
                    `;
                    host.appendChild(article);
                }
            }

            function renderHeader() {
                const active = state.levels.find((item) => Number(item.id) === Number(state.activeLevel));
                document.getElementById("page-title").textContent =
                    PAGE === "my-cards" ? L.MyCards : (active?.name || L.Catalog);
                document.getElementById("level-description").innerHTML = active?.description || "";
                document.querySelectorAll("[data-view]").forEach((button) => {
                    button.classList.toggle("active", button.dataset.view === state.view);
                });
            }

            async function reload() {
                document.getElementById("cards").textContent = L.Loading;
                if (PAGE === "my-cards") await loadMyCards();
                else await loadCatalog();
                renderLevels();
                renderHeader();
                renderCards();
            }

            document.getElementById("search").value = state.search;
            document.getElementById("search").addEventListener("input", (event) => {
                state.search = String(event.currentTarget.value || "");
                renderCards();
            });
            document.querySelectorAll("[data-view]").forEach((button) => {
                button.addEventListener("click", () => {
                    state.view = button.dataset.view;
                    localStorage.setItem(`kripta-view-${PAGE}`, state.view);
                    renderHeader();
                    renderCards();
                });
            });
            reload().catch((error) => {
                console.error(error);
                document.getElementById("cards").textContent = L.Error;
            });
            """;
    }

    private const string BaseJavascript =
        """
        async function savePreferences() {
            const theme = document.getElementById("theme-select")?.value || "dark";
            const language = document.getElementById("language-select")?.value || "en";
            await fetch("/site/preferences", {
                method: "POST",
                credentials: "same-origin",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ theme, language })
            }).catch(() => null);
        }
        document.getElementById("theme-select")?.addEventListener("change", async (event) => {
            document.documentElement.dataset.theme = event.currentTarget.value || "dark";
            await savePreferences();
        });
        document.getElementById("language-select")?.addEventListener("change", async () => {
            await savePreferences();
            location.reload();
        });
        document.getElementById("logout")?.addEventListener("click", async () => {
            await fetch("/site/logout", { method: "POST", credentials: "same-origin" }).catch(() => null);
            location.href = "/";
        });
        """;

    private const string Css =
        """
        :root {
            color-scheme: dark;
            --bg: #111315;
            --panel: #1a1d20;
            --panel-2: #22262a;
            --text: #f1f1f1;
            --muted: #a8afb6;
            --border: #343a40;
            --accent: #d8a34b;
            --accent-text: #1b1206;
            --danger: #f08b8b;
        }
        html[data-theme="light"] {
            color-scheme: light;
            --bg: #f5f6f7;
            --panel: #ffffff;
            --panel-2: #eceff1;
            --text: #1f252b;
            --muted: #63707a;
            --border: #d5dbe0;
            --accent: #8f621d;
            --accent-text: #ffffff;
            --danger: #a53e3e;
        }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            min-height: 100vh;
            background: var(--bg);
            color: var(--text);
            font-family: Arial, Helvetica, sans-serif;
            letter-spacing: 0;
        }
        a { color: inherit; }
        .topbar {
            min-height: 58px;
            display: flex;
            align-items: center;
            gap: 18px;
            padding: 10px 18px;
            border-bottom: 1px solid var(--border);
            background: var(--panel);
        }
        .brand {
            font-weight: 700;
            text-decoration: none;
            white-space: nowrap;
        }
        nav {
            display: flex;
            align-items: center;
            gap: 8px;
            flex: 1 1 auto;
        }
        nav a, nav button, .button, button {
            border: 1px solid var(--border);
            background: var(--panel-2);
            color: var(--text);
            border-radius: 6px;
            padding: 8px 11px;
            text-decoration: none;
            cursor: pointer;
            font: inherit;
        }
        nav a:hover, nav button:hover, .button:hover, button:hover, button.active {
            border-color: var(--accent);
        }
        .prefs {
            display: flex;
            gap: 10px;
            align-items: center;
            color: var(--muted);
            font-size: 13px;
        }
        select, input {
            width: 100%;
            min-height: 34px;
            border: 1px solid var(--border);
            border-radius: 6px;
            background: var(--panel-2);
            color: var(--text);
            padding: 7px 9px;
        }
        .prefs select { width: auto; margin-left: 5px; }
        .login-panel, .home, .detail-page {
            width: min(900px, calc(100vw - 32px));
            margin: 42px auto;
        }
        .login-panel {
            width: min(500px, calc(100vw - 32px));
        }
        .login-box, .home section, .detail {
            background: var(--panel);
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 24px;
        }
        h1 { margin: 0 0 10px; font-size: 30px; }
        h2 { margin: 0 0 8px; font-size: 18px; }
        p { color: var(--muted); line-height: 1.45; }
        form { display: grid; gap: 14px; }
        label span { display: block; margin-bottom: 6px; color: var(--muted); }
        form button, .button {
            background: var(--accent);
            color: var(--accent-text);
            border-color: var(--accent);
            font-weight: 700;
        }
        .error { color: var(--danger); }
        .eyebrow, .muted { color: var(--muted); }
        .home-actions { display: flex; gap: 12px; flex-wrap: wrap; margin-top: 22px; }
        .browser-page { height: calc(100vh - 59px); }
        .browser-shell {
            height: 100%;
            display: grid;
            grid-template-columns: minmax(180px, 240px) minmax(0, 1fr);
        }
        .levels {
            overflow: auto;
            padding: 12px;
            border-right: 1px solid var(--border);
            background: var(--panel);
        }
        .levels button {
            display: block;
            width: 100%;
            text-align: left;
            margin-bottom: 8px;
        }
        .browser-main {
            min-width: 0;
            overflow: auto;
            padding: 18px;
        }
        .browser-header {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 18px;
            margin-bottom: 18px;
        }
        .level-description {
            color: var(--muted);
            max-width: 760px;
        }
        .toolbar {
            display: grid;
            grid-template-columns: minmax(180px, 260px) auto auto;
            gap: 8px;
            align-items: center;
        }
        .cards-tiles {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 14px;
        }
        .card-tile, .card-row {
            border: 1px solid var(--border);
            background: var(--panel);
            border-radius: 8px;
            overflow: hidden;
        }
        .card-row {
            display: grid;
            grid-template-columns: 112px minmax(0, 1fr);
            gap: 14px;
            margin-bottom: 12px;
            padding: 10px;
        }
        .card-image {
            display: block;
            background: var(--panel-2);
            border: 1px solid transparent;
            aspect-ratio: 4 / 3;
        }
        .card-image:hover, .card-image:focus-visible {
            border-color: var(--accent);
        }
        .card-row .card-image { aspect-ratio: 1; }
        .card-image img, .detail-image img {
            width: 100%;
            height: 100%;
            object-fit: contain;
            display: block;
        }
        .card-body { padding: 12px; min-width: 0; }
        .card-body h2 a { text-decoration: none; }
        .card-body h2 a:hover, .card-body h2 a:focus-visible { text-decoration: underline; }
        .badge {
            display: inline-block;
            margin-bottom: 8px;
            color: var(--accent);
            font-weight: 700;
        }
        .back { display: inline-block; margin-bottom: 14px; color: var(--muted); }
        .card-html {
            margin-top: 18px;
            line-height: 1.5;
        }
        .detail-image {
            margin-top: 22px;
            background: var(--panel-2);
            border: 1px solid var(--border);
            border-radius: 8px;
            max-height: 70vh;
            overflow: hidden;
        }
        @media (max-width: 760px) {
            .topbar, .browser-header, .prefs, nav { flex-wrap: wrap; }
            .browser-shell { grid-template-columns: 1fr; }
            .levels { border-right: 0; border-bottom: 1px solid var(--border); max-height: 180px; }
            .toolbar { grid-template-columns: 1fr 1fr; }
            .toolbar input { grid-column: 1 / -1; }
        }
        """;
}

/// <summary>
/// Пользовательские настройки сайта из cookies
/// </summary>
public sealed record SitePreferences(string Language, string Theme);

/// <summary>
/// Запрос сохранения пользовательских настроек сайта
/// </summary>
public sealed record SitePreferencesRequest(string? Language, string? Theme);
