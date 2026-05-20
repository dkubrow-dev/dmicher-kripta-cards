function firstOf(object, keys, fallback = undefined) {
  for (const key of keys) {
    if (
      object &&
      Object.prototype.hasOwnProperty.call(object, key) &&
      object[key] !== undefined &&
      object[key] !== null
    ) {
      return object[key];
    }
  }
  return fallback;
}

function firstObjectOf(object, keys, fallback = null) {
  for (const key of keys) {
    const value = object?.[key];
    if (value && typeof value === "object" && !Array.isArray(value)) {
      return value;
    }
  }
  return fallback;
}

function arrayFromUnknown(value) {
  if (Array.isArray(value)) return value;
  if (Array.isArray(value?.items)) return value.items;
  if (Array.isArray(value?.data)) return value.data;
  if (Array.isArray(value?.result)) return value.result;
  if (Array.isArray(value?.value)) return value.value;
  return [];
}

function ensureArray(value) {
  if (Array.isArray(value)) return value;
  const arr = arrayFromUnknown(value);
  if (arr.length) return arr;
  if (value && typeof value === "object" && !Array.isArray(value)) return [value];
  return [];
}

export function normalizeLevels(value) {
  return ensureArray(value)
    .map((item) => ({
      id: Number(firstOf(item, ["id", "Id", "level", "Level"], 0)),
      name: String(firstOf(item, ["name", "Name"], "")),
      description: String(firstOf(item, ["description", "Description"], ""))
    }))
    .sort((a, b) => a.id - b.id);
}

export function normalizeCardMeta(value, fallback = {}) {
  const source =
    firstObjectOf(value, ["cardMeta", "CardMeta", "rolledCard", "RolledCard", "value", "Value"], null) ??
    value;

  return {
    level: Number(firstOf(source, ["level", "Level", "cardLevel", "CardLevel"], fallback.level ?? 0)),
    number: Number(firstOf(source, ["number", "Number", "card", "Card", "cardNumber", "CardNumber"], fallback.number ?? 0)),
    name: String(firstOf(source, ["name", "Name"], fallback.name ?? "")),
    description: String(firstOf(source, ["description", "Description"], fallback.description ?? "")),
    imagePath: String(firstOf(source, ["imagePath", "ImagePath", "image", "Image", "imageUrl", "ImageUrl"], fallback.imagePath ?? fallback.image ?? "")),
  };
}

export function normalizeCardsList(value, fallbackLevel = null) {
  const cards = ensureArray(value).map((item) =>
    normalizeCardMeta(item, { level: fallbackLevel ?? 0 })
  );

  if (fallbackLevel === null || fallbackLevel === undefined) {
    return cards;
  }

  const normalizedLevel = Number(fallbackLevel);
  return cards.filter((item) => Number(item.level) === normalizedLevel);
}

function normalizePlayerCard(item) {
  return {
    guid: String(firstOf(item, ["guid", "Guid", "id", "Id"], "")),
    ownerGuid: String(firstOf(item, ["ownerGuid", "OwnerGuid"], "")),
    level: Number(firstOf(item, ["level", "Level", "cardLevel", "CardLevel"], 0)),
    number: Number(firstOf(item, ["number", "Number", "card", "Card", "cardNumber", "CardNumber"], 0)),
    count: Number(firstOf(item, ["count", "Count", "amount", "Amount", "qty", "Qty", "quantity", "Quantity"], 1))
  };
}

export function normalizePlayersList(value) {
  return ensureArray(value).map((item) => {
    const source =
      firstObjectOf(item, ["player", "Player", "value", "Value"], null) ??
      item;

    const nestedCards =
      firstOf(item, ["cardDtos", "CardDtos", "playerCards", "PlayerCards", "cards", "Cards"], null) ??
      firstOf(source, ["cardDtos", "CardDtos", "playerCards", "PlayerCards", "cards", "Cards"], []);

    return {
      guid: String(firstOf(source, ["guid", "Guid", "id", "Id"], "")),
      name: String(firstOf(source, ["name", "Name"], "")),
      comment: String(firstOf(source, ["comment", "Comment", "comments", "Comments"], "")),
      cardsCount: Number(
        firstOf(
          source,
          ["cardsCount", "CardsCount", "cardsTypesCount", "CardsTypesCount"],
          ensureArray(nestedCards).length
        )
      )
    };
  });
}

export function normalizePlayersInfo(value) {
  return ensureArray(value).map((item) => {
    const source =
      firstObjectOf(item, ["player", "Player", "value", "Value", "dto", "Dto"], null) ??
      item;

    const nestedCards =
      firstOf(
        item,
        [
          "cardDtos",
          "CardDtos",
          "playerCards",
          "PlayerCards",
          "playersCards",
          "PlayersCards",
          "cards",
          "Cards",
          "cardsList",
          "CardsList",
          "inventory",
          "Inventory"
        ],
        null
      ) ??
      firstOf(
        source,
        [
          "cardDtos",
          "CardDtos",
          "playerCards",
          "PlayerCards",
          "playersCards",
          "PlayersCards",
          "cards",
          "Cards",
          "cardsList",
          "CardsList",
          "inventory",
          "Inventory"
        ],
        []
      );

    return {
      guid: String(firstOf(source, ["guid", "Guid", "id", "Id"], "")),
      name: String(firstOf(source, ["name", "Name"], "")),
      comment: String(firstOf(source, ["comment", "Comment", "comments", "Comments"], "")),
      playerCards: ensureArray(nestedCards).map(normalizePlayerCard)
    };
  });
}

export function normalizeRollCard(value, fallbackLevel = 0) {
  const rolledCard =
    firstObjectOf(value, ["rolledCard", "RolledCard", "card", "Card", "value", "Value"], null) ??
    value;

  return normalizeCardMeta(rolledCard, {
    level: Number(firstOf(rolledCard, ["level", "Level"], firstOf(value, ["requestedCardLevel", "RequestedCardLevel"], fallbackLevel))),
    number: Number(firstOf(rolledCard, ["number", "Number", "card", "Card", "cardNumber", "CardNumber"], 0)),
    name: "",
    description: "",
    imagePath: ""
  });
}