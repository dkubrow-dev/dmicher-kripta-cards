import { KriptaApiClient } from "../api/client.js";
import { MODULE_ID, TEMPLATE_ROOT } from "../constants.js";
import { KriptaGiveCardDialog } from "./give-card-dialog.js";
import { KriptaRequestCardDialog } from "./request-card-dialog.js";
import { createKriptaChatMessage } from "../helpers/chat.js";
import { chooseBoundUserDialog } from "./dialogs.js";
import { getBinding, getBindings, notifyError, notifyWarn } from "../helpers/utils.js";

function assertLocalCardRef(level, number) {
  const normalizedLevel = Number(level);
  const normalizedNumber = Number(number);

  if (!Number.isInteger(normalizedLevel) || normalizedLevel < 0) {
    throw new Error(`некорректный level карточки: ${level}`);
  }

  if (!Number.isInteger(normalizedNumber) || normalizedNumber < 0) {
    throw new Error(`некорректный number карточки: ${number}`);
  }

  return { level: normalizedLevel, number: normalizedNumber };
}

export class KriptaCardDetailsApp extends Application {
  constructor(options = {}) {
    super(options);
    this.level = Number(options.level);
    this.number = Number(options.number);
    this.meta = null;
    this.levels = [];
    this.imageUrl = "";
  }

  static get defaultOptions() {
    return foundry.utils.mergeObject(super.defaultOptions, {
      id: `${MODULE_ID}-card-details-${foundry.utils.randomID()}`,
      title: "Карточка каталога",
      template: `${TEMPLATE_ROOT}/card-details-app.hbs`,
      classes: [MODULE_ID, "sheet"],
      width: 640,
      height: 720,
      resizable: true
    });
  }

  async getData() {
    const ref = assertLocalCardRef(this.level, this.number);


    const [meta, levels, imageBlob] = await Promise.all([
      KriptaApiClient.getCardMeta(ref.level, ref.number),
      KriptaApiClient.getLevelsList(),
      KriptaApiClient.getCardImageBlob(ref.level, ref.number).catch(() => null)
    ]);

    this.meta = meta;
    this.levels = levels;
    this.imageUrl = imageBlob ? URL.createObjectURL(imageBlob) : "";

    return {
      meta,
      levelName: levels.find((item) => item.id === ref.level)?.name ?? String(ref.level),
      imageUrl: this.imageUrl,
      isGM: game.user.isGM
    };
  }

  activateListeners(html) {
    super.activateListeners(html);

    html.find('[data-action="output"]').on("click", async () => {
      try {
        await createKriptaChatMessage({
          title: "Справка",
          subtitle: `${this.meta?.name ?? ""} (${this.levels.find((item) => item.id === this.level)?.name ?? this.level})`,
          imageUrl: this.imageUrl,
          description: this.meta?.description ?? "",
          speakerUser: game.user
        });
      } catch (error) {
        notifyError(error, "Не удалось вывести карточку в чат");
      }
    });

    html.find('[data-action="request"]').on("click", () => {
      const binding = getBinding(game.user.id);
      if (!binding?.guid) return notifyWarn(game.i18n.localize("KRIPTA.NoBinding"));

      try {
        const ref = assertLocalCardRef(this.level, this.number);
        new KriptaRequestCardDialog({
          playerGuid: binding.guid,
          ownerFoundryUserId: game.user.id,
          initialLevel: ref.level,
          initialNumber: ref.number
        }).render(true);
      } catch (error) {
        notifyWarn(error.message ?? "Некорректная карточка для запроса");
      }
    });

    html.find('[data-action="give"]').on("click", async () => {
      const bindings = getBindings();
      const rows = Object.entries(bindings).map(([foundryUserId, binding]) => ({
        foundryUserId,
        foundryUserName: game.users.get(foundryUserId)?.name ?? binding.name ?? foundryUserId,
        guid: binding.guid
      })).filter((item) => item.guid);

      const dialogResult = await chooseBoundUserDialog(rows);

      if (dialogResult?.action !== "confirm") return;

      const foundryUserId = String(dialogResult?.foundryUserId ?? "");
      if (!foundryUserId) return notifyWarn("Игрок для выдачи не выбран");

      const binding = bindings[foundryUserId];
      if (!binding?.guid) return notifyWarn("Не удалось определить привязку игрока для выдачи");

      const playerName = game.users.get(foundryUserId)?.name ?? binding?.name ?? "";

      try {
        const ref = assertLocalCardRef(this.level, this.number);
        new KriptaGiveCardDialog({
          playerGuid: binding.guid,
          ownerFoundryUserId: foundryUserId,
          playerName,
          initialLevel: ref.level,
          initialNumber: ref.number
        }).render(true);
      } catch (error) {
        notifyWarn(error.message ?? "Некорректная карточка для выдачи");
      }
    });
  }
}