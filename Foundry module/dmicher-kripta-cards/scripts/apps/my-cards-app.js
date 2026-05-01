import { KriptaApiClient } from "../api/client.js";
import { MODULE_ID, TEMPLATE_ROOT, VIEW_MODES } from "../constants.js";
import { countPromptDialog } from "./dialogs.js";
import { KriptaCardDetailsApp } from "./card-details-app.js";
import { KriptaRequestCardDialog } from "./request-card-dialog.js";
import { KriptaUseCardDialog } from "./use-card-dialog.js";
import { getUiPrefs, notifyError, notifyInfo, notifyWarn, setUiPref, stripHtml } from "../helpers/utils.js";

const MISSING_CARD_CACHE = new Set();

const WINDOW_MIN_WIDTH = 450;
const SIDEBAR_MIN_WIDTH = 200;
const MAIN_MIN_WIDTH = 250;

const MY_CARDS_IMAGE_URL_CACHE = new Map();
const MY_CARDS_IMAGE_PROMISE_CACHE = new Map();

function clamp(value, min, max) {
  return Math.min(Math.max(value, min), max);
}

function isValidOwnedCard(card) {
  const level = Number(card?.level);
  const number = Number(card?.number);
  const count = Number(card?.count ?? 1);

  return Number.isInteger(level) && level >= 0 &&
    Number.isInteger(number) && number >= 0 &&
    Number.isFinite(count) && count > 0;
}

function buildMissingMeta(item) {
  return {
    level: Number(item.level),
    number: Number(item.number),
    name: `Карточка ${item.number}`,
    description: `Карточка ${item.level}/${item.number} отсутствует в текущем каталоге сервера.`
  };
}

function getMyCardsImageCacheKey(level, number) {
  return `${Number(level)}:${Number(number)}`;
}

async function loadMyCardsImageUrl(level, number) {
  const cacheKey = getMyCardsImageCacheKey(level, number);

  if (MY_CARDS_IMAGE_URL_CACHE.has(cacheKey)) {
    return MY_CARDS_IMAGE_URL_CACHE.get(cacheKey) || "";
  }

  if (!MY_CARDS_IMAGE_PROMISE_CACHE.has(cacheKey)) {
    const promise = KriptaApiClient.getCardImageBlob(level, number)
      .then((blob) => blob ? URL.createObjectURL(blob) : "")
      .catch(() => "")
      .then((url) => {
        if (url) {
          MY_CARDS_IMAGE_URL_CACHE.set(cacheKey, url);
        }

        MY_CARDS_IMAGE_PROMISE_CACHE.delete(cacheKey);
        return url;
      });

    MY_CARDS_IMAGE_PROMISE_CACHE.set(cacheKey, promise);
  }

  return MY_CARDS_IMAGE_PROMISE_CACHE.get(cacheKey) || "";
}

export class KriptaMyCardsApp extends Application {
  constructor(options = {}) {
    super(options);

    const prefs = getUiPrefs();
    const savedSidebarWidthPx = Number(prefs?.myCardsSidebarWidthPx ?? 0);

    this.sidebarWidthPx = Number.isFinite(savedSidebarWidthPx) && savedSidebarWidthPx > 0
      ? savedSidebarWidthPx
      : 0;

    this._sidebarResizeWindowHandler = null;

    this._sidebarResizeMouseDownHandler = null;
    this._sidebarResizeMouseMoveHandler = null;
    this._sidebarResizeMouseUpHandler = null;
    this._sidebarResizeDivider = null;

    this.playerGuid = options.playerGuid;
    this.playerName = options.playerName ?? game.user.name;
    this.ownerFoundryUserId = options.ownerFoundryUserId ?? game.user.id;
    this.search = "";
    this.levels = [];
    this.selectedLevel = null;
    this.items = [];
    this.viewMode = getUiPrefs().myCardsViewMode ?? VIEW_MODES.TILES;
  }

  static get defaultOptions() {
    return foundry.utils.mergeObject(super.defaultOptions, {
      id: `${MODULE_ID}-my-cards-${foundry.utils.randomID()}`,
      title: "Карточки игрока",
      template: `${TEMPLATE_ROOT}/my-cards-app.hbs`,
      classes: [MODULE_ID, "sheet"],
      width: 1040,
      height: 760,
      minWidth: WINDOW_MIN_WIDTH,
      resizable: true
    });
  }

  async getData() {
    const [serverLevels, infoList] = await Promise.all([
      KriptaApiClient.getLevelsList(),
      KriptaApiClient.getPlayersInfo([this.playerGuid])
    ]);

    const player = infoList[0] ?? { playerCards: [] };
    const rawCards = Array.isArray(player.playerCards) ? player.playerCards : [];
    const validCards = rawCards.filter(isValidOwnedCard);
    const invalidCards = rawCards.filter((card) => !isValidOwnedCard(card));

    if (invalidCards.length) {
      console.warn("KRIPTA myCards invalid cards filtered JSON", JSON.stringify(invalidCards, null, 2));
    }

    const extraLevels = [...new Set(validCards.map((card) => Number(card.level)))]
      .filter((levelId) => !serverLevels.some((item) => Number(item.id) === levelId))
      .map((levelId) => ({
        id: levelId,
        name: `Уровень ${levelId}`,
        description: "Уровень присутствует в инвентаре игрока, но отсутствует в текущем каталоге сервера."
      }));

    this.levels = [...serverLevels, ...extraLevels].sort((a, b) => Number(a.id) - Number(b.id));
    if (!this.levels.length) {
      return { emptyState: true };
    }

    if (
      this.selectedLevel === null ||
      this.selectedLevel === undefined ||
      !this.levels.some((item) => Number(item.id) === Number(this.selectedLevel))
    ) {
      this.selectedLevel = this.levels[0].id;
    }

    const groupedCards = validCards.reduce((map, card) => {
      const key = `${card.level}:${card.number}`;
      if (!map.has(key)) {
        map.set(key, {
          level: Number(card.level),
          number: Number(card.number),
          count: 0
        });
      }
      map.get(key).count += Number(card.count ?? 1);
      return map;
    }, new Map());

    const list = [...groupedCards.values()].filter((item) => Number(item.level) === Number(this.selectedLevel));

    const metaResults = await Promise.all(
      list.map(async (item) => {
        const cacheKey = `${item.level}:${item.number}`;

        if (MISSING_CARD_CACHE.has(cacheKey)) {
          return {
            meta: buildMissingMeta(item),
            isMissing: true
          };
        }

        try {
          const meta = await KriptaApiClient.getCardMeta(item.level, item.number);
          return {
            meta,
            isMissing: false
          };
        } catch (error) {
          MISSING_CARD_CACHE.add(cacheKey);
          console.warn("KRIPTA myCards missing card meta", { item, error });
          return {
            meta: buildMissingMeta(item),
            isMissing: true
          };
        }
      })
    );

    this.items = list.map((item, index) => {
      const descriptionText = stripHtml(metaResults[index]?.meta?.description ?? "");
      const name = String(metaResults[index]?.meta?.name ?? item?.name ?? "");
      const cachedImageUrl = metaResults[index]?.isMissing
        ? ""
        : (MY_CARDS_IMAGE_URL_CACHE.get(getMyCardsImageCacheKey(item.level, item.number)) || "");

      return {
        ...item,
        ...metaResults[index].meta,
        imageUrl: cachedImageUrl,
        descriptionText,
        searchText: `${name} ${descriptionText}`.toLowerCase(),
        isMissing: metaResults[index]?.isMissing ?? false
      };
    });

    const activeLevel = this.levels.find((item) => Number(item.id) === Number(this.selectedLevel)) ?? this.levels[0];

    return {
      emptyState: false,
      playerName: this.playerName,
      levels: this.levels.map((item) => ({ ...item, isActive: Number(item.id) === Number(activeLevel.id) })),
      activeLevel,
      items: this.items,
      search: this.search,
      isTiles: this.viewMode === VIEW_MODES.TILES,
      isTable: this.viewMode === VIEW_MODES.TABLE,
      isGM: game.user.isGM,
      sidebarWidthStyle: this.sidebarWidthPx > 0 ? `--kripta-sidebar-width: ${this.sidebarWidthPx}px;` : ""
    };
  }

  activateListeners(html) {
    super.activateListeners(html);

    const root = this.element?.[0] ?? html?.[0] ?? null;

    this._setupSidebarResize(root);

    html.find('[data-level-id]').on("click", (event) => {
      this.selectedLevel = Number(event.currentTarget.dataset.levelId);
      this.render();
    });

    html.find('[name="search"]').on("input", (event) => {
      this.search = String(event.currentTarget.value ?? "");
      this._applySearchFilter(root, this.search);
    });

    this._applySearchFilter(root, this.search);
    void this._hydrateImages(root);

    html.find('[data-action="set-view"]').on("click", async (event) => {
      this.viewMode = event.currentTarget.dataset.view;
      await setUiPref("myCardsViewMode", this.viewMode);
      this.render();
    });

    html.find('[data-action="refresh"]').on("click", () => this.render());

    html.find('[data-action="request"]').on("click", () => {
      new KriptaRequestCardDialog({
        playerGuid: this.playerGuid,
        ownerFoundryUserId: this.ownerFoundryUserId
      }).render(true);
    });

    html.find('[data-action="use"]').on("click", (event) => {
      const item = this._findItem(event);
      if (!item) return;

      if (item.isMissing) {
        return notifyWarn("Эта карточка больше не зарегистрирована на сервере. Использование недоступно.");
      }

      new KriptaUseCardDialog({
        playerGuid: this.playerGuid,
        playerName: this.playerName,
        ownerFoundryUserId: this.ownerFoundryUserId,
        level: item.level,
        number: item.number,
        onComplete: () => this.render()
      }).render(true);
    });

    html.find('[data-action="info"]').on("click", (event) => {
      const item = this._findItem(event);
      if (!item) return;

      if (item.isMissing) {
        return notifyWarn("Эта карточка больше не зарегистрирована на сервере.");
      }

      new KriptaCardDetailsApp({ level: item.level, number: item.number }).render(true);
    });

    html.find('[data-action="take"]').on("click", async (event) => {
      const item = this._findItem(event);
      if (!item) return;

      const count = await countPromptDialog({
        title: "Забрать карточку",
        message: `Игрок ${this.playerName} будет лишён карточки ${item.name}.`,
        max: item.count,
        defaultValue: 1
      });

      if (!Number.isFinite(Number(count)) || Number(count) <= 0) return;

      const normalizedCount = Math.max(1, Math.min(item.count, Math.trunc(Number(count))));

      try {
        await KriptaApiClient.takeCard(this.playerGuid, item.level, item.number, normalizedCount);
        notifyInfo("Карточка списана.");
        this.render();
      } catch (error) {
        notifyError(error, "Не удалось списать карточку");
      }
    });

    html.find(".kripta-card-tile").on("click", (event) => {
      if ($(event.target).closest("button").length) return;

      const cardKey = event.currentTarget.closest("[data-card-key]")?.dataset?.cardKey;
      if (!cardKey) return;

      const item = this.items.find((entry) => `${entry.level}:${entry.number}` === cardKey);
      if (!item) return;

      if (item.isMissing) {
        return notifyWarn("Эта карточка больше не зарегистрирована на сервере.");
      }

      new KriptaCardDetailsApp({ level: item.level, number: item.number }).render(true);
    });
  }

  setPosition(position = {}) {
    const nextPosition = { ...position };

    const requestedWidth = Number(
      nextPosition.width ??
      this.position?.width ??
      this.options?.width ??
      WINDOW_MIN_WIDTH
    );

    nextPosition.width = Math.max(WINDOW_MIN_WIDTH, requestedWidth);

    const result = super.setPosition(nextPosition);

    const root = this.element?.[0];
    const browser = root?.querySelector(".kripta-browser--resizable");
    const sidebar = browser?.querySelector(".kripta-browser__sidebar");

    if (browser && sidebar) {
      this._applySidebarWidth(browser, sidebar, this.sidebarWidthPx);
    }

    return result;
  }

  async close(options) {
    if (this._sidebarResizeWindowHandler) {
      window.removeEventListener("resize", this._sidebarResizeWindowHandler);
      this._sidebarResizeWindowHandler = null;
    }

    if (this._sidebarResizeDivider && this._sidebarResizeMouseDownHandler) {
      this._sidebarResizeDivider.removeEventListener("mousedown", this._sidebarResizeMouseDownHandler);
    }

    if (this._sidebarResizeMouseMoveHandler) {
      document.removeEventListener("mousemove", this._sidebarResizeMouseMoveHandler);
      this._sidebarResizeMouseMoveHandler = null;
    }

    if (this._sidebarResizeMouseUpHandler) {
      document.removeEventListener("mouseup", this._sidebarResizeMouseUpHandler);
      this._sidebarResizeMouseUpHandler = null;
    }

    this._sidebarResizeDivider = null;
    this._sidebarResizeMouseDownHandler = null;

    document.body.style.userSelect = "";
    document.body.style.cursor = "";

    return super.close(options);
  }

  _applySidebarWidth(browser, sidebar, rawWidth = this.sidebarWidthPx) {
    const divider = browser.querySelector('[data-action="resize-sidebar"]');
    const main = browser.querySelector(".kripta-browser__main");

    const browserWidth =
      browser.getBoundingClientRect().width ||
      browser.clientWidth ||
      this.position?.width ||
      this.options?.width ||
      1040;

    const dividerWidth =
      divider?.getBoundingClientRect?.().width ||
      8;

    const defaultWidth = Math.max(SIDEBAR_MIN_WIDTH, Math.round(browserWidth * 0.2));
    const maxWidth = Math.max(SIDEBAR_MIN_WIDTH, browserWidth - MAIN_MIN_WIDTH - dividerWidth);
    const nextWidth = clamp(Number(rawWidth) || defaultWidth, SIDEBAR_MIN_WIDTH, maxWidth);

    this.sidebarWidthPx = nextWidth;

    browser.style.setProperty("--kripta-sidebar-width", `${nextWidth}px`);
    browser.style.gridTemplateColumns = `${nextWidth}px ${dividerWidth}px minmax(${MAIN_MIN_WIDTH}px, 1fr)`;

    sidebar.style.width = `${nextWidth}px`;
    sidebar.style.minWidth = `${nextWidth}px`;
    sidebar.style.maxWidth = `${nextWidth}px`;

    if (main) {
      main.style.minWidth = `${MAIN_MIN_WIDTH}px`;
    }
  }
  _setupSidebarResize(rootOrHtml) {
    const root =
      rootOrHtml?.querySelector
        ? rootOrHtml
        : (rootOrHtml?.[0] ?? this.element?.[0] ?? null);

    const browser = root?.querySelector(".kripta-browser--resizable");
    const sidebar = browser?.querySelector(".kripta-browser__sidebar");
    const divider = browser?.querySelector('[data-action="resize-sidebar"]');

    if (!browser || !sidebar || !divider) return;

    this._applySidebarWidth(browser, sidebar, this.sidebarWidthPx);

    if (!this._sidebarResizeWindowHandler) {
      this._sidebarResizeWindowHandler = () => {
        const nextRoot = this.element?.[0] ?? null;
        const nextBrowser = nextRoot?.querySelector(".kripta-browser--resizable");
        const nextSidebar = nextBrowser?.querySelector(".kripta-browser__sidebar");

        if (nextBrowser && nextSidebar) {
          this._applySidebarWidth(nextBrowser, nextSidebar, this.sidebarWidthPx);
        }
      };

      window.addEventListener("resize", this._sidebarResizeWindowHandler);
    }

    divider.onpointerdown = (event) => {
      event.preventDefault();

      const startX = event.clientX;
      const startWidth = this.sidebarWidthPx || sidebar.getBoundingClientRect().width;

      browser.classList.add("is-resizing");

      const onPointerMove = (moveEvent) => {
        const deltaX = moveEvent.clientX - startX;
        this._applySidebarWidth(browser, sidebar, startWidth + deltaX);
      };

      const onPointerUp = async () => {
        browser.classList.remove("is-resizing");
        window.removeEventListener("pointermove", onPointerMove);
        window.removeEventListener("pointerup", onPointerUp);

        try {
          await setUiPref("myCardsSidebarWidthPx", this.sidebarWidthPx);
        } catch (error) {
          console.warn("KRIPTA sidebar width save failed", error);
        }
      };

      window.addEventListener("pointermove", onPointerMove);
      window.addEventListener("pointerup", onPointerUp, { once: true });
    };
  }

  async _hydrateImages(root) {
    const cards = Array.from(root?.querySelectorAll("[data-card-key]") ?? []);
    await Promise.all(cards.map((cardElement) => this._hydrateCardImage(cardElement)));
  }

  async _hydrateCardImage(cardElement) {
    const cardKey = String(cardElement?.dataset?.cardKey ?? "");
    if (!cardKey) return;

    const item = this.items.find((entry) => `${entry.level}:${entry.number}` === cardKey);
    if (!item || item.isMissing) return;

    const imageContainer = cardElement.classList.contains("kripta-card-tile")
      ? cardElement.querySelector(".kripta-card-tile__image-wrap")
      : cardElement.querySelector(".kripta-row-card__image");

    if (!imageContainer || imageContainer.querySelector("img")) return;

    const imageUrl = item.imageUrl || await loadMyCardsImageUrl(item.level, item.number);
    if (!imageUrl) return;

    item.imageUrl = imageUrl;

    const currentRoot = this.element?.[0];
    const currentCardElement = currentRoot?.querySelector(`[data-card-key="${cardKey}"]`);
    if (!currentCardElement) return;

    const currentContainer = currentCardElement.classList.contains("kripta-card-tile")
      ? currentCardElement.querySelector(".kripta-card-tile__image-wrap")
      : currentCardElement.querySelector(".kripta-row-card__image");

    if (!currentContainer || currentContainer.querySelector("img")) return;

    const img = document.createElement("img");
    img.src = imageUrl;
    img.alt = item.name ?? "";

    currentContainer.innerHTML = "";
    currentContainer.appendChild(img);
  }

  _normalizeSearch(value) {
    return String(value ?? "").trim().toLowerCase();
  }

  _applySearchFilter(root, rawSearch = this.search) {
    const normalizedSearch = this._normalizeSearch(rawSearch);
    const cards = root?.querySelectorAll("[data-card-key]") ?? [];

    for (const card of cards) {
      const haystack = String(card.dataset.searchText ?? "").toLowerCase();
      card.style.display = !normalizedSearch || haystack.includes(normalizedSearch) ? "" : "none";
    }
  }

  _findItem(event) {
    const cardKey = event.currentTarget.closest("[data-card-key]")?.dataset?.cardKey;
    return this.items.find((item) => `${item.level}:${item.number}` === cardKey);
  }
}