import { KriptaApiClient } from "../api/client.js";
import { MODULE_ID, TEMPLATE_ROOT, VIEW_MODES } from "../constants.js";
import { KriptaCardDetailsApp } from "./card-details-app.js";
import { KriptaGiveCardDialog } from "./give-card-dialog.js";
import { buildCardSubtitle, createKriptaChatMessage } from "../helpers/chat.js";
import { chooseBoundUserDialog } from "./dialogs.js";
import { formatCardNameFallback, localize } from "../helpers/lang.js";
import { getBindings, getUiPrefs, notifyError, notifyWarn, setUiPref } from "../helpers/utils.js";
import { sanitizeCardHtml, stripHtml, truncateHtmlDescription } from "../helpers/html-sanitizer.js";

const WINDOW_MIN_WIDTH = 450;
const SIDEBAR_MIN_WIDTH = 200;
const MAIN_MIN_WIDTH = 250;
const RESIZER_WIDTH = 8;

const CATALOG_IMAGE_URL_CACHE = new Map();
const CATALOG_IMAGE_PROMISE_CACHE = new Map();

function clamp(value, min, max) {
  return Math.min(Math.max(value, min), max);
}

function isValidCardRef(card) {
  return (
    !!card &&
    Number.isInteger(Number(card.level)) &&
    Number(card.level) >= 0 &&
    Number.isInteger(Number(card.number)) &&
    Number(card.number) >= 0
  );
}

function buildCatalogFallbackMeta(card) {
  return {
    level: Number(card?.level),
    number: Number(card?.number),
    name: String(card?.name ?? formatCardNameFallback(card?.number ?? "")),
    description: String(card?.description ?? "")
  };
}

function getCatalogImageCacheKey(imagePath) {
    return String(imagePath ?? "");
}

async function loadCatalogImageUrl(imagePath) {
  const cacheKey = getCatalogImageCacheKey(imagePath);

  if (CATALOG_IMAGE_URL_CACHE.has(cacheKey)) {
    return CATALOG_IMAGE_URL_CACHE.get(cacheKey) || "";
  }

  if (!CATALOG_IMAGE_PROMISE_CACHE.has(cacheKey)) {
    const promise = KriptaApiClient.getCardImageBlob(imagePath)
      .then((blob) => blob ? URL.createObjectURL(blob) : "")
      .catch((error) => {
        console.warn("kripta image load failed", { imagePath, error });
        return "";
      })
      .then((url) => {
        if (url) {
          CATALOG_IMAGE_URL_CACHE.set(cacheKey, url);
        }

        CATALOG_IMAGE_PROMISE_CACHE.delete(cacheKey);
        return url;
      });

    CATALOG_IMAGE_PROMISE_CACHE.set(cacheKey, promise);
  }

  return CATALOG_IMAGE_PROMISE_CACHE.get(cacheKey) || "";
}

export class KriptaCatalogApp extends Application {
  constructor(options = {}) {
    super(options);

    const prefs = getUiPrefs();
    const savedSidebarWidthPx = Number(prefs?.catalogSidebarWidthPx ?? 0);

    this.sidebarWidthPx = Number.isFinite(savedSidebarWidthPx) && savedSidebarWidthPx > 0
      ? savedSidebarWidthPx
      : 0;

    this._sidebarResizeWindowHandler = null;

    this.levels = [];
    this.selectedLevel = null;
    this.search = "";
    this.viewMode = getUiPrefs().catalogViewMode ?? VIEW_MODES.TILES;
    this.cards = [];
    this.items = [];
  }

  static get defaultOptions() {
    return foundry.utils.mergeObject(super.defaultOptions, {
      id: `${MODULE_ID}-catalog`,
      title: localize("Window.Catalog"),
      template: `${TEMPLATE_ROOT}/catalog-app.hbs`,
      classes: [MODULE_ID, "sheet"],
      width: 1040,
      height: 760,
      minWidth: WINDOW_MIN_WIDTH,
      resizable: true
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

    return super.close(options);
  }

  async getData() {
    this.levels = await KriptaApiClient.getLevelsList();
    if (!this.levels.length) return { emptyState: true };

    if (
      this.selectedLevel === null ||
      this.selectedLevel === undefined ||
      !this.levels.some((item) => Number(item.id) === Number(this.selectedLevel))
    ) {
      this.selectedLevel = this.levels[0].id;
    }

    this.cards = await KriptaApiClient.getCardsList(this.selectedLevel, "");

    const metaResults = await Promise.all(
      this.cards.map(async (card) => {
        if (!isValidCardRef(card)) {
          return {
            meta: buildCatalogFallbackMeta(card),
            isBroken: true
          };
        }

        try {
          const meta = await KriptaApiClient.getCardMeta(card.level, card.number);
          return {
            meta,
            isBroken: false
          };
        } catch (error) {
          console.warn("kripta catalog meta load failed", { card, error });
          return {
            meta: buildCatalogFallbackMeta(card),
            isBroken: true
          };
        }
      })
    );

    this.items = this.cards.map((card, index) => {
      const meta = metaResults[index]?.meta ?? buildCatalogFallbackMeta(card);
      const name = String(meta?.name ?? card?.name ?? "");
      const nameText = stripHtml(name);
      const nameHtml = sanitizeCardHtml(name);
      const description = String(meta?.description ?? card?.description ?? "");
      const descriptionText = stripHtml(description);
      const descriptionPreviewHtml = truncateHtmlDescription(description, 250);
      const descriptionTablePreviewHtml = truncateHtmlDescription(description, 500);
      const cachedImageUrl = isValidCardRef(card)
        ? CATALOG_IMAGE_URL_CACHE.get(getCatalogImageCacheKey(meta.imagePath))
        : "";

      return {
        ...card,
        ...meta,
        imageUrl: cachedImageUrl,
        nameText,
        nameHtml,
        descriptionText,
        descriptionPreviewHtml,
        descriptionTablePreviewHtml,
        searchText: `${nameText} ${descriptionText}`.toLowerCase(),
        isBroken: !isValidCardRef(card) || (metaResults[index]?.isBroken ?? false)
      };
    });

    const activeLevel = this.levels.find((item) => Number(item.id) === Number(this.selectedLevel)) ?? this.levels[0];

    return {
      emptyState: false,
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

    this._setupSidebarResize(html);

    html.find('[data-level-id]').on("click", async (event) => {
      this.selectedLevel = Number(event.currentTarget.dataset.levelId);
      this.render();
    });

    html.find('[name="search"]').on("input", (event) => {
      this.search = String(event.currentTarget.value ?? "");
      this._applySearchFilter(html[0], this.search);
    });

    this._applySearchFilter(html[0], this.search);
    void this._hydrateImages(html[0]);

    html.find('[data-action="set-view"]').on("click", async (event) => {
      this.viewMode = event.currentTarget.dataset.view;
      await setUiPref("catalogViewMode", this.viewMode);
      this.render();
    });

    html.find('[data-action="refresh"]').on("click", () => this.render());

    html.find('[data-action="output"]').on("click", async (event) => {
      const item = this._findItem(event);
      if (!item) return;

      try {
        const levelName = this.levels.find((level) => Number(level.id) === Number(item.level))?.name ?? String(item.level);
        await createKriptaChatMessage({
          title: localize("Chat.ReferenceTitle"),
          subtitle: buildCardSubtitle(item.name, levelName),
          imageUrl: item.imageUrl,
          imageResolver: item.imageUrl
            ? null
            : async () => loadCatalogImageUrl(item.imagePath),
          description: item.description,
          speakerUser: game.user
        });
      } catch (error) {
        notifyError(error, localize("Notification.CardOutputFailed"));
      }
    });

    html.find('[data-action="info"]').on("click", (event) => {
      const item = this._findItem(event);
      if (!item) return;

      if (!isValidCardRef(item)) {
        return notifyWarn(localize("Notification.BadCatalogCardNumber"));
      }

      new KriptaCardDetailsApp({ level: item.level, number: item.number }).render(true);
    });

    html.find('[data-action="give"]').on("click", async (event) => {
      const item = this._findItem(event);
      if (!item) return;

      if (!isValidCardRef(item)) {
        return notifyWarn(localize("Notification.BadCatalogCardNumberForGive"));
      }

      const bindings = getBindings();
      const rows = Object.entries(bindings).map(([foundryUserId, binding]) => ({
        foundryUserId,
        foundryUserName: game.users.get(foundryUserId)?.name ?? binding.name ?? foundryUserId,
        guid: binding.guid
      })).filter((entry) => entry.guid);

      const dialogResult = await chooseBoundUserDialog(rows);

      if (dialogResult?.action !== "confirm") return;

      const foundryUserId = String(dialogResult?.foundryUserId ?? "");
      if (!foundryUserId) return notifyWarn(localize("Notification.PlayerNotSelected"));

      const binding = bindings[foundryUserId];
      if (!binding?.guid) return notifyWarn(localize("Notification.PlayerBindingMissing"));

      new KriptaGiveCardDialog({
        playerGuid: binding.guid,
        ownerFoundryUserId: foundryUserId,
        playerName: game.users.get(foundryUserId)?.name ?? binding.name ?? "",
        initialLevel: item.level,
        initialNumber: item.number
      }).render(true);
    });

    html.find(".kripta-card-tile").on("click", (event) => {
      if ($(event.target).closest("button").length) return;

      const card = event.currentTarget.closest("[data-card-key]")?.dataset?.cardKey;
      if (!card) return;

      const [level, number] = card.split(":").map(Number);
      const ref = { level, number };

      if (!isValidCardRef(ref)) {
        return notifyWarn(localize("Notification.BadCatalogCardNumber"));
      }

      new KriptaCardDetailsApp(ref).render(true);
    });
  }

  _applySidebarWidth(browser, sidebar, rawWidth = this.sidebarWidthPx) {
    if (!browser || !sidebar) return;

    const browserWidth = browser.clientWidth || this.position?.width || this.options?.width || 1040;
    const defaultWidth = Math.max(SIDEBAR_MIN_WIDTH, Math.round(browserWidth * 0.2));
    const maxWidth = Math.max(SIDEBAR_MIN_WIDTH, browserWidth - MAIN_MIN_WIDTH - RESIZER_WIDTH);
    const nextWidth = clamp(Number(rawWidth) || defaultWidth, SIDEBAR_MIN_WIDTH, maxWidth);

    this.sidebarWidthPx = nextWidth;

    browser.style.setProperty("--kripta-sidebar-width", `${nextWidth}px`);
    browser.style.gridTemplateColumns = `${nextWidth}px ${RESIZER_WIDTH}px minmax(${MAIN_MIN_WIDTH}px, 1fr)`;

    sidebar.style.width = `${nextWidth}px`;
    sidebar.style.minWidth = `${nextWidth}px`;
    sidebar.style.maxWidth = `${nextWidth}px`;
  }

  _setupSidebarResize(html) {
    const root = this.element?.[0] ?? html?.[0];
    const browser = root?.querySelector(".kripta-browser--resizable");
    const sidebar = browser?.querySelector(".kripta-browser__sidebar");
    const divider = browser?.querySelector('[data-action="resize-sidebar"]');

    if (!browser || !sidebar || !divider) {
      requestAnimationFrame(() => {
        const retryRoot = this.element?.[0];
        const retryBrowser = retryRoot?.querySelector(".kripta-browser--resizable");
        const retrySidebar = retryBrowser?.querySelector(".kripta-browser__sidebar");
        const retryDivider = retryBrowser?.querySelector('[data-action="resize-sidebar"]');

        if (!retryBrowser || !retrySidebar || !retryDivider) return;

        this._bindSidebarResize(retryBrowser, retrySidebar, retryDivider);
      });
      return;
    }

    this._bindSidebarResize(browser, sidebar, divider);
  }

  _bindSidebarResize(browser, sidebar, divider) {
    this._applySidebarWidth(browser, sidebar, this.sidebarWidthPx);

    if (!this._sidebarResizeWindowHandler) {
      this._sidebarResizeWindowHandler = () => {
        const root = this.element?.[0];
        const nextBrowser = root?.querySelector(".kripta-browser--resizable");
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
          await setUiPref("catalogSidebarWidthPx", this.sidebarWidthPx);
        } catch (error) {
          console.warn("KRIPTA catalog sidebar width save failed", error);
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
    if (!item || !isValidCardRef(item)) return;

    const imageContainer = cardElement.classList.contains("kripta-card-tile")
      ? cardElement.querySelector(".kripta-card-tile__image-wrap")
      : cardElement.querySelector(".kripta-row-card__image");

    if (!imageContainer || imageContainer.querySelector("img")) return;

    const imageUrl = item.imageUrl || await loadCatalogImageUrl(item.imagePath);
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
    img.alt = item.nameText ?? stripHtml(item.name);

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
