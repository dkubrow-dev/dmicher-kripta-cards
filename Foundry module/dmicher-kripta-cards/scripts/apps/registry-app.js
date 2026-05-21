import { KriptaApiClient } from "../api/client.js";
import { MODULE_ID, TEMPLATE_ROOT } from "../constants.js";
import { addEditPlayerDialog, deletePlayerDialog } from "./dialogs.js";
import { localize } from "../helpers/lang.js";
import { notifyError, notifyInfo } from "../helpers/utils.js";

const WINDOW_MIN_WIDTH = 450;

function compareRu(a, b) {
  return String(a ?? "").localeCompare(String(b ?? ""), "ru", {
    sensitivity: "base"
  });
}

function sortPlayers(players) {
  return [...players].sort((left, right) => {
    const byName = compareRu(left?.name, right?.name);
    if (byName !== 0) return byName;
    return compareRu(left?.comment, right?.comment);
  });
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function fetchPlayersUntilDeleted(guid, attempts = 5, delayMs = 250) {
  let freshPlayers = [];

  for (let index = 0; index < attempts; index += 1) {
    freshPlayers = sortPlayers(await KriptaApiClient.getPlayersList());

    if (!freshPlayers.some((item) => item.guid === guid)) {
      return freshPlayers;
    }

    if (index < attempts - 1) {
      await sleep(delayMs);
    }
  }

  return freshPlayers;
}

function extractJsonTail(text) {
  const raw = String(text ?? "").trim();
  if (!raw) return null;

  try {
    return JSON.parse(raw);
  } catch (_error) {
    // ignore
  }

  const match = raw.match(/(\{.*\})$/);
  if (!match) return null;

  try {
    return JSON.parse(match[1]);
  } catch (_error) {
    return null;
  }
}

function normalizeRegistryError(error, fallback) {
  const rawMessage = String(error?.message ?? error ?? "").trim();
  if (!rawMessage) return fallback;

  const apiMatch = rawMessage.match(/^api\s+(\d+)\s*:\s*(.*)$/i);
  const status = apiMatch?.[1] ?? "";
  const tail = apiMatch?.[2] ?? rawMessage;
  const parsed = extractJsonTail(tail);

  if (parsed?.errors && typeof parsed.errors === "object") {
    const firstField = Object.keys(parsed.errors)[0];
    const firstValue = parsed.errors[firstField];

    if (Array.isArray(firstValue) && firstValue.length) {
      return status ? `api ${status}: ${firstValue[0]}` : String(firstValue[0]);
    }

    if (typeof firstValue === "string" && firstValue.trim()) {
      return status ? `api ${status}: ${firstValue.trim()}` : firstValue.trim();
    }
  }

  if (parsed?.message && String(parsed.message).trim()) {
    return status ? `api ${status}: ${String(parsed.message).trim()}` : String(parsed.message).trim();
  }

  if (parsed?.title && String(parsed.title).trim()) {
    return status ? `api ${status}: ${String(parsed.title).trim()}` : String(parsed.title).trim();
  }

  return rawMessage || fallback;
}

function validatePlayerPayload(payload) {
  const name = String(payload?.name ?? "").trim();
  if (!name) return localize("Error.NameRequired");
  return "";
}

export class KriptaPlayerRegistryApp extends Application {
  constructor(options = {}) {
    super(options);
    this.players = [];
    this.selectedGuid = null;
    this.onChange = options.onChange ?? (() => { });
  }

  static get defaultOptions() {
    return foundry.utils.mergeObject(super.defaultOptions, {
      id: `${MODULE_ID}-registry`,
      title: localize("Window.Registry"),
      template: `${TEMPLATE_ROOT}/registry-app.hbs`,
      classes: [MODULE_ID, "sheet"],
      width: 760,
      height: 640,
      minWidth: WINDOW_MIN_WIDTH,
      resizable: true
    });
  }

  static get defaultOptions() {
    return foundry.utils.mergeObject(super.defaultOptions, {
      id: `${MODULE_ID}-registry`,
      title: localize("Window.Registry"),
      template: `${TEMPLATE_ROOT}/registry-app.hbs`,
      classes: [MODULE_ID, "sheet"],
      width: 760,
      height: 640,
      minWidth: WINDOW_MIN_WIDTH,
      resizable: true
    });
  }
  async getData() {
    const previousSelectedGuid = this.selectedGuid;
    this.players = sortPlayers(await KriptaApiClient.getPlayersList());

    if (previousSelectedGuid && this.players.some((player) => player.guid === previousSelectedGuid)) {
      this.selectedGuid = previousSelectedGuid;
    } else if (this.players.length) {
      this.selectedGuid = this.players[0].guid;
    } else {
      this.selectedGuid = null;
    }

    return {
      players: this.players.map((player) => ({
        ...player,
        isSelected: player.guid === this.selectedGuid
      })),
      hasPlayers: this.players.length > 0
    };
  }

  activateListeners(html) {
    super.activateListeners(html);
    this._applySelectionStyles(html);

    html.find("[data-player-guid]").on("click", (event) => {
      const nextGuid = String(event.currentTarget.dataset.playerGuid ?? "").trim();
      if (!nextGuid || nextGuid === this.selectedGuid) return;

      this.selectedGuid = nextGuid;
      this._applySelectionStyles(html);
    });

    html.find("[data-player-guid]").on("dblclick", (event) => {
      const button = event.button ?? event.originalEvent?.button ?? 0;
      if (button !== 0) return;

      const nextGuid = String(event.currentTarget.dataset.playerGuid ?? "").trim();
      if (!nextGuid) return;

      this.selectedGuid = nextGuid;
      this._applySelectionStyles(html);
      html.find('[data-action="edit"]').trigger("click");
    });

    html.find('[data-action="refresh"]').on("click", () => this.render());

    html.find('[data-action="add"]').on("click", async () => {
      const dialogResult = await addEditPlayerDialog();
      if (dialogResult?.action !== "confirm") return;

      const payload = {
        name: dialogResult.name,
        comment: dialogResult.comment
      };

      const validationMessage = validatePlayerPayload(payload);
      if (validationMessage) {
        ui.notifications.error(validationMessage);
        console.error(validationMessage);
        return;
      }

      try {
        await KriptaApiClient.addPlayer(payload.name, payload.comment);
        notifyInfo(localize("Notification.PlayerAdded"));
        this.onChange();
        this.render();
      } catch (error) {
        const message = normalizeRegistryError(error, localize("Notification.PlayerAddFailed"));
        ui.notifications.error(message);
        console.error(error);
      }
    });

    html.find('[data-action="edit"]').on("click", async () => {
      const player = this.players.find((item) => item.guid === this.selectedGuid);
      if (!player) return;

      const dialogResult = await addEditPlayerDialog(player);
      if (dialogResult?.action !== "confirm") return;

      const payload = {
        name: dialogResult.name,
        comment: dialogResult.comment
      };

      const validationMessage = validatePlayerPayload(payload);
      if (validationMessage) {
        ui.notifications.error(validationMessage);
        console.error(validationMessage);
        return;
      }

      try {
        await KriptaApiClient.updatePlayer(player.guid, payload.name, payload.comment);
        this.selectedGuid = player.guid;
        notifyInfo(localize("Notification.PlayerUpdated"));
        this.onChange();
        this.render();
      } catch (error) {
        const message = normalizeRegistryError(error, localize("Notification.PlayerUpdateFailed"));
        ui.notifications.error(message);
        console.error(error);
      }
    });

    html.find('[data-action="delete"]').on("click", async () => {
      const player = this.players.find((item) => item.guid === this.selectedGuid);
      if (!player) return;

      const deleteDecision = await deletePlayerDialog(player);

      if (!deleteDecision?.valid) {
        if (deleteDecision?.action === "confirm") {
          ui.notifications.error(localize("Notification.DeleteCanceledBadCode"));
        }
        return;
      }
      try {
        await KriptaApiClient.deletePlayer(player.guid);

        const freshPlayers = await fetchPlayersUntilDeleted(player.guid);

        if (freshPlayers.some((item) => item.guid === player.guid)) {
          throw new Error(localize("Error.RegistryDeleteReturned"));
        }

        this.players = freshPlayers;
        this.selectedGuid = this.players[0]?.guid ?? null;

        notifyInfo(localize("Notification.PlayerDeleted"));

        await this.onChange();
        await this.render(true);
      } catch (error) {
        notifyError(error, localize("Notification.PlayerDeleteFailed"));
      }
    });
  }

  _applySelectionStyles(html) {
    const rows = html.find("[data-player-guid]").toArray();

    for (const row of rows) {
      const isSelected = String(row.dataset.playerGuid ?? "") === String(this.selectedGuid ?? "");
      row.classList.toggle("is-selected", isSelected);

      const cells = row.querySelectorAll("td");

      for (let index = 0; index < cells.length; index += 1) {
        const cell = cells[index];

        if (isSelected) {
          cell.style.setProperty("background-color", "rgba(226, 170, 77, 0.28)", "important");
          cell.style.setProperty("border-top", "2px solid #d49a43", "important");
          cell.style.setProperty("border-bottom", "2px solid #d49a43", "important");
          cell.style.setProperty("border-left", index === 0 ? "2px solid #d49a43" : "0", "important");
          cell.style.setProperty("border-right", index === cells.length - 1 ? "2px solid #d49a43" : "0", "important");
        } else {
          cell.style.removeProperty("background-color");
          cell.style.removeProperty("border-top");
          cell.style.removeProperty("border-bottom");
          cell.style.removeProperty("border-left");
          cell.style.removeProperty("border-right");
        }
      }
    }
  }
}
