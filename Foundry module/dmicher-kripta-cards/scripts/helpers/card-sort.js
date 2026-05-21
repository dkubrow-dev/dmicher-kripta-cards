import { stripHtml } from "./html-sanitizer.js";

const CARD_NAME_COLLATOR = new Intl.Collator("ru", {
  numeric: true,
  sensitivity: "base"
});

function compareCardNumbers(left, right) {
  const leftNumber = Number(left?.number);
  const rightNumber = Number(right?.number);

  if (Number.isFinite(leftNumber) && Number.isFinite(rightNumber)) {
    return leftNumber - rightNumber;
  }

  return String(left?.number ?? "").localeCompare(String(right?.number ?? ""));
}

export function sortCardsByName(cards) {
  if (!Array.isArray(cards)) return [];

  return [...cards].sort((left, right) => {
    const nameComparison = CARD_NAME_COLLATOR.compare(stripHtml(left?.name), stripHtml(right?.name));
    return nameComparison || compareCardNumbers(left, right);
  });
}
