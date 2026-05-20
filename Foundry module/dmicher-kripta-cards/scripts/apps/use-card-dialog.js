import { KriptaApiClient } from "../api/client.js";
import { MODULE_ID, TEMPLATE_ROOT } from "../constants.js";
import { createKriptaChatMessage } from "../helpers/chat.js";
import { notifyError, notifyInfo, notifyWarn } from "../helpers/utils.js";

export class KriptaUseCardDialog extends FormApplication {
  constructor(options = {}) {
    super(options);
    this.playerGuid = options.playerGuid;
    this.playerName = options.playerName ?? game.user.name;
    this.ownerFoundryUserId = options.ownerFoundryUserId ?? game.user.id;
    this.level = Number(options.level);
    this.number = Number(options.number);
    this.onComplete = options.onComplete ?? (() => {});
    this.meta = null;
    this.imageUrl = "";
    this.isMissing = false;
  }

  static get defaultOptions() {
    return foundry.utils.mergeObject(super.defaultOptions, {
      id: `${MODULE_ID}-use-card`,
      title: "Использовать карточку",
      template: `${TEMPLATE_ROOT}/use-card-dialog.hbs`,
      classes: [MODULE_ID, "sheet"],
      width: 480,
      height: "auto",
      closeOnSubmit: true
    });
  }

  async getData() {
    try {
      this.meta = await KriptaApiClient.getCardMeta(this.level, this.number);
      const blob = await KriptaApiClient.getCardImageBlob(this.meta.imagePath).catch(() => null);
      this.imageUrl = blob ? URL.createObjectURL(blob) : "";
      this.isMissing = false;

      return {
        meta: this.meta,
        imageUrl: this.imageUrl,
        isMissing: false
      };
    } catch (error) {
      const message = String(error?.message ?? "");

      if (message.includes("404") || message.toLowerCase().includes("not registered")) {
        this.isMissing = true;
        this.meta = {
          level: this.level,
          number: this.number,
          name: `Карточка ${this.number}`,
          description: `Карточка ${this.level}/${this.number} больше не зарегистрирована на сервере.`
        };

        return {
          meta: this.meta,
          imageUrl: "",
          isMissing: true
        };
      }

      throw error;
    }
  }

  async _updateObject(_event, formData) {
    if (this.isMissing) {
      notifyWarn("Эта карточка больше не зарегистрирована на сервере. Использование недоступно.");
      return;
    }

    const data = foundry.utils.expandObject(formData);
    const spend = data.mode !== "show";

    try {
      if (spend) {
        await KriptaApiClient.takeCard(this.playerGuid, this.level, this.number, 1);
      }

      await createKriptaChatMessage({
        title: this.meta?.name ?? `Карточка ${this.level}/${this.number}`,
        imageUrl: this.imageUrl,
        description: this.meta?.description ?? "",
        footerHtml: spend
          ? '<div class="kripta-spent-note" style="display:block;width:100%;margin-top:8px;font-size:12px;line-height:1.35;font-weight:700;text-align:center;color:#d44;">карточка потрачена</div>'
          : "",
        speakerUser: game.users.get(this.ownerFoundryUserId) ?? game.user,
        rollModeUser: game.user
      });

      if (spend) notifyInfo("Карточка использована и списана.");
      await this.onComplete();
    } catch (error) {
      notifyError(error, "Не удалось использовать карточку");
    }
  }
}