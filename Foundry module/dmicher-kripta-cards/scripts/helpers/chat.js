import { CHAT_ACTIONS, MODULE_ID } from "../constants.js";
import { sanitizeCardHtml, stripHtml } from "./html-sanitizer.js";
import { escapeHtml } from "./utils.js";

export function getActionPayloadFromElement(element) {
  try {
    const raw = element?.dataset?.payload;
    return raw ? JSON.parse(decodeURIComponent(raw)) : null;
  } catch (error) {
    console.error(error);
    return null;
  }
}

export function createActionButtonHtml(action, decision, label, payload, cssClass = "") {
  const encodedPayload = encodeURIComponent(JSON.stringify(payload));
  return `<button type="button" class="kripta-chat-button ${cssClass}" data-kripta-action="${action}" data-kripta-decision="${decision}" data-payload="${encodedPayload}">${escapeHtml(label)}</button>`;
}

function blobToDataUrl(blob) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(String(reader.result || ""));
    reader.onerror = () => reject(reader.error || new Error("Не удалось прочитать blob"));
    reader.readAsDataURL(blob);
  });
}

async function normalizeChatImageUrl(imageUrl) {
  const raw = String(imageUrl ?? "").trim();
  if (!raw) return "";

  if (raw.startsWith("data:")) return raw;
  if (raw.startsWith("http://") || raw.startsWith("https://")) return raw;

  if (raw.startsWith("blob:")) {
    try {
      const response = await fetch(raw);
      const blob = await response.blob();
      return await blobToDataUrl(blob);
    } catch (error) {
      console.warn("kripta chat image normalize failed", { imageUrl: raw, error });
      return "";
    }
  }

  return raw;
}

function detectCreatedRollMode(chatData) {
  const whisper = Array.isArray(chatData?.whisper) ? chatData.whisper : [];

  if (chatData?.blind) {
    return CONST.DICE_ROLL_MODES.BLIND;
  }

  if (!whisper.length) {
    return CONST.DICE_ROLL_MODES.PUBLIC;
  }

  if (whisper.length === 1 && whisper[0] === game.user.id) {
    return CONST.DICE_ROLL_MODES.SELF;
  }

  return CONST.DICE_ROLL_MODES.PRIVATE;
}

function buildKriptaChatContent({
  title,
  subtitle = "",
  imageUrl = "",
  description = "",
  footerHtml = "",
  buttonsHtml = ""
}) {
  const safeDescription = sanitizeCardHtml(description);
  const safeSubtitle = sanitizeCardHtml(subtitle);
  const safeFooter = sanitizeCardHtml(footerHtml);
  const imageAlt = escapeHtml(stripHtml(subtitle) || String(title ?? ""));

  return `
    <div class="kripta-chat-card">
      <div class="kripta-chat-card__title">${escapeHtml(title)}</div>
      ${safeSubtitle ? `<div class="kripta-chat-card__subtitle">${safeSubtitle}</div>` : ""}
      ${imageUrl ? `<div class="kripta-chat-card__image-wrap"><img class="kripta-chat-card__image" src="${imageUrl}" alt="${imageAlt}"></div>` : ""}
      ${safeDescription ? `<div class="kripta-chat-card__description">${safeDescription}</div>` : ""}
      ${buttonsHtml ? `<div class="kripta-chat-card__actions">${buttonsHtml}</div>` : ""}
      ${safeFooter ? `<div class="kripta-chat-card__footer">${safeFooter}</div>` : ""}
    </div>
  `;
}

export function buildCardSubtitle(cardName, levelName = "") {
  const normalizedLevelName = String(levelName ?? "").trim();
  const suffix = normalizedLevelName ? ` (${escapeHtml(normalizedLevelName)})` : "";
  return `${String(cardName ?? "")}${suffix}`;
}

export function buildCardReceiveSubtitle({ playerName = "", cardName = "", levelName = "" } = {}) {
  const normalizedPlayerName = String(playerName ?? "").trim() || "игрок";
  return `Игрок ${escapeHtml(normalizedPlayerName)} получает карточку ${buildCardSubtitle(cardName, levelName)}`;
}

async function resolveChatImageUrl({ imageUrl = "", imageResolver = null }) {
  try {
    let resolvedUrl = "";

    if (typeof imageResolver === "function") {
      resolvedUrl = await imageResolver();
    }

    if (!resolvedUrl) {
      resolvedUrl = imageUrl;
    }

    return await normalizeChatImageUrl(resolvedUrl);
  } catch (error) {
    console.warn("kripta chat image resolve failed", error);
    return "";
  }
}

async function hydrateCreatedChatMessageImage(message, contentPayload, imagePayload) {
  try {
    const safeImageUrl = await resolveChatImageUrl(imagePayload);
    if (!safeImageUrl) return;

    await message.update({
      content: buildKriptaChatContent({
        ...contentPayload,
        imageUrl: safeImageUrl
      })
    });
  } catch (error) {
    console.warn("kripta chat message image hydrate failed", error);
  }
}

export async function createKriptaChatMessage({
  title,
  subtitle = "",
  imageUrl = "",
  imageResolver = null,
  description = "",
  footerHtml = "",
  speakerUser = game.user,
  buttonsHtml = "",
  whisper = null,
  flags = {}
}) {
  const speaker = ChatMessage.getSpeaker({ user: speakerUser });

  const contentPayload = {
    title,
    subtitle,
    description,
    footerHtml,
    buttonsHtml
  };

  const chatData = {
    user: game.user.id,
    speaker,
    style: CONST.CHAT_MESSAGE_STYLES.OTHER,
    content: buildKriptaChatContent({
      ...contentPayload,
      imageUrl: ""
    }),
    flags: {
      [MODULE_ID]: flags
    }
  };

  let createRollMode = CONST.DICE_ROLL_MODES.PUBLIC;

  if (Array.isArray(whisper)) {
    chatData.whisper = whisper;
    chatData.blind = false;
    chatData.rollMode = CONST.DICE_ROLL_MODES.PRIVATE;
    createRollMode = CONST.DICE_ROLL_MODES.PRIVATE;
  } else {
    const applyMode =
      ChatMessage.applyMode ||
      ChatMessage.applyRollMode ||
      ChatMessage.implementation?.applyMode ||
      ChatMessage.implementation?.applyRollMode;

    if (typeof applyMode === "function") {
      applyMode.call(ChatMessage, chatData);
    }

    createRollMode = detectCreatedRollMode(chatData);
    chatData.rollMode = createRollMode;
  }

  const created = await ChatMessage.create(chatData, { rollMode: createRollMode });

  if (imageUrl || typeof imageResolver === "function") {
    void hydrateCreatedChatMessageImage(
      created,
      contentPayload,
      { imageUrl, imageResolver }
    );
  }

  return created;
}

export async function createCardRequestMessage({
  playerGuid,
  ownerFoundryUserId,
  level,
  number,
  playerName,
  title,
  cardName = "",
  levelName,
  imageUrl,
  imageResolver = null,
  description,
  footerHtml = "",
  speakerUser = game.user
}) {
  const payload = {
    playerGuid,
    ownerFoundryUserId,
    playerName,
    level,
    number
  };

  const buttonsHtml = [
    createActionButtonHtml(CHAT_ACTIONS.REQUEST_CARD, "confirm", "Подтвердить", payload, "is-confirm"),
    createActionButtonHtml(CHAT_ACTIONS.REQUEST_CARD, "cancel", "Отменить", payload, "is-cancel")
  ].join("");

  const subtitleLevelName = String(levelName ?? "").trim() || String(level ?? "");

  return createKriptaChatMessage({
    title,
    subtitle: buildCardSubtitle(cardName, subtitleLevelName),
    imageUrl,
    imageResolver,
    description,
    footerHtml,
    speakerUser,
    buttonsHtml,
    flags: {
      type: CHAT_ACTIONS.REQUEST_CARD,
      payload
    }
  });
}
