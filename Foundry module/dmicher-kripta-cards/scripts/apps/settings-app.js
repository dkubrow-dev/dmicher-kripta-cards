import { KriptaApiClient } from "../api/client.js";
import { MODULE_ID, RELEASES_SITE_URL, TEMPLATE_ROOT } from "../constants.js";
import { format, localize } from "../helpers/lang.js";
import { getServerUrl, getTechUsers, notifyError, notifyInfo, notifyWarn, setServerUrl, setTechUsers } from "../helpers/utils.js";

function canManageKriptaSettings(user = game.user) {
  return Number(user?.role ?? 0) >= Number(CONST.USER_ROLES.ASSISTANT ?? 3);
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
      return format("Notification.InvalidServerUrl", { url: normalizedUrl });
    }
    return localize("Notification.ServerCheckFailedFallback");
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
    return localize("Notification.ServerConnectionFailed");
  }

  return localize("Notification.ServerCheckFailedFallback");
}

function formatTechUserCheckError(stageLabel, fallback) {
  return `${stageLabel}: ${fallback}`;
}

function getSiteLocale() {
  const lang = String(game.i18n?.lang ?? "en").toLowerCase();
  return lang.startsWith("ru") ? "ru" : "en";
}

function getModuleVersion() {
  return String(game.modules.get(MODULE_ID)?.version ?? "").trim();
}

function buildReleasesSiteUrl(path, params = {}) {
  const baseUrl = String(RELEASES_SITE_URL ?? "").trim();
  const url = new URL(path, baseUrl.endsWith("/") ? baseUrl : `${baseUrl}/`);

  for (const [key, value] of Object.entries(params)) {
    const normalizedValue = String(value ?? "").trim();
    if (normalizedValue) {
      url.searchParams.set(key, normalizedValue);
    }
  }

  return url.toString();
}

export class KriptaSettingsApp extends FormApplication {
  static get defaultOptions() {
    return foundry.utils.mergeObject(super.defaultOptions, {
      id: `${MODULE_ID}-settings`,
      title: localize("Window.Settings"),
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
      notifyWarn(localize("Notification.SettingsAccessDenied"));
      return this;
    }

    return super._render(force, options);
  }

  async getData() {
    const users = getTechUsers();
    return {
      serverUrl: getServerUrl(),
      serverDownloadUrl: buildReleasesSiteUrl(`/${getSiteLocale()}/downloads/server/`, { moduleVersion: getModuleVersion() }),
      serverDocumentationUrl: buildReleasesSiteUrl(`/${getSiteLocale()}/docs/server/`),
      writerId: users.writer?.id ?? "",
      writerKey: users.writer?.key ?? "",
      readerId: users.reader?.id ?? "",
      readerKey: users.reader?.key ?? ""
    };
  }

  activateListeners(html) {
    super.activateListeners(html);

    html.find('[data-action="test-server"]').on("click", async (event) => {
      event.preventDefault();

      if (!canManageKriptaSettings()) {
        notifyWarn(localize("Notification.SettingsAccessDenied"));
        return;
      }

      const rawServerUrl = String(html.find('[name="serverUrl"]').val() ?? "").trim();

      await this._persistFromHtml(html);

      try {
        await KriptaApiClient.healthCheck();
        notifyInfo(localize("Notification.ServerSuccess"));
      } catch (error) {
        notifyError(new Error(formatServerCheckError(error, rawServerUrl)), localize("Notification.ServerCheckFailed"));
      }
    });

    html.find('[data-action="test-auth"]').on("click", async (event) => {
      event.preventDefault();

      if (!canManageKriptaSettings()) {
        notifyWarn(localize("Notification.SettingsAccessDenied"));
        return;
      }

      await this._persistFromHtml(html);

      try {
        await KriptaApiClient.checkMe();
      } catch (error) {
        const message = formatTechUserCheckError(localize("Notification.TechUserReader"), localize("Error.InvalidReader"));
        ui.notifications.error(message);
        console.error(error);
        return;
      }

      try {
        await KriptaApiClient.testWriterAccess();
      } catch (error) {
        const message = formatTechUserCheckError(localize("Notification.TechUserWriter"), localize("Error.InvalidWriter"));
        ui.notifications.error(message);
        console.error(error);
        return;
      }

      notifyInfo(localize("Notification.TechUsersCheckSuccess"));
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
      notifyWarn(localize("Notification.SettingsAccessDenied"));
      return;
    }

    const expanded = foundry.utils.expandObject(formData);

    await setServerUrl(expanded.serverUrl);
    await setTechUsers({
      writer: { id: expanded.writerId ?? "", key: expanded.writerKey ?? "" },
      reader: { id: expanded.readerId ?? "", key: expanded.readerKey ?? "" }
    });

    notifyInfo(localize("Notification.SettingsSaved"));
  }
}
