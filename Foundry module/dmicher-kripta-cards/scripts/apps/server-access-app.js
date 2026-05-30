import { KriptaApiClient } from "../api/client.js";
import { MODULE_ID, TEMPLATE_ROOT } from "../constants.js";
import { localize } from "../helpers/lang.js";
import { getServerUrl, notifyError, notifyInfo } from "../helpers/utils.js";
import { changePinDialog, isValidPlayerPin } from "./dialogs.js";

async function copyTextToClipboard(value) {
  const text = String(value ?? "");

  if (navigator.clipboard?.writeText) {
    await navigator.clipboard.writeText(text);
    return;
  }

  const textarea = document.createElement("textarea");
  textarea.value = text;
  textarea.setAttribute("readonly", "readonly");
  textarea.style.position = "fixed";
  textarea.style.left = "-9999px";
  document.body.appendChild(textarea);
  textarea.select();
  document.execCommand("copy");
  textarea.remove();
}

export class KriptaServerAccessApp extends Application {
  constructor(options = {}) {
    super(options);
    this.playerGuid = options.playerGuid;
    this.ownerFoundryUserId = options.ownerFoundryUserId ?? game.user.id;
    this.foundryUserName = options.foundryUserName ?? game.users.get(this.ownerFoundryUserId)?.name ?? game.user.name;
    this.serverPlayer = options.serverPlayer ?? null;
    this.pin = "";
  }

  static get defaultOptions() {
    return foundry.utils.mergeObject(super.defaultOptions, {
      id: `${MODULE_ID}-server-access-${foundry.utils.randomID()}`,
      title: localize("Window.Server"),
      template: `${TEMPLATE_ROOT}/server-access-app.hbs`,
      classes: [MODULE_ID, "sheet"],
      width: 450,
      height: "auto",
      resizable: false
    });
  }

  async getData() {
    const playerGuid = String(this.playerGuid ?? "").trim();
    if (!playerGuid) {
      throw new Error(localize("NoBinding"));
    }

    const players = this.serverPlayer ? null : await KriptaApiClient.getPlayersList();
    this.serverPlayer = this.serverPlayer ?? players.find((player) => String(player.guid ?? "").trim() === playerGuid) ?? null;
    if (!this.serverPlayer) {
      throw new Error(localize("Notification.BoundServerPlayerNotFound"));
    }

    const pin = await KriptaApiClient.getPlayerPin(playerGuid);
    this.pin = pin || this.serverPlayer?.pin || "";

    const serverUrl = getServerUrl();

    return {
      serverUrl,
      hasServerUrl: !!serverUrl,
      foundryUserName: this.foundryUserName,
      serverLogin: this.serverPlayer?.login ?? "",
      serverPlayerName: this.serverPlayer?.name ?? "",
      pin: this.pin
    };
  }

  activateListeners(html) {
    super.activateListeners(html);

    html.find('[data-action="change-pin"]').on("click", async () => {
      const dialogResult = await changePinDialog(this.pin);
      if (dialogResult?.action !== "confirm") return;

      if (!isValidPlayerPin(dialogResult.pin)) {
        ui.notifications.error(localize("Error.PinInvalid"));
        return;
      }

      try {
        await KriptaApiClient.updatePlayerPin(this.playerGuid, dialogResult.pin);
        this.pin = dialogResult.pin;
        notifyInfo(localize("Notification.PinUpdated"));
        this.render();
      } catch (error) {
        notifyError(error, localize("Notification.PinUpdateFailed"));
      }
    });

    html.find('[data-action="copy-pin"]').on("click", async () => {
      try {
        await copyTextToClipboard(this.pin);
        notifyInfo(localize("Notification.PinCopied"));
      } catch (error) {
        notifyError(error, localize("Notification.PinCopyFailed"));
      }
    });
  }
}
