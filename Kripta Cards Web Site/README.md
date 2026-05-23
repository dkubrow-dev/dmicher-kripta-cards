# Kripta Cards Web Site

Static bilingual website for Kripta Cards downloads, documentation, and AI policy notes.

## Development

```powershell
npm.cmd run build
npm.cmd run serve
```

The build output is written to `dist/`. The website has no runtime dependencies after build and can be served by IIS as static files.

## Content Model

- `src/site-data.mjs` contains locales, repositories, release catalogs, AI status labels, and storage metadata.
- `src/pages.mjs` contains localized page copy and page composition.
- `src/styles/main.css` contains both dark and light themes.
- `src/client/settings.js` handles the long-lived `settings` cookie for locale and theme.
- `public/files/` is the local download storage root for now.

Before production deployment, set `config.origin` in `src/site-data.mjs` to the public domain.
