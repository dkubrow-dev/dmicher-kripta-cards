import { DEFAULT_UI_PREFS, MODULE_ID, SETTINGS } from "../constants.js";
import { localize } from "./lang.js";

function normalizeBindingRecord(binding) {
  if (!binding) return null;

  const guid =
    binding.guid ??
    binding.playerGuid ??
    binding.id ??
    binding.Guid ??
    binding.PlayerGuid ??
    binding.Id ??
    "";

  return {
    guid: String(guid ?? "").trim(),
    playerGuid: String(guid ?? "").trim(),
    id: String(guid ?? "").trim(),
    name: String(binding.name ?? binding.Name ?? ""),
    comment: String(binding.comment ?? binding.Comment ?? "")
  };
}

export function getServerUrl() {
  const value = game.settings.get(MODULE_ID, SETTINGS.SERVER_URL) ?? "";
  return String(value).trim().replace(/\/+$/, "");
}

export async function setServerUrl(value) {
  return game.settings.set(MODULE_ID, SETTINGS.SERVER_URL, String(value ?? "").trim());
}

export function getTechUsers() {
  return foundry.utils.deepClone(
    game.settings.get(MODULE_ID, SETTINGS.TECH_AUTH_USERS) ?? {
      writer: { id: "", key: "" },
      reader: { id: "", key: "" }
    }
  );
}

export async function setTechUsers(value) {
  return game.settings.set(MODULE_ID, SETTINGS.TECH_AUTH_USERS, value);
}

export function getBindings() {
  return foundry.utils.deepClone(
    game.settings.get(MODULE_ID, SETTINGS.PLAYER_BINDINGS) ?? {}
  );
}

export async function setBinding(foundryUserId, playerInfo) {
  const bindings = getBindings();
  bindings[foundryUserId] = normalizeBindingRecord({
    guid: playerInfo?.guid ?? playerInfo?.playerGuid ?? playerInfo?.id ?? "",
    name: playerInfo?.name ?? "",
    comment: playerInfo?.comment ?? ""
  });
  return game.settings.set(MODULE_ID, SETTINGS.PLAYER_BINDINGS, bindings);
}

export async function clearBinding(foundryUserId) {
  const bindings = getBindings();
  delete bindings[foundryUserId];
  return game.settings.set(MODULE_ID, SETTINGS.PLAYER_BINDINGS, bindings);
}

export function getBinding(foundryUserId) {
  const bindings = getBindings();
  return normalizeBindingRecord(bindings[foundryUserId] ?? null);
}

export function getCurrentUserBinding() {
  return getBinding(game.user.id);
}

export function getUiPrefs() {
  return foundry.utils.mergeObject(
    DEFAULT_UI_PREFS,
    game.settings.get(MODULE_ID, SETTINGS.UI_PREFS) ?? {}
  );
}

export async function setUiPref(key, value) {
  const prefs = getUiPrefs();
  prefs[key] = value;
  return game.settings.set(MODULE_ID, SETTINGS.UI_PREFS, prefs);
}

export function notifyInfo(message) {
  ui.notifications?.info(message);
}

export function notifyWarn(message) {
  ui.notifications?.warn(message);
}

function isTechnicalErrorMessage(message) {
  return (
    /^api\s+\d+\s*:/i.test(message) ||
    /Failed to fetch/i.test(message) ||
    /NetworkError/i.test(message) ||
    /Load failed/i.test(message) ||
    /ERR_[A-Z_]+/i.test(message)
  );
}

export function notifyError(error, fallback = localize("Error.Generic")) {
  console.error(error);
  const message = error?.message || error?.toString?.() || fallback;
  const useFallback = error?.isApiError || error?.name === "KriptaApiError" || isTechnicalErrorMessage(message);
  ui.notifications?.error(useFallback ? fallback : message);
}

export function escapeHtml(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

export function getRollModeForUser(_user = game.user) {
  return game.settings.get("core", "rollMode") ?? CONST.DICE_ROLL_MODES.PUBLIC;
}

export function buildWhisperRecipients(speakerUser = game.user) {
  const gmRecipients = ChatMessage.getWhisperRecipients("GM") ?? [];
  const result = new Map(gmRecipients.map((user) => [user.id, user]));
  if (speakerUser) result.set(speakerUser.id, speakerUser);
  return [...result.keys()];
}

export function getFoundryUsersForBinding() {
  return [...game.users].map((user) => ({
    id: user.id,
    name: user.name,
    isGM: user.isGM,
    active: user.active
  }));
}

export function objectWithoutUndefined(source) {
  return Object.fromEntries(
    Object.entries(source).filter(([, value]) => value !== undefined && value !== null && value !== "")
  );
}
