import { KriptaApiClient } from "../api/client.js";
import { MODULE_ID, TEMPLATE_ROOT } from "../constants.js";
import { createKriptaChatMessage } from "../helpers/chat.js";
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

export class KriptaGiveCardDialog extends FormApplication {
  constructor(options = {}) {
    super(options);
    this.playerGuid = options.playerGuid ?? "";
    this.playerName = options.playerName ?? "";
    this.ownerFoundryUserId = options.ownerFoundryUserId ?? game.user.id;
    this.onComplete = options.onComplete ?? (() => {});
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
      id: `${MODULE_ID}-give-card`,
      title: "Выдать карточку",
      template: `${TEMPLATE_ROOT}/give-card-dialog.hbs`,
      classes: [MODULE_ID, "sheet"],
      width: 520,
      height: "auto",
      closeOnSubmit: true
    });
  }

  async getData() {
    this.levels = await KriptaApiClient.getLevelsList();

    if (this.selectedLevel === null || this.selectedLevel === undefined) {
      this.selectedLevel = this.initialLevel ?? this.levels[0]?.id ?? 0;
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
      if (!Number.isNaN(levelFromForm)) {
        this.selectedLevel = levelFromForm;
      }

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
      }

      this.render();
    });

    html.find('[name="cardNumber"]').on("change", (event) => {
      this.selectedNumber = Number(event.currentTarget.value);
    });
  }

  async _updateObject(_event, formData) {
    const snapshot = {
      data: foundry.utils.expandObject(formData),
      playerGuid: String(this.playerGuid ?? "").trim(),
      playerName: this.playerName ?? "",
      ownerFoundryUserId: this.ownerFoundryUserId ?? game.user.id,
      initialLevel: this.initialLevel,
      initialNumber: this.initialNumber,
      selectedLevel: this.selectedLevel,
      selectedNumber: this.selectedNumber,
      mode: this.mode,
      levels: Array.isArray(this.levels) ? [...this.levels] : []
    };

    void this._submitGiveInBackground(snapshot);
  }

  async _submitGiveInBackground(snapshot) {
    try {
      const data = snapshot.data ?? {};

      const selectedLevel = Number(
        data.level ??
        snapshot.selectedLevel ??
        snapshot.initialLevel ??
        snapshot.levels[0]?.id ??
        0
      );

      const selectedMode = String(
        data.mode ??
        snapshot.mode ??
        "random"
      );

      let playerGuid = String(snapshot.playerGuid ?? "").trim();

      if (!playerGuid) {
        const binding = getBinding(snapshot.ownerFoundryUserId);
        playerGuid = String(binding?.guid ?? binding?.playerGuid ?? binding?.id ?? "").trim();
      }

      let card = null;

      if (selectedMode === "manual") {
        const rawSelectedNumber =
          data.cardNumber ??
          snapshot.selectedNumber ??
          snapshot.initialNumber;

        const selectedNumber = Number(rawSelectedNumber);

        if (!Number.isInteger(selectedNumber) || selectedNumber < 0) {
          throw new Error("Не удалось определить выбранную карточку для выдачи.");
        }

        card = await KriptaApiClient.getCardMeta(selectedLevel, selectedNumber);
      } else {
        card = await KriptaApiClient.rollCard(selectedLevel);

        if (!isValidCard(card)) {
          const fallbackCards = await KriptaApiClient.getCardsList(selectedLevel, "");
          card = pickRandomCard(fallbackCards);
        }

        if (isValidCard(card) && needsMetaHydration(card)) {
          card = await KriptaApiClient.getCardMeta(card.level, card.number);
        }
      }

      if (!playerGuid) {
        throw new Error("Не удалось определить игрока для выдачи карточки.");
      }

      if (!isValidCard(card)) {
        throw new Error("Не удалось определить карточку для выдачи.");
      }

      await KriptaApiClient.giveCard(playerGuid, card.level, card.number, 1);

      const levels = snapshot.levels.length ? snapshot.levels : await KriptaApiClient.getLevelsList();
      const levelName = levels.find((item) => Number(item.id) === Number(card.level))?.name ?? String(card.level);

      await createKriptaChatMessage({
        title: `Игрок ${snapshot.playerName} получает карточку ${card.name} (${levelName})`,
        imageUrl: "",
        imageResolver: async () => {
          const blob = await KriptaApiClient.getCardImageBlob(card.level, card.number).catch(() => null);
          return blob ? URL.createObjectURL(blob) : "";
        },
        description: card.description,
        speakerUser: game.user
      });

      notifyInfo("Карточка выдана.");
      await Promise.resolve(this.onComplete());
    } catch (error) {
      notifyError(error, "Не удалось выдать карточку");
    }
  }
}