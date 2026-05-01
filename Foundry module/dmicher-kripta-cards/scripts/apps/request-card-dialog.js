import { KriptaApiClient } from "../api/client.js";
import { MODULE_ID, TEMPLATE_ROOT } from "../constants.js";
import { createCardRequestMessage } from "../helpers/chat.js";
import { getBinding, notifyError, notifyInfo } from "../helpers/utils.js";

function isValidCard(card) {
  return !!card && Number(card.level) >= 0 && Number(card.number) >= 0;
}

function pickRandomCard(cards) {
  if (!Array.isArray(cards) || !cards.length) return null;
  return cards[Math.floor(Math.random() * cards.length)] ?? null;
}

function needsMetaHydration(card) {
  return !card || !String(card.name ?? "").trim() || !String(card.description ?? "").trim();
}

export class KriptaRequestCardDialog extends FormApplication {
  constructor(options = {}) {
    super(options);

    this.playerGuid = options.playerGuid ?? "";
    this.ownerFoundryUserId = options.ownerFoundryUserId ?? game.user.id;

    this.initialLevel = options.initialLevel ?? null;
    this.initialNumber = options.initialNumber ?? null;

    this.selectedLevel = options.initialLevel ?? null;
    this.selectedNumber = options.initialNumber ?? null;

    this.mode = this.initialLevel !== null && this.initialNumber !== null ? "manual" : "random";

    this.levels = [];
    this.cards = [];
  }

  static get defaultOptions() {
    return foundry.utils.mergeObject(super.defaultOptions, {
      id: `${MODULE_ID}-request-card`,
      title: "Получить карточку",
      template: `${TEMPLATE_ROOT}/request-card-dialog.hbs`,
      classes: [MODULE_ID, "sheet"],
      width: 520,
      height: "auto",
      closeOnSubmit: true
    });
  }

  async getData() {
    this.levels = await KriptaApiClient.getLevelsList();

    if (this.selectedLevel === null || this.selectedLevel === undefined) {
      this.selectedLevel = this.levels[0]?.id ?? 0;
    }

    if (this.mode === "manual") {
      this.cards = await KriptaApiClient.getCardsList(this.selectedLevel, "");
      if (
        (this.selectedNumber === null || this.selectedNumber === undefined || this.selectedNumber === "") &&
        this.cards.length
      ) {
        this.selectedNumber = this.cards[0].number;
      }
    } else {
      this.cards = [];
    }

    return {
      levels: this.levels,
      cards: this.cards,
      selectedLevel: this.selectedLevel,
      selectedNumber: this.selectedNumber ?? "",
      isManual: this.mode === "manual"
    };
  }

  activateListeners(html) {
    super.activateListeners(html);

    html.find('[name="mode"]').on("change", async (event) => {
      this.mode = String(event.currentTarget.value);

      const levelFromForm = Number(html.find('[name="level"]').val());
      if (!Number.isNaN(levelFromForm)) this.selectedLevel = levelFromForm;

      if (this.mode === "manual") {
        this.cards = await KriptaApiClient.getCardsList(this.selectedLevel, "");
        this.selectedNumber = this.cards[0]?.number ?? null;
      } else {
        this.cards = [];
        this.selectedNumber = null;
      }

      this.render();
    });

    html.find('[name="level"]').on("change", async (event) => {
      this.selectedLevel = Number(event.currentTarget.value);

      if (this.mode === "manual") {
        this.cards = await KriptaApiClient.getCardsList(this.selectedLevel, "");
        this.selectedNumber = this.cards[0]?.number ?? null;
        this.render();
      }
    });

    html.find('[name="cardNumber"]').on("change", (event) => {
      this.selectedNumber = Number(event.currentTarget.value);
    });
  }

  async _updateObject(_event, formData) {
    const snapshot = {
      data: foundry.utils.expandObject(formData),
      playerGuid: String(this.playerGuid ?? "").trim(),
      ownerFoundryUserId: this.ownerFoundryUserId ?? game.user.id,
      initialLevel: this.initialLevel,
      initialNumber: this.initialNumber,
      selectedLevel: this.selectedLevel,
      selectedNumber: this.selectedNumber,
      mode: this.mode,
      levels: Array.isArray(this.levels) ? [...this.levels] : []
    };

    void this._submitRequestInBackground(snapshot);
  }

  async _submitRequestInBackground(snapshot) {
    try {
      const data = snapshot.data ?? {};

      const selectedLevel = Number(
        data.level ??
        snapshot.selectedLevel ??
        snapshot.initialLevel ??
        0
      );

      const mode = String(
        data.mode ??
        snapshot.mode ??
        "random"
      );

      let playerGuid = String(snapshot.playerGuid ?? "").trim();
      const ownerFoundryUserId = snapshot.ownerFoundryUserId ?? game.user.id;

      if (!playerGuid) {
        const binding = getBinding(ownerFoundryUserId);
        playerGuid = String(binding?.guid ?? binding?.playerGuid ?? binding?.id ?? "").trim();
      }

      let chosenCard = null;

      if (mode === "manual") {
        const rawSelectedNumber =
          data.cardNumber ??
          snapshot.selectedNumber ??
          snapshot.initialNumber;

        const selectedNumber = Number(rawSelectedNumber);

        if (!Number.isInteger(selectedNumber) || selectedNumber < 0) {
          ui.notifications.warn("Не удалось определить выбранную карточку.");
          return;
        }

        chosenCard = await KriptaApiClient.getCardMeta(selectedLevel, selectedNumber);
      } else {
        chosenCard = await KriptaApiClient.rollCard(selectedLevel);

        if (!isValidCard(chosenCard)) {
          const fallbackCards = await KriptaApiClient.getCardsList(selectedLevel, "");
          chosenCard = pickRandomCard(fallbackCards);
        }

        if (isValidCard(chosenCard) && needsMetaHydration(chosenCard)) {
          chosenCard = await KriptaApiClient.getCardMeta(chosenCard.level, chosenCard.number);
        }
      }

      if (!isValidCard(chosenCard)) {
        ui.notifications.warn("Не удалось получить карточку.");
        return;
      }

      const resolvedLevelName =
        snapshot.levels.find((item) => Number(item.id) === Number(chosenCard.level))?.name ??
        chosenCard.levelName ??
        "";

      await createCardRequestMessage({
        playerGuid,
        ownerFoundryUserId,
        playerName: game.users.get(ownerFoundryUserId)?.name ?? game.user.name,
        level: chosenCard.level,
        number: chosenCard.number,
        title: mode === "manual"
          ? `Выбрана карта: ${chosenCard.name}`
          : `Случайная карта: ${chosenCard.name}`,
        levelName: resolvedLevelName,
        imageUrl: "",
        imageResolver: async () => {
          const blob = await KriptaApiClient.getCardImageBlob(chosenCard.level, chosenCard.number).catch(() => null);
          return blob ? URL.createObjectURL(blob) : "";
        },
        description: chosenCard.description ?? "",
        speakerUser: game.user
      });

      notifyInfo("Запрос карточки отправлен в чат.");
    } catch (error) {
      notifyError(error, "Не удалось отправить запрос карточки");
    }
  }
}