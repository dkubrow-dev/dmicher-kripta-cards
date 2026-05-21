import { KriptaApiClient } from "../api/client.js";
import { MODULE_ID, TEMPLATE_ROOT } from "../constants.js";
import { buildCardSubtitle, createKriptaChatMessage } from "../helpers/chat.js";
import { notifyError, notifyInfo, notifyWarn } from "../helpers/utils.js";
import { sanitizeCardHtml, stripHtml } from "../helpers/html-sanitizer.js";

function decorateCardMeta(meta) {
  const name = String(meta?.name ?? "");
  const description = String(meta?.description ?? "");

  return {
    ...meta,
    nameText: stripHtml(name),
    nameHtml: sanitizeCardHtml(name),
    descriptionHtml: sanitizeCardHtml(description)
  };
}

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
    this.levels = [];
    this.levelName = "";
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
      const [meta, levels] = await Promise.all([
        KriptaApiClient.getCardMeta(this.level, this.number),
        KriptaApiClient.getLevelsList()
      ]);

      this.meta = decorateCardMeta(meta);
      this.levels = levels;
      this.levelName = levels.find((item) => Number(item.id) === Number(this.level))?.name ?? String(this.level);

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
        this.levelName = String(this.level);
        this.meta = decorateCardMeta({
          level: this.level,
          number: this.number,
          name: `Карточка ${this.number}`,
          description: `Карточка ${this.level}/${this.number} больше не зарегистрирована на сервере.`
        });

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
        title: spend ? "Карта потрачена" : "Справка по карте",
        subtitle: buildCardSubtitle(this.meta?.name ?? `Карта ${this.level}/${this.number}`, this.levelName || this.level),
        imageUrl: this.imageUrl,
        description: this.meta?.description ?? "",
        footerHtml: spend ? '<div class="kripta-spent-note">КАРТА ПОТРАЧЕНА</div>' : "",
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
