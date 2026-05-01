import { MODULE_ID, SETTINGS } from "./constants.js";
import { KriptaSettingsApp } from "./apps/settings-app.js";

function canManageKriptaSettings(user = game.user) {
  return Number(user?.role ?? 0) >= Number(CONST.USER_ROLES.ASSISTANT ?? 3);
}

function removeKriptaSettingsMenuEntry(_app, html) {
  if (canManageKriptaSettings()) return;

  const root = html?.[0] ?? html;
  if (!root?.querySelectorAll) return;

  const menuKey = `${MODULE_ID}.connection-settings`;
  const selectors = [
    `[data-key="${menuKey}"]`,
    `[data-action="submenu"][data-key="${menuKey}"]`,
    `[name="${menuKey}"]`
  ];

  for (const selector of selectors) {
    root.querySelectorAll(selector).forEach((element) => {
      const row =
        element.closest(".form-group") ||
        element.closest(".settings-list li") ||
        element.closest("li") ||
        element.closest("section") ||
        element;

      row.remove();
    });
  }
}

export function registerSettings() {
  game.settings.register(MODULE_ID, SETTINGS.SERVER_URL, {
    name: "Адрес сервера",
    scope: "world",
    config: false,
    type: String,
    default: ""
  });

  game.settings.register(MODULE_ID, SETTINGS.TECH_AUTH_USERS, {
    name: "Тех.пользователи",
    scope: "world",
    config: false,
    type: Object,
    default: {
      writer: { id: "", key: "" },
      reader: { id: "", key: "" }
    }
  });

  game.settings.register(MODULE_ID, SETTINGS.PLAYER_BINDINGS, {
    name: "Привязки участников к игрокам сервера",
    scope: "world",
    config: false,
    type: Object,
    default: {}
  });

  game.settings.register(MODULE_ID, SETTINGS.UI_PREFS, {
    name: "Локальные настройки интерфейса",
    scope: "client",
    config: false,
    type: Object,
    default: {
      myCardsViewMode: "tiles",
      catalogViewMode: "tiles"
    }
  });

  game.settings.registerMenu(MODULE_ID, "connection-settings", {
    name: "Карточки Крипты",
    label: "Настройка модуля",
    hint: "Подключение к API и технические пользователи.",
    icon: "fas fa-id-card",
    type: KriptaSettingsApp,
    restricted: false
  });

  Hooks.on("renderSettingsConfig", removeKriptaSettingsMenuEntry);
  Hooks.on("renderSettings", removeKriptaSettingsMenuEntry);
}