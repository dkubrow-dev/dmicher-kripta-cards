const ROOT_KEY = "KRIPTA";

function buildKey(key) {
  const raw = String(key ?? "").trim();
  if (!raw) return ROOT_KEY;
  return raw.startsWith(`${ROOT_KEY}.`) ? raw : `${ROOT_KEY}.${raw}`;
}

function fallbackFormat(template, data = {}) {
  return String(template ?? "").replace(/\{([^}]+)\}/g, (_match, token) => {
    const key = String(token ?? "").trim();
    return data[key] ?? "";
  });
}

export function localize(key) {
  const fullKey = buildKey(key);
  return globalThis.game?.i18n?.localize?.(fullKey) ?? fullKey;
}

export function format(key, data = {}) {
  const fullKey = buildKey(key);

  if (typeof globalThis.game?.i18n?.format === "function") {
    return globalThis.game.i18n.format(fullKey, data);
  }

  return fallbackFormat(localize(fullKey), data);
}

export function formatCardNameFallback(number) {
  return format("Card.FallbackName", { number });
}

export function formatCardAddressFallback(level, number) {
  return format("Card.FallbackAddress", { level, number });
}

export function formatMissingCardDescription(level, number) {
  return format("Card.MissingDescription", { level, number });
}

export function formatMissingLevelName(level) {
  return format("Level.FallbackName", { level });
}

export function formatCardReceiveSubtitle(playerName, cardSubtitle) {
  return format("Chat.CardReceiveSubtitle", { playerName, cardSubtitle });
}
