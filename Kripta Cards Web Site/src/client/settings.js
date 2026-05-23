(function () {
  const cookieName = "settings";
  const locales = ["en", "ru"];
  const themes = ["dark", "light"];
  const maxAge = 60 * 60 * 24 * 365 * 10;

  function readCookie() {
    const prefix = cookieName + "=";
    const raw = document.cookie
      .split(";")
      .map((item) => item.trim())
      .find((item) => item.startsWith(prefix));

    if (!raw) {
      return { v: 1, locale: "en", theme: "dark" };
    }

    try {
      const parsed = JSON.parse(decodeURIComponent(raw.slice(prefix.length)));
      return {
        v: 1,
        locale: locales.includes(parsed.locale) ? parsed.locale : "en",
        theme: themes.includes(parsed.theme) ? parsed.theme : "dark"
      };
    } catch {
      return { v: 1, locale: "en", theme: "dark" };
    }
  }

  function writeCookie(settings) {
    const secure = window.location.protocol === "https:" ? "; Secure" : "";
    document.cookie = `${cookieName}=${encodeURIComponent(JSON.stringify(settings))}; Max-Age=${maxAge}; Path=/; SameSite=Lax${secure}`;
  }

  function localeFromPath() {
    const match = window.location.pathname.match(/^\/(en|ru)(\/|$)/);
    return match ? match[1] : null;
  }

  function samePageForLocale(locale) {
    const pathLocale = localeFromPath();
    if (pathLocale) {
      return window.location.pathname.replace(/^\/(en|ru)(?=\/|$)/, `/${locale}`) + window.location.search + window.location.hash;
    }
    return `/${locale}/`;
  }

  function applyTheme(settings) {
    document.documentElement.dataset.theme = settings.theme;
    const themeButton = document.querySelector("[data-theme-toggle]");
    if (themeButton) {
      const labels = JSON.parse(themeButton.getAttribute("data-labels") || "{}");
      const label = settings.theme === "dark" ? labels.dark : labels.light;
      themeButton.textContent = label || settings.theme;
      themeButton.setAttribute("aria-label", labels.switchTheme || "Switch theme");
    }
  }

  function showModuleVersionHint(locale) {
    const panel = document.querySelector("[data-module-context]");
    if (!panel) {
      return;
    }

    const params = new URLSearchParams(window.location.search);
    const version = params.get("moduleVersion") || params.get("module");
    if (!version) {
      return;
    }

    const text = panel.querySelector("[data-module-version-text]");
    if (text) {
      const template = text.textContent || "";
      text.textContent = template.replace("{version}", version);
    }
    panel.hidden = false;
  }

  const settings = readCookie();
  const currentLocale = localeFromPath();
  if (currentLocale) {
    settings.locale = currentLocale;
  }
  writeCookie(settings);
  applyTheme(settings);

  window.addEventListener("DOMContentLoaded", () => {
    const locale = localeFromPath() || settings.locale;
    const localeSelect = document.querySelector("[data-locale-switcher]");
    if (localeSelect) {
      localeSelect.value = locale;
      localeSelect.addEventListener("change", () => {
        const nextLocale = localeSelect.value;
        settings.locale = nextLocale;
        writeCookie(settings);
        window.location.assign(samePageForLocale(nextLocale));
      });
    }

    const themeButton = document.querySelector("[data-theme-toggle]");
    if (themeButton) {
      themeButton.addEventListener("click", () => {
        settings.theme = settings.theme === "dark" ? "light" : "dark";
        writeCookie(settings);
        applyTheme(settings);
      });
    }

    showModuleVersionHint(locale);
  });
})();
