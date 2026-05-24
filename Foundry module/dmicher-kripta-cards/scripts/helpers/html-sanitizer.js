import { escapeHtml } from "./utils.js";

function stripDangerousHtmlBlocks(value) {
  return String(value ?? "")
    .replace(/<\s*(script|style|iframe|object|embed|svg|math|canvas|video|audio)[^>]*>[\s\S]*?<\s*\/\s*\1\s*>/gi, " ")
    .replace(/<\s*(script|style|iframe|object|embed|svg|math|canvas|video|audio)[^>]*>/gi, " ");
}

export function stripHtml(value) {
  return stripDangerousHtmlBlocks(value).replace(/<[^>]*>/g, " ").replace(/\s+/g, " ").trim();
}

const SAFE_CARD_HTML_TAGS = new Set([
  "a",
  "b",
  "blockquote",
  "br",
  "code",
  "div",
  "em",
  "h3",
  "h4",
  "hr",
  "i",
  "li",
  "ol",
  "p",
  "pre",
  "s",
  "small",
  "span",
  "strong",
  "sub",
  "sup",
  "table",
  "tbody",
  "td",
  "th",
  "thead",
  "tr",
  "u",
  "ul"
]);

const DROP_CARD_HTML_TAGS = new Set([
  "base",
  "button",
  "canvas",
  "embed",
  "form",
  "iframe",
  "img",
  "input",
  "link",
  "math",
  "meta",
  "object",
  "option",
  "script",
  "select",
  "source",
  "style",
  "svg",
  "textarea",
  "track",
  "video"
]);

const SAFE_CARD_HTML_GLOBAL_ATTRS = new Set(["class", "style", "title"]);
const SAFE_CARD_HTML_TAG_ATTRS = {
  a: new Set(["href", "rel", "target"]),
  td: new Set(["colspan", "rowspan"]),
  th: new Set(["colspan", "rowspan"])
};

const SAFE_CARD_CSS_PROPERTIES = [
  "background",
  "background-color",
  "border",
  "border-bottom",
  "border-color",
  "border-left",
  "border-radius",
  "border-right",
  "border-style",
  "border-top",
  "border-width",
  "color",
  "display",
  "font-size",
  "font-style",
  "font-weight",
  "letter-spacing",
  "line-height",
  "margin",
  "margin-bottom",
  "margin-left",
  "margin-right",
  "margin-top",
  "padding",
  "padding-bottom",
  "padding-left",
  "padding-right",
  "padding-top",
  "text-align",
  "text-decoration",
  "vertical-align",
  "white-space"
];

const SAFE_CARD_CSS_DISPLAY_VALUES = new Set(["block", "inline", "inline-block", "list-item", "none"]);
const SAFE_LEVEL_DESCRIPTION_TAGS = new Set(["p", "b", "u", "i", "sup", "sub"]);

function sanitizeClassList(value) {
  return String(value ?? "")
    .split(/\s+/)
    .map((token) => token.trim())
    .filter((token) => /^[A-Za-z0-9_-]+$/.test(token))
    .slice(0, 32)
    .join(" ");
}

function isUnsafeCssValue(value) {
  return /url\s*\(|expression\s*\(|javascript\s*:|vbscript\s*:|@import|-moz-binding|behavior\s*:/i.test(String(value ?? ""));
}

function sanitizeInlineStyle(value) {
  if (typeof document === "undefined" || typeof document.createElement !== "function") {
    return "";
  }

  const probe = document.createElement("span");
  probe.setAttribute("style", String(value ?? ""));

  return SAFE_CARD_CSS_PROPERTIES
    .map((property) => {
      const propertyValue = probe.style.getPropertyValue(property);
      if (!propertyValue || isUnsafeCssValue(propertyValue)) return "";

      if (
        property === "display" &&
        !SAFE_CARD_CSS_DISPLAY_VALUES.has(propertyValue.trim().toLowerCase())
      ) {
        return "";
      }

      return `${property}: ${propertyValue}`;
    })
    .filter(Boolean)
    .join("; ");
}

function isSafeCardUrl(value) {
  const raw = String(value ?? "").trim();
  if (!raw) return false;

  const compact = raw.replace(/[\u0000-\u001F\u007F\s]+/g, "").toLowerCase();
  if (
    compact.startsWith("javascript:") ||
    compact.startsWith("vbscript:") ||
    compact.startsWith("data:")
  ) {
    return false;
  }

  try {
    const base = globalThis.location?.origin || "https://kripta.invalid";
    const url = new URL(raw, base);
    return ["http:", "https:", "mailto:", "tel:"].includes(url.protocol);
  } catch (_error) {
    return false;
  }
}

function sanitizeIntegerAttribute(value, min = 1, max = 99) {
  const number = Number(value);
  if (!Number.isInteger(number) || number < min || number > max) return "";
  return String(number);
}

function sanitizeCardElementAttributes(source, target, tagName) {
  for (const attr of Array.from(source.attributes ?? [])) {
    const attrName = attr.name.toLowerCase();
    const attrValue = attr.value ?? "";
    const isGlobal = SAFE_CARD_HTML_GLOBAL_ATTRS.has(attrName);
    const isTagSpecific = SAFE_CARD_HTML_TAG_ATTRS[tagName]?.has(attrName);

    if (attrName.startsWith("on") || (!isGlobal && !isTagSpecific)) continue;

    if (attrName === "class") {
      const className = sanitizeClassList(attrValue);
      if (className) target.setAttribute("class", className);
      continue;
    }

    if (attrName === "style") {
      const style = sanitizeInlineStyle(attrValue);
      if (style) target.setAttribute("style", style);
      continue;
    }

    if (attrName === "href") {
      if (isSafeCardUrl(attrValue)) target.setAttribute("href", attrValue.trim());
      continue;
    }

    if (attrName === "target") {
      const targetValue = attrValue.trim().toLowerCase();
      if (["_blank", "_self", "_parent", "_top"].includes(targetValue)) {
        target.setAttribute("target", targetValue);
      }
      continue;
    }

    if (attrName === "rel") {
      if (tagName === "a") target.setAttribute("rel", "noopener noreferrer");
      continue;
    }

    if (attrName === "colspan" || attrName === "rowspan") {
      const value = sanitizeIntegerAttribute(attrValue);
      if (value) target.setAttribute(attrName, value);
      continue;
    }

    if (attrName === "title") {
      target.setAttribute("title", attrValue);
    }
  }

  if (tagName === "a" && target.getAttribute("target") === "_blank") {
    target.setAttribute("rel", "noopener noreferrer");
  }
}

export function sanitizeCardHtml(value) {
  const raw = String(value ?? "");
  if (!raw) return "";

  if (typeof document === "undefined" || typeof document.createElement !== "function") {
    return escapeHtml(stripHtml(raw));
  }

  const source = document.createElement("template");
  source.innerHTML = raw;

  const target = document.createElement("template");

  const appendSafeNode = (node, parent) => {
    if (node.nodeType === 3) {
      parent.appendChild(document.createTextNode(node.textContent ?? ""));
      return;
    }

    if (node.nodeType !== 1) return;

    const tagName = node.tagName.toLowerCase();

    if (DROP_CARD_HTML_TAGS.has(tagName)) return;

    if (!SAFE_CARD_HTML_TAGS.has(tagName)) {
      for (const child of Array.from(node.childNodes)) {
        appendSafeNode(child, parent);
      }
      return;
    }

    const clone = document.createElement(tagName);
    sanitizeCardElementAttributes(node, clone, tagName);
    parent.appendChild(clone);

    for (const child of Array.from(node.childNodes)) {
      appendSafeNode(child, clone);
    }
  };

  for (const child of Array.from(source.content.childNodes)) {
    appendSafeNode(child, target.content);
  }

  return target.innerHTML;
}

export function sanitizeLevelDescriptionHtml(value) {
  const raw = String(value ?? "");
  if (!raw) return "";

  if (typeof document === "undefined" || typeof document.createElement !== "function") {
    return escapeHtml(stripHtml(raw));
  }

  const source = document.createElement("template");
  source.innerHTML = stripDangerousHtmlBlocks(raw);

  const target = document.createElement("template");

  const appendSafeNode = (node, parent) => {
    if (node.nodeType === 3) {
      parent.appendChild(document.createTextNode(node.textContent ?? ""));
      return;
    }

    if (node.nodeType !== 1) return;

    const tagName = node.tagName.toLowerCase();
    if (!SAFE_LEVEL_DESCRIPTION_TAGS.has(tagName)) {
      for (const child of Array.from(node.childNodes)) {
        appendSafeNode(child, parent);
      }
      return;
    }

    const clone = document.createElement(tagName);
    parent.appendChild(clone);

    for (const child of Array.from(node.childNodes)) {
      appendSafeNode(child, clone);
    }
  };

  for (const child of Array.from(source.content.childNodes)) {
    appendSafeNode(child, target.content);
  }

  return target.innerHTML;
}

export function truncateHtmlDescription(value, limit = 256) {
  const raw = String(value ?? "");
  const normalizedLimit = Math.floor(Number(limit));

  if (!raw || !Number.isFinite(normalizedLimit) || normalizedLimit <= 0) {
    return "";
  }

  if (typeof document === "undefined" || typeof document.createElement !== "function") {
    const text = stripHtml(raw);
    const preview = text.length > normalizedLimit
      ? `${text.slice(0, normalizedLimit)}...`
      : text;

    return escapeHtml(preview);
  }

  const sanitized = sanitizeCardHtml(raw);
  const source = document.createElement("template");
  source.innerHTML = sanitized;

  const fullText = source.content.textContent ?? "";
  if (fullText.length <= normalizedLimit) {
    return sanitized;
  }

  const target = document.createElement("template");
  let remaining = normalizedLimit;
  let didTruncate = false;

  const appendEllipsis = (parent) => {
    if (didTruncate) return;

    const lastChild = parent.lastChild;
    if (lastChild?.nodeType === 3) {
      lastChild.textContent = `${lastChild.textContent ?? ""}...`;
    } else {
      parent.appendChild(document.createTextNode("..."));
    }

    didTruncate = true;
  };

  const appendPreviewNode = (node, parent) => {
    if (didTruncate) return false;

    if (node.nodeType === 3) {
      const text = node.textContent ?? "";
      if (!text) return true;

      if (text.length < remaining) {
        parent.appendChild(document.createTextNode(text));
        remaining -= text.length;
        return true;
      }

      if (text.length === remaining) {
        parent.appendChild(document.createTextNode(text));
        remaining = 0;
        appendEllipsis(parent);
        return false;
      }

      parent.appendChild(document.createTextNode(`${text.slice(0, remaining)}...`));
      remaining = 0;
      didTruncate = true;
      return false;
    }

    if (node.nodeType === 1) {
      const clone = node.cloneNode(false);
      parent.appendChild(clone);

      for (const child of Array.from(node.childNodes)) {
        if (!appendPreviewNode(child, clone)) return false;
      }
    }

    return true;
  };

  for (const child of Array.from(source.content.childNodes)) {
    if (!appendPreviewNode(child, target.content)) break;
  }

  return target.innerHTML;
}
