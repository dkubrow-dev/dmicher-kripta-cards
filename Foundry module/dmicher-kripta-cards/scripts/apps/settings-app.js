import { KriptaApiClient } from "../api/client.js";
import { AUTHOR_THANKS_URL, MODULE_ID, TEMPLATE_ROOT } from "../constants.js";
import { getServerUrl, getTechUsers, notifyError, notifyInfo, notifyWarn, setServerUrl, setTechUsers } from "../helpers/utils.js";

function canManageKriptaSettings(user = game.user) {
  return Number(user?.role ?? 0) >= Number(CONST.USER_ROLES.ASSISTANT ?? 3);
}

function stringifyServerResult(result) {
  if (result === null || result === undefined) return "";

  if (typeof result === "string") {
    return result.trim();
  }

  if (typeof result === "object") {
    const entries = Object.entries(result)
      .filter(([, value]) => value !== undefined && value !== null && value !== "")
      .map(([key, value]) => `${key}: ${value}`);

    if (entries.length) return entries.join(" ");

    try {
      return JSON.stringify(result);
    } catch (_error) {
      return String(result);
    }
  }

  return String(result).trim();
}

function formatServerSuccessMessage(result) {
  const tail = stringifyServerResult(result);
  return tail ? `Успешное подключение. ${tail}` : "Успешное подключение.";
}

function formatServerCheckError(error, rawServerUrl = "") {
  const rawMessage = String(error?.message ?? error ?? "").trim();
  const normalizedUrl = String(rawServerUrl ?? "").trim();

  if (
    /Failed to construct/i.test(rawMessage) ||
    /Invalid base URL/i.test(rawMessage) ||
    /Invalid URL/i.test(rawMessage) ||
    /not a valid URL/i.test(rawMessage) ||
    /URL constructor/i.test(rawMessage)
  ) {
    if (normalizedUrl) {
      return `URL constructor: ${normalizedUrl} is not a valid URL`;
    }
    return rawMessage || "Invalid URL";
  }

  if (
    /Failed to fetch/i.test(rawMessage) ||
    /NetworkError/i.test(rawMessage) ||
    /Load failed/i.test(rawMessage) ||
    /fetch resource/i.test(rawMessage) ||
    /ERR_CONNECTION_REFUSED/i.test(rawMessage) ||
    /ERR_CONNECTION_RESET/i.test(rawMessage) ||
    /ERR_NAME_NOT_RESOLVED/i.test(rawMessage) ||
    /ERR_CERT/i.test(rawMessage)
  ) {
    return "Не удалось подключиться к серверу. Проверьте адрес, доступность сервера и настройки CORS/HTTPS.";
  }

  return rawMessage || "Не удалось проверить сервер.";
}

function tryExtractJsonMessage(text) {
  const normalized = String(text ?? "").trim();
  if (!normalized) return "";

  try {
    const parsed = JSON.parse(normalized);

    if (parsed && typeof parsed === "object") {
      if (typeof parsed.message === "string" && parsed.message.trim()) {
        return parsed.message.trim();
      }

      if (typeof parsed.title === "string" && parsed.title.trim()) {
        return parsed.title.trim();
      }
    }
  } catch (_error) {
    // ignore
  }

  const jsonCandidateMatch = normalized.match(/(\{.*\})$/);
  if (jsonCandidateMatch) {
    try {
      const parsed = JSON.parse(jsonCandidateMatch[1]);

      if (parsed && typeof parsed === "object") {
        if (typeof parsed.message === "string" && parsed.message.trim()) {
          return parsed.message.trim();
        }

        if (typeof parsed.title === "string" && parsed.title.trim()) {
          return parsed.title.trim();
        }
      }
    } catch (_error) {
      // ignore
    }
  }

  return normalized;
}

function normalizeApiErrorText(error) {
  const rawMessage = String(error?.message ?? error ?? "").trim();
  if (!rawMessage) return "unknown error";

  const apiMatch = rawMessage.match(/^api\s+(\d+)\s*:\s*(.+)$/i);
  if (apiMatch) {
    const code = apiMatch[1];
    const payload = tryExtractJsonMessage(apiMatch[2]);
    return `api ${code}: ${payload}`;
  }

  return tryExtractJsonMessage(rawMessage);
}

function formatTechUserCheckError(stageLabel, error) {
  return `${stageLabel}: ${normalizeApiErrorText(error)}`;
}

function openAuthorThanksPage() {
  const url = String(AUTHOR_THANKS_URL ?? "").trim();

  if (!url) {
    ui.notifications.warn("Ссылка для кнопки «Сказать спасибо автору» не настроена.");
    return;
  }

  window.open(url, "_blank", "noopener,noreferrer");
}

export class KriptaSettingsApp extends FormApplication {
  static get defaultOptions() {
    return foundry.utils.mergeObject(super.defaultOptions, {
      id: `${MODULE_ID}-settings`,
      title: "Карточки Крипты - настройки",
      template: `${TEMPLATE_ROOT}/settings-app.hbs`,
      classes: [MODULE_ID, "sheet"],
      width: 620,
      height: "auto",
      closeOnSubmit: false,
      submitOnChange: false,
      submitOnClose: false
    });
  }

  async _render(force, options) {
    if (!canManageKriptaSettings()) {
      notifyWarn("Раздел настроек «Карточки крипты» доступен только ролям «Ведущий» и «Ассистент ведущего».");
      return this;
    }

    return super._render(force, options);
  }

  async getData() {
    const users = getTechUsers();
    return {
      serverUrl: getServerUrl(),
      writerId: users.writer?.id ?? "",
      writerKey: users.writer?.key ?? "",
      readerId: users.reader?.id ?? "",
      readerKey: users.reader?.key ?? ""
    };
  }

  activateListeners(html) {
    super.activateListeners(html);

    let thanksButton = html.find('[data-action="thanks-author"]');

    if (!thanksButton.length) {
      const footer = html.find("footer.sheet-footer, .sheet-footer").first();

      if (footer.length) {
        const submitButton = footer.find('button[type="submit"]').first();
        const injectedButton = $(`
          <button type="button" data-action="thanks-author">
            <i class="fas fa-heart"></i>
            Сказать спасибо автору
          </button>
        `);

        if (submitButton.length) {
          injectedButton.insertBefore(submitButton);
        } else {
          footer.append(injectedButton);
        }

        thanksButton = injectedButton;
      }
    }

    thanksButton.on("click", (event) => {
      event.preventDefault();
      openAuthorThanksPage();
    });

    html.find('[data-action="test-server"]').on("click", async (event) => {
      event.preventDefault();

      if (!canManageKriptaSettings()) {
        notifyWarn("Раздел настроек «Карточки крипты» доступен только ролям «Ведущий» и «Ассистент ведущего».");
        return;
      }

      const rawServerUrl = String(html.find('[name="serverUrl"]').val() ?? "").trim();

      await this._persistFromHtml(html);

      try {
        const result = await KriptaApiClient.healthCheck();
        notifyInfo(formatServerSuccessMessage(result));
      } catch (error) {
        notifyError(new Error(formatServerCheckError(error, rawServerUrl)), "Проверка сервера не удалась");
      }
    });

    html.find('[data-action="test-auth"]').on("click", async (event) => {
      event.preventDefault();

      if (!canManageKriptaSettings()) {
        notifyWarn("Раздел настроек «Карточки крипты» доступен только ролям «Ведущий» и «Ассистент ведущего».");
        return;
      }

      await this._persistFromHtml(html);

      try {
        await KriptaApiClient.checkMe();
      } catch (error) {
        const message = formatTechUserCheckError("Читатель", error);
        ui.notifications.error(message);
        console.error(message);
        return;
      }

      try {
        await KriptaApiClient.testWriterAccess();
      } catch (error) {
        const message = formatTechUserCheckError("Писатель", error);
        ui.notifications.error(message);
        console.error(message);
        return;
      }

      notifyInfo("Reader и Writer успешно проходят проверку.");
    });
  }

  async _persistFromHtml(html) {
    if (!canManageKriptaSettings()) return;

    const payload = {
      serverUrl: html.find('[name="serverUrl"]').val(),
      writer: {
        id: html.find('[name="writerId"]').val(),
        key: html.find('[name="writerKey"]').val()
      },
      reader: {
        id: html.find('[name="readerId"]').val(),
        key: html.find('[name="readerKey"]').val()
      }
    };

    await setServerUrl(payload.serverUrl);
    await setTechUsers({
      writer: payload.writer,
      reader: payload.reader
    });
  }

  async _updateObject(_event, formData) {
    if (!canManageKriptaSettings()) {
      notifyWarn("Раздел настроек «Карточки крипты» доступен только ролям «Ведущий» и «Ассистент ведущего».");
      return;
    }

    const expanded = foundry.utils.expandObject(formData);

    await setServerUrl(expanded.serverUrl);
    await setTechUsers({
      writer: { id: expanded.writerId ?? "", key: expanded.writerKey ?? "" },
      reader: { id: expanded.readerId ?? "", key: expanded.readerKey ?? "" }
    });

    notifyInfo("Настройки подключения сохранены.");
  }
}