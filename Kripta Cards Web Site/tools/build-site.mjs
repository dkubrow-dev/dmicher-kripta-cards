import { copyFile, mkdir, readdir, readFile, rm, stat, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { aiStatuses, catalogs, config } from "../src/site-data.mjs";
import { navigation, pages, ui } from "../src/pages.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const rootDir = path.resolve(__dirname, "..");
const distDir = path.join(rootDir, "dist");
const publicDir = path.join(rootDir, "public");

await rm(distDir, { recursive: true, force: true });
await mkdir(distDir, { recursive: true });
await copyPublic(publicDir, distDir);
await copySourceAssets();

const pageMap = new Map(pages.map((page) => [page.slug, page]));
const locales = config.locales.map((locale) => locale.code);

for (const locale of locales) {
  for (const page of pages) {
    await writePage(locale, page);
  }
  await writeLocalized404(locale);
}

await writeRootIndex();
await writeRoot404();
await writeRobots();
await writeSitemap();

console.log(`Built ${pages.length * locales.length + locales.length + 3} files into ${distDir}`);

async function writePage(locale, page) {
  const html = renderLayout(locale, page, page.render(locale, helpers(locale, page)));
  const outDir = page.slug ? path.join(distDir, locale, ...page.slug.split("/")) : path.join(distDir, locale);
  await mkdir(outDir, { recursive: true });
  await writeFile(path.join(outDir, "index.html"), html, "utf8");
}

async function writeLocalized404(locale) {
  const page = {
    slug: "404",
    title: { [locale]: ui[locale].pageNotFoundTitle },
    description: { [locale]: ui[locale].pageNotFoundText }
  };
  const body = `
    <section class="page-intro">
      <h1>${escapeHtml(ui[locale].pageNotFoundTitle)}</h1>
      <p>${escapeHtml(ui[locale].pageNotFoundText)}</p>
      <div class="hero-actions">
        ${helpers(locale, page).linkButton(`/${locale}/`, locale === "ru" ? "На главную" : "Home")}
        ${helpers(locale, page).linkButton(`/${locale}/downloads/`, ui[locale].allDownloads, "secondary")}
      </div>
    </section>
  `;
  const outDir = path.join(distDir, locale);
  await writeFile(path.join(outDir, "404.html"), renderLayout(locale, page, body, { noIndex: true }), "utf8");
}

async function writeRootIndex() {
  const html = `<!doctype html>
<html lang="en" data-theme="dark">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="robots" content="noindex">
  <title>Kripta Cards</title>
  <script>
    (function () {
      var locale = "en";
      var raw = document.cookie.split(";").map(function (item) { return item.trim(); }).find(function (item) { return item.indexOf("settings=") === 0; });
      if (raw) {
        try {
          var parsed = JSON.parse(decodeURIComponent(raw.slice("settings=".length)));
          if (parsed.locale === "ru" || parsed.locale === "en") locale = parsed.locale;
        } catch (error) {}
      }
      window.location.replace("/" + locale + "/" + window.location.search + window.location.hash);
    })();
  </script>
  <meta http-equiv="refresh" content="0; url=/en/">
</head>
<body>
  <p><a href="/en/">Open Kripta Cards</a></p>
</body>
</html>`;
  await writeFile(path.join(distDir, "index.html"), html, "utf8");
}

async function writeRoot404() {
  const html = `<!doctype html>
<html lang="en" data-theme="dark">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="robots" content="noindex">
  <title>Page not found - Kripta Cards</title>
  <script>
    (function () {
      var locale = window.location.pathname.indexOf("/ru/") === 0 ? "ru" : "en";
      window.location.replace("/" + locale + "/404.html");
    })();
  </script>
</head>
<body>
  <p><a href="/en/404.html">Page not found</a></p>
</body>
</html>`;
  await writeFile(path.join(distDir, "404.html"), html, "utf8");
}

async function writeRobots() {
  const robots = `User-agent: *
Allow: /
Disallow: /files/

Sitemap: ${config.origin}/sitemap.xml
`;
  await writeFile(path.join(distDir, "robots.txt"), robots, "utf8");
}

async function writeSitemap() {
  const urls = [];
  for (const page of pages) {
    for (const locale of locales) {
      urls.push(`  <url>
    <loc>${absoluteUrl(locale, page.slug)}</loc>
    ${locales.map((altLocale) => `<xhtml:link rel="alternate" hreflang="${altLocale}" href="${absoluteUrl(altLocale, page.slug)}" />`).join("\n    ")}
    <xhtml:link rel="alternate" hreflang="x-default" href="${absoluteUrl(config.defaultLocale, page.slug)}" />
  </url>`);
    }
  }

  const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">
${urls.join("\n")}
</urlset>
`;
  await writeFile(path.join(distDir, "sitemap.xml"), sitemap, "utf8");
}

function renderLayout(locale, page, content, options = {}) {
  const t = ui[locale];
  const title = textFor(page.title, locale);
  const description = textFor(page.description, locale);
  const canonical = absoluteUrl(locale, page.slug);
  const alternateLinks = locales.map((altLocale) => {
    return `<link rel="alternate" hreflang="${altLocale}" href="${absoluteUrl(altLocale, page.slug)}">`;
  }).join("\n  ");

  return `<!doctype html>
<html lang="${locale}" data-theme="${config.defaultTheme}">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  ${options.noIndex ? '<meta name="robots" content="noindex">' : '<meta name="robots" content="index, follow">'}
  <title>${escapeHtml(title)} - ${escapeHtml(config.siteName[locale])}</title>
  <meta name="description" content="${escapeHtml(description)}">
  <link rel="canonical" href="${canonical}">
  ${alternateLinks}
  <link rel="alternate" hreflang="x-default" href="${absoluteUrl(config.defaultLocale, page.slug)}">
  <link rel="icon" href="/assets/favicon.svg" type="image/svg+xml">
  <link rel="stylesheet" href="/assets/main.css">
  <script>
    (function () {
      var theme = "dark";
      var raw = document.cookie.split(";").map(function (item) { return item.trim(); }).find(function (item) { return item.indexOf("settings=") === 0; });
      if (raw) {
        try {
          var parsed = JSON.parse(decodeURIComponent(raw.slice("settings=".length)));
          if (parsed.theme === "light" || parsed.theme === "dark") theme = parsed.theme;
        } catch (error) {}
      }
      document.documentElement.dataset.theme = theme;
    })();
  </script>
</head>
<body>
  <a class="skip-link" href="#content">${escapeHtml(t.skip)}</a>
  ${renderHeader(locale, page)}
  <main id="content">
    ${content}
  </main>
  ${renderFooter(locale)}
  <script src="/assets/settings.js" defer></script>
</body>
</html>`;
}

function renderHeader(locale, page) {
  const t = ui[locale];
  const currentTop = page.slug.split("/")[0] || "";
  const labels = escapeHtml(JSON.stringify({ dark: t.dark, light: t.light, switchTheme: t.switchTheme }));

  return `<header class="site-header">
    <div class="header-inner">
      <a class="brand" href="/${locale}/" aria-label="${escapeHtml(config.siteName[locale])}">
        <span class="brand-mark" aria-hidden="true">KC</span>
        <span class="brand-text">${escapeHtml(config.siteName[locale])}</span>
      </a>
      <nav class="nav" aria-label="${escapeHtml(t.mainNavigation)}">
        ${navigation[locale].map((item) => {
          const targetTop = item.href.replace(`/${locale}/`, "").split("/")[0] || "";
          const current = targetTop === currentTop ? ' aria-current="page"' : "";
          return `<a href="${item.href}"${current}>${escapeHtml(item.label)}</a>`;
        }).join("")}
      </nav>
      <div class="site-controls">
        <label>
          <span class="sr-only">${escapeHtml(t.language)}</span>
          <select class="control" data-locale-switcher aria-label="${escapeHtml(t.language)}">
            ${config.locales.map((item) => `<option value="${item.code}"${item.code === locale ? " selected" : ""}>${escapeHtml(item.shortLabel)}</option>`).join("")}
          </select>
        </label>
        <button class="theme-toggle" type="button" data-theme-toggle data-labels="${labels}">${escapeHtml(t.dark)}</button>
      </div>
    </div>
  </header>`;
}

function renderFooter(locale) {
  return `<footer class="site-footer">
    <div class="footer-inner">
      <span>${escapeHtml(config.siteName[locale])}</span>
      <span><a href="/${locale}/ai-policy/">${escapeHtml(navigation[locale].find((item) => item.href.endsWith("/ai-policy/")).label)}</a></span>
    </div>
  </footer>`;
}

function helpers(locale, page) {
  const t = ui[locale];
  return {
    ui: t,
    linkButton(href, label, variant = "") {
      return `<a class="button ${variant}" href="${href}">${escapeHtml(label)}</a>`;
    },
    pageIntro(title, text) {
      return `<section class="page-intro"><h1>${escapeHtml(title)}</h1><p>${escapeHtml(text)}</p></section>`;
    },
    cardGrid(cards) {
      return `<div class="card-grid">${cards.map((card) => `<a class="card" href="${card.href}"><h2>${escapeHtml(card.title)}</h2><p>${escapeHtml(card.text)}</p></a>`).join("")}</div>`;
    },
    linkList(links) {
      return `<ul class="link-list">${links.map((link) => `<li><a href="${link.href}">${escapeHtml(link.label)}</a></li>`).join("")}</ul>`;
    },
    serverReleaseTable(items) {
      return table([
        t.version,
        t.status,
        t.compatibility,
        t.file,
        t.size,
        t.sha256,
        t.notes
      ], items.map((item) => [
        escapeHtml(item.version),
        statusBadge(item.status, locale),
        escapeHtml(`Module ${item.moduleCompatibility}; Foundry ${item.foundryCompatibility}`),
        fileLinks(item.files, locale, item.status),
        escapeHtml(item.files.map((file) => file.size).join(", ")),
        checksum(item.files.map((file) => file.sha256).join(", ")),
        escapeHtml(item.notes[locale])
      ]));
    },
    moduleReleaseTable(items) {
      return table([
        t.version,
        t.status,
        t.aiStatus,
        "Manifest",
        "Foundry",
        t.notes
      ], items.map((item) => [
        escapeHtml(item.version),
        statusBadge(item.status, locale),
        aiBadge(item.aiStatus, locale),
        `<a href="${item.manifestUrl}">module.json</a>`,
        `<a href="${item.foundryUrl}">${config.foundry.packageId}</a>`,
        escapeHtml(item.notes[locale])
      ]));
    },
    languagePatchTable(items) {
      return table([
        t.language,
        t.status,
        t.compatibility,
        t.aiStatus,
        t.bat,
        t.sh,
        t.sha256
      ], items.map((item) => [
        `${escapeHtml(item.languageName)} <span class="checksum">${escapeHtml(item.locale)}</span>`,
        statusBadge(item.status, locale),
        escapeHtml(item.moduleCompatibility),
        aiBadge(item.aiStatus, locale),
        plannedFileLink(item.batHref, item.status, locale, "bat"),
        plannedFileLink(item.shHref, item.status, locale, "sh"),
        checksum(item.sha256)
      ]));
    },
    contentPackTable(items) {
      return table([
        "ID",
        t.status,
        t.compatibility,
        t.aiStatus,
        t.file,
        t.size,
        t.sha256,
        t.notes
      ], items.map((item) => [
        escapeHtml(item.id),
        statusBadge(item.status, locale),
        escapeHtml(item.serverCompatibility),
        aiBadge(item.aiStatus, locale),
        plannedFileLink(item.href, item.status, locale, item.title),
        escapeHtml(item.size),
        checksum(item.sha256),
        escapeHtml(item.notes[locale])
      ]));
    },
    aiStatusList() {
      return `<dl class="status-list">${Object.entries(aiStatuses).map(([key, item]) => `<div><dt>${escapeHtml(item[locale].label)}</dt><dd>${escapeHtml(item[locale].description)} <span class="checksum">${escapeHtml(key)}</span></dd></div>`).join("")}</dl>`;
    },
    steps(items) {
      return `<section class="page-intro"><h1>${escapeHtml(textFor(page.title, locale))}</h1><p>${escapeHtml(textFor(page.description, locale))}</p></section><ol class="steps">${items.map((item) => `<li>${escapeHtml(item)}</li>`).join("")}</ol>`;
    },
    checkList(items) {
      return `<ul class="checks">${items.map((item) => `<li>${escapeHtml(item)}</li>`).join("")}</ul>`;
    }
  };
}

function table(headers, rows) {
  return `<div class="table-wrap"><table><thead><tr>${headers.map((header) => `<th>${escapeHtml(header)}</th>`).join("")}</tr></thead><tbody>${rows.map((row) => `<tr>${row.map((cell) => `<td>${cell}</td>`).join("")}</tr>`).join("")}</tbody></table></div>`;
}

function statusBadge(status, locale) {
  const label = ui[locale][status] || status;
  return `<span class="status ${escapeHtml(status)}">${escapeHtml(label)}</span>`;
}

function aiBadge(status, locale) {
  const item = aiStatuses[status];
  return `<span class="status">${escapeHtml(item ? item[locale].label : status)}</span>`;
}

function fileLinks(files, locale, status) {
  return files.map((file) => plannedFileLink(file.href, status, locale, file.label)).join("<br>");
}

function plannedFileLink(href, status, locale, label) {
  if (status !== "published") {
    return `<span title="${escapeHtml(href)}">${escapeHtml(ui[locale].unavailable)}</span>`;
  }
  return `<a href="${href}">${escapeHtml(label)}</a>`;
}

function checksum(value) {
  return `<span class="checksum">${escapeHtml(value)}</span>`;
}

function textFor(value, locale) {
  if (typeof value === "string") {
    return value;
  }
  return value[locale] ?? value[config.defaultLocale] ?? "";
}

function absoluteUrl(locale, slug) {
  const local = `/${locale}/${slug ? `${slug}/` : ""}`;
  return `${config.origin}${local}`;
}

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

async function copyPublic(from, to) {
  try {
    await stat(from);
  } catch {
    return;
  }

  await mkdir(to, { recursive: true });
  const entries = await readdir(from, { withFileTypes: true });
  for (const entry of entries) {
    const source = path.join(from, entry.name);
    const target = path.join(to, entry.name);
    if (entry.isDirectory()) {
      await copyPublic(source, target);
    } else {
      await copyFile(source, target);
    }
  }
}

async function copySourceAssets() {
  const assetsDir = path.join(distDir, "assets");
  await mkdir(assetsDir, { recursive: true });
  await copyFile(path.join(rootDir, "src", "styles", "main.css"), path.join(assetsDir, "main.css"));
  await copyFile(path.join(rootDir, "src", "client", "settings.js"), path.join(assetsDir, "settings.js"));
}
