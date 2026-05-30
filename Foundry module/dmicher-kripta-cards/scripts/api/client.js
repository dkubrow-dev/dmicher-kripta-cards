import { ROLES } from "../constants.js";
import { format, localize } from "../helpers/lang.js";
import { getServerUrl, getTechUsers, objectWithoutUndefined } from "../helpers/utils.js";
import {
  normalizeCardMeta,
  normalizeCardsList,
  normalizeLevels,
  normalizePlayersInfo,
  normalizePlayersList,
  normalizeRollCard
} from "./normalizers.js";

function assertValidCardAddress(level, number, context = "card request") {
  const normalizedLevel = Number(level);
  const normalizedNumber = Number(number);

  if (!Number.isInteger(normalizedLevel) || normalizedLevel < 0) {
    throw new Error(format("Error.InvalidCardLevel", { context, level }));
  }

  if (!Number.isInteger(normalizedNumber) || normalizedNumber < 0) {
    throw new Error(format("Error.InvalidCardNumber", { context, number }));
  }

  return {
    level: normalizedLevel,
    number: normalizedNumber
  };
}

function createApiError(response, details) {
  const error = new Error(localize("Error.Generic"));
  error.name = "KriptaApiError";
  error.isApiError = true;
  error.status = response.status;
  error.statusText = response.statusText;
  error.details = details;
  return error;
}

export class KriptaApiClient {
  static buildHeaders(role, extra = {}, { useAuth = true } = {}) {
    const headers = {
      Accept: "application/json, text/plain, */*",
      "Content-Type": "application/json",
      ...extra
    };

    if (!useAuth) return objectWithoutUndefined(headers);

    const users = getTechUsers();
    const auth = users?.[role] ?? { id: "", key: "" };
    const basic = auth.id || auth.key ? btoa(`${auth.id}:${auth.key}`) : "";

    return objectWithoutUndefined({
      ...headers,
      Authorization: basic ? `Basic ${basic}` : "",
      Id: auth.id ?? "",
      Key: auth.key ?? "",
      "X-Api-Id": auth.id ?? "",
      "X-Api-Key": auth.key ?? "",
      "X-Auth-Id": auth.id ?? "",
      "X-Auth-Key": auth.key ?? "",
      "X-User-Id": auth.id ?? "",
      "X-User-Key": auth.key ?? ""
    });
  }

  static buildUrl(path, query = null) {
    const base = getServerUrl();
    const url = new URL(path, `${base}/`);

    if (query) {
      for (const [key, value] of Object.entries(query)) {
        if (value === undefined || value === null || value === "") continue;
        if (Array.isArray(value)) value.forEach((item) => url.searchParams.append(key, item));
        else url.searchParams.set(key, value);
      }
    }

    return url.toString();
  }

  static async request(role, path, { method = "GET", body, query, binary = false, headers = {}, useAuth = true, cacheMode = "no-store" } = {}) {
    const response = await fetch(this.buildUrl(path, query), {
      method,
      mode: "cors",
      cache: cacheMode,
      headers: this.buildHeaders(role, headers, { useAuth }),
      body: body !== undefined ? JSON.stringify(body) : undefined
    });

    if (!response.ok) {
      let details = "";
      try {
        details = await response.text();
      } catch (_error) {}
      throw createApiError(response, details);
    }

    if (binary) return response.blob();
    if (response.status === 204) return null;

    const contentType = response.headers.get("content-type") ?? "";
    if (contentType.includes("application/json") || contentType.includes("text/json")) {
      return response.json();
    }

    const text = await response.text();
    try {
      return JSON.parse(text);
    } catch (_error) {
      return text;
    }
  }

  static async healthCheck() {
    return this.request(ROLES.READER, "/api/Health/check", {
      method: "GET",
      headers: { "Content-Type": undefined },
      useAuth: false
    });
  }

  static async checkMe() {
    return this.request(ROLES.READER, "/api/Health/check-me", {
      method: "GET",
      headers: { "Content-Type": undefined }
    });
  }

  static async getLevelsList() {
    const raw = await this.request(ROLES.READER, "/api/Cards/getLevelsList", {
      method: "GET",
      headers: { "Content-Type": undefined }
    });


    const normalized = normalizeLevels(raw);

    return normalized;
  }

  static async getCardsList(level, search = "") {
    const body = objectWithoutUndefined({
      Level: level,
      level,
      LevelId: level,
      levelId: level,
      Search: search,
      search,
      Query: search,
      query: search,
      Name: search,
      name: search
    });

    const raw = await this.request(ROLES.READER, "/api/Cards/getCardsList", {
      method: "POST",
      body
    });


    const normalized = normalizeCardsList(raw, level);

    return normalized;
  }

  static async getCardMeta(level, number) {
    const addr = assertValidCardAddress(level, number, "getCardMeta");

    const raw = await this.request(ROLES.READER, `/api/Cards/getCardMeta/${addr.level}/${addr.number}`, {
      method: "GET",
      headers: { "Content-Type": undefined }
    });


    const normalized = normalizeCardMeta(raw, addr);

    return normalized;
  }

  static buildCardImagePath(imagePath) {
      return String(imagePath ?? "")
          .replace(/\\/g, "/")
          .replace(/^\/+/, "")
          .split("/")
          .map(encodeURIComponent)
          .join("/");
  }

  static async getCardImageBlob(imagePath) {
      return this.request(ROLES.READER, `/api/Cards/getCardImage/${this.buildCardImagePath(imagePath)}`, {
          method: "GET",
          cacheMode: "default",
          binary: true,
          headers: { "Content-Type": undefined }
      });
  }

  static async getPlayersList() {
    return normalizePlayersList(
      await this.request(ROLES.WRITER, "/api/PlayersCards/getPlayersList", {
        method: "GET",
        query: {
          _ts: Date.now()
        },
        headers: {
          "Content-Type": undefined,
          "Cache-Control": "no-cache, no-store, must-revalidate",
          Pragma: "no-cache"
        }
      })
    );
  }

  static async getPlayersInfo(guids) {
    const uniqueGuids = [...new Set((Array.isArray(guids) ? guids : [guids]).filter(Boolean))];

    const raw = await this.request(ROLES.READER, "/api/PlayersCards/getPlayersInfo", {
      method: "POST",
      body: uniqueGuids,
      query: {
        players: uniqueGuids
      }
    });


    return normalizePlayersInfo(raw);
  }

  static async addPlayer(name, comment = "", login = "", pin = "") {
    const body = objectWithoutUndefined({
      Name: name,
      name,
      Login: login,
      login,
      Pin: pin,
      pin,
      Comment: comment,
      comment
    });

    return this.request(ROLES.WRITER, "/api/PlayersCards/addPlayer", {
      method: "POST",
      body
    });
  }

  static async updatePlayer(guid, name, comment = "", login = "", pin = "") {
    const query = objectWithoutUndefined({
      Guid: guid,
      guid,
      Id: guid,
      id: guid,
      playerGuid: guid,
      PlayerGuid: guid,
      player: guid,
      Player: guid
    });

    const body = objectWithoutUndefined({
      Name: name,
      name,
      Login: login,
      login,
      Pin: pin,
      pin,
      Comment: comment,
      comment
    });

    return this.request(ROLES.WRITER, "/api/PlayersCards/updatePlayer", {
      method: "POST",
      query,
      body
    });
  }

  static async deletePlayer(guid) {
    const query = objectWithoutUndefined({
      playerId: guid
    });

    return this.request(ROLES.WRITER, "/api/PlayersCards/deletePlayer", {
      method: "DELETE",
      query,
      headers: { "Content-Type": undefined }
    });
  }

  static async getPlayerPin(guid) {
    const query = objectWithoutUndefined({
      playerGuid: guid,
      PlayerGuid: guid,
      guid,
      Guid: guid,
      id: guid,
      Id: guid
    });

    const raw = await this.request(ROLES.WRITER, "/api/PlayersCards/getPlayerPin", {
      method: "GET",
      query,
      headers: { "Content-Type": undefined }
    });

    return String(raw?.pin ?? raw?.Pin ?? "");
  }

  static async updatePlayerPin(guid, pin) {
    const query = objectWithoutUndefined({
      playerGuid: guid,
      PlayerGuid: guid,
      guid,
      Guid: guid,
      id: guid,
      Id: guid
    });

    const body = objectWithoutUndefined({
      Pin: pin,
      pin
    });

    return this.request(ROLES.WRITER, "/api/PlayersCards/updatePlayerPin", {
      method: "POST",
      query,
      body
    });
  }

static async rollCard(level) {
  const normalizedLevel = Number(level);

  const raw = await this.request(ROLES.READER, "/api/PlayersCards/rollCard", {
    method: "POST",
    query: {
      level: normalizedLevel
    },
    headers: { "Content-Type": undefined }
  });


  const normalized = normalizeRollCard(raw, normalizedLevel);

  return normalized;
}

  static async giveCard(playerGuid, level, number, count = 1) {
    const addr = assertValidCardAddress(level, number, "giveCard");

    const query = objectWithoutUndefined({
      player: playerGuid,
      Player: playerGuid,
      guid: playerGuid,
      Guid: playerGuid,
      id: playerGuid,
      Id: playerGuid,
      playerGuid,
      PlayerGuid: playerGuid,
      level: addr.level,
      Level: addr.level,
      card: addr.number,
      Card: addr.number,
      number: addr.number,
      Number: addr.number,
      count,
      Count: count,
      amount: count,
      Amount: count
    });

    return this.request(ROLES.WRITER, "/api/PlayersCards/giveCard", {
      method: "POST",
      query,
      headers: { "Content-Type": undefined }
    });
  }

  static async takeCard(playerGuid, level, number, count = 1) {
    const addr = assertValidCardAddress(level, number, "takeCard");

    const query = objectWithoutUndefined({
      player: playerGuid,
      Player: playerGuid,
      guid: playerGuid,
      Guid: playerGuid,
      id: playerGuid,
      Id: playerGuid,
      playerGuid,
      PlayerGuid: playerGuid,
      level: addr.level,
      Level: addr.level,
      card: addr.number,
      Card: addr.number,
      number: addr.number,
      Number: addr.number,
      count,
      Count: count,
      amount: count,
      Amount: count
    });

    return this.request(ROLES.WRITER, "/api/PlayersCards/takeCard", {
      method: "POST",
      query,
      headers: { "Content-Type": undefined }
    });
  }

  static async testWriterAccess() {
    return this.getPlayersList();
  }
}
