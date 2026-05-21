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
    name: "KRIPTA.Settings.ServerUrl.Name",
    scope: "world",
    config: false,
    type: String,
    default: ""
  });

  game.settings.register(MODULE_ID, SETTINGS.TECH_AUTH_USERS, {
    name: "KRIPTA.Settings.TechAuthUsers.Name",
    scope: "world",
    config: false,
    type: Object,
    default: {
      writer: { id: "", key: "" },
      reader: { id: "", key: "" }
    }
  });

  game.settings.register(MODULE_ID, SETTINGS.PLAYER_BINDINGS, {
    name: "KRIPTA.Settings.PlayerBindings.Name",
    scope: "world",
    config: false,
    type: Object,
    default: {}
  });

  game.settings.register(MODULE_ID, SETTINGS.UI_PREFS, {
    name: "KRIPTA.Settings.UiPrefs.Name",
    scope: "client",
    config: false,
    type: Object,
    default: {
      myCardsViewMode: "tiles",
      catalogViewMode: "tiles"
    }
  });

  game.settings.registerMenu(MODULE_ID, "connection-settings", {
    name: "KRIPTA.Settings.Menu.Name",
    label: "KRIPTA.Settings.Menu.Label",
    hint: "KRIPTA.Settings.Menu.Hint",
    icon: "fas fa-id-card",
    type: KriptaSettingsApp,
    restricted: false
  });

  Hooks.on("renderSettingsConfig", removeKriptaSettingsMenuEntry);
  Hooks.on("renderSettings", removeKriptaSettingsMenuEntry);
}
