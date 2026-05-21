import { KriptaApiClient } from "./api/client.js";
import { MODULE_ID, CHAT_ACTIONS } from "./constants.js";
import { buildCardReceiveSubtitle, createKriptaChatMessage, getActionPayloadFromElement } from "./helpers/chat.js";
import { localize } from "./helpers/lang.js";
import {
  getBinding,
  getServerUrl,
  getTechUsers,
  notifyError,
  notifyInfo,
  notifyWarn
} from "./helpers/utils.js";
import { KriptaCatalogApp } from "./apps/catalog-app.js";
import { KriptaMyCardsApp } from "./apps/my-cards-app.js";
import { KriptaPlayersApp } from "./apps/players-app.js";
import { KriptaRequestCardDialog } from "./apps/request-card-dialog.js";
import { registerSettings } from "./settings.js";

const ZERO_GUID = "00000000-0000-0000-0000-000000000000";
const MENU_ROOT_TOOL = "menu-root";

function normalizeGuidCandidate(value) {
  if (!value) return "";
  const stringValue = String(value).trim();
  if (!stringValue || stringValue === ZERO_GUID) return "";
  return stringValue;
}

function getPlayerGuidFromBinding(foundryUserId) {
  const binding = getBinding(foundryUserId);
  return (
    normalizeGuidCandidate(binding?.guid) ||
    normalizeGuidCandidate(binding?.playerGuid) ||
    normalizeGuidCandidate(binding?.id) ||
    ""
  );
}

async function resolvePlayerGuid(payload) {
  const explicitGuid =
    normalizeGuidCandidate(payload?.playerGuid) ||
    normalizeGuidCandidate(payload?.guid) ||
    normalizeGuidCandidate(payload?.id);

  if (explicitGuid) return explicitGuid;

  const bindingGuid = getPlayerGuidFromBinding(payload?.ownerFoundryUserId);
  if (bindingGuid) return bindingGuid;

  const ownerUser = game.users.get(payload?.ownerFoundryUserId);
  const ownerName = String(payload?.playerName ?? ownerUser?.name ?? "").trim().toLowerCase();

  if (!ownerName) return "";

  const players = await KriptaApiClient.getPlayersList();
  const matched = players.find((player) => {
    const playerName = String(player?.name ?? "").trim().toLowerCase();
    return playerName === ownerName;
  });

  return (
    normalizeGuidCandidate(matched?.guid) ||
    normalizeGuidCandidate(matched?.playerGuid) ||
    normalizeGuidCandidate(matched?.id) ||
    ""
  );
}

function hasKriptaTechUserCredentials(user) {
  return !!String(user?.id ?? "").trim() && !!String(user?.key ?? "").trim();
}

function ensureKriptaMenuSettings() {
  const serverUrl = String(getServerUrl() ?? "").trim();
  const users = getTechUsers();

  if (!serverUrl) {
    throw new Error(localize("Error.MissingServerUrl"));
  }

  if (!hasKriptaTechUserCredentials(users?.reader)) {
    throw new Error(localize("Error.InvalidReader"));
  }

  if (!hasKriptaTechUserCredentials(users?.writer)) {
    throw new Error(localize("Error.InvalidWriter"));
  }
}

function notifyKriptaMenuUnavailable(error) {
  console.error("KRIPTA menu open failed", error);
  ui.notifications.error(localize("Error.MenuUnavailable"));
}

async function openKriptaMenuWindow(openWindow) {
  try {
    ensureKriptaMenuSettings();

    await KriptaApiClient.checkMe();
    await KriptaApiClient.testWriterAccess();

    openWindow();
  } catch (error) {
    notifyKriptaMenuUnavailable(error);
  }
}

Hooks.once("init", () => {
  registerSettings();
  Handlebars.registerHelper("eq", (a, b) => a === b);
});

Hooks.once("ready", () => {
  const module = game.modules.get(MODULE_ID);
  if (module) module.api = { KriptaApiClient };
});

Hooks.on("getSceneControlButtons", (controls) => {
  controls[MODULE_ID] = {
    name: MODULE_ID,
    title: localize("Menu.Title"),
    icon: "fas fa-id-card",
    order: 90,
    visible: true,
    activeTool: MENU_ROOT_TOOL,
    tools: {
      [MENU_ROOT_TOOL]: {
        name: MENU_ROOT_TOOL,
        title: localize("Menu.Title"),
        icon: "fas fa-id-card",
        order: -1,
        button: false,
        visible: false,
        onChange: () => {}
      },
      catalog: {
        name: "catalog",
        title: localize("Menu.Catalog"),
        icon: "fas fa-book-open",
        order: 0,
        button: true,
        visible: true,
        onChange: () => {
          openKriptaMenuWindow(() => {
            new KriptaCatalogApp().render(true);
          });
        }
      },
      "get-card": {
        name: "get-card",
        title: localize("Menu.GetCard"),
        icon: "fas fa-hand-holding-medical",
        order: 1,
        button: true,
        visible: true,
        onChange: () => {
          const binding = getBinding(game.user.id);
          const playerGuid = binding?.guid ?? binding?.playerGuid ?? "";

          if (!playerGuid) {
            notifyWarn(localize("NoBinding"));
            return;
          }

          openKriptaMenuWindow(() => {
            new KriptaRequestCardDialog({
              playerGuid,
              ownerFoundryUserId: game.user.id
            }).render(true);
          });
        }
      },
      "my-cards": {
        name: "my-cards",
        title: localize("Menu.MyCards"),
        icon: "fas fa-images",
        order: 2,
        button: true,
        visible: true,
        onChange: () => {
          const binding = getBinding(game.user.id);
          const playerGuid = binding?.guid ?? binding?.playerGuid ?? "";

          if (!playerGuid) {
            notifyWarn(localize("NoBinding"));
            return;
          }

          openKriptaMenuWindow(() => {
            new KriptaMyCardsApp({
              playerGuid,
              playerName: game.user.name,
              ownerFoundryUserId: game.user.id
            }).render(true);
          });
        }
      },
      players: {
        name: "players",
        title: localize("Menu.Players"),
        icon: "fas fa-users-cog",
        order: 3,
        button: true,
        visible: game.user.isGM,
        onChange: () => {
          openKriptaMenuWindow(() => {
            new KriptaPlayersApp().render(true);
          });
        }
      }
    }
  };
});

Hooks.on("renderChatMessageHTML", (message, html) => {
  const actionButtons = html.querySelectorAll("[data-kripta-action]");

  for (const element of actionButtons) {
    if (!game.user.isGM) {
      element.style.display = "none";
    }

    element.addEventListener("click", async (event) => {
      event.preventDefault();

      if (!game.user.isGM) {
        notifyWarn(localize("GMOnly"));
        return;
      }

      const target = event.currentTarget;
      const action = target.dataset.kriptaAction;
      if (action !== CHAT_ACTIONS.REQUEST_CARD) return;

      const payload = getActionPayloadFromElement(target);
      const decision = target.dataset.kriptaDecision;

      if (!payload) {
        notifyWarn(localize("Chat.CardRequestPayloadUnreadable"));
        return;
      }

      if (decision === "cancel") {
        await message.delete();
        notifyInfo(localize("Chat.CardRequestCanceled"));
        return;
      }

      try {
        const resolvedPlayerGuid = await resolvePlayerGuid(payload);

        if (!resolvedPlayerGuid) {
          throw new Error(localize("Error.MissingRequestPlayerGuid"));
        }

        await KriptaApiClient.giveCard(
          resolvedPlayerGuid,
          payload.level,
          payload.number,
          1
        );

        await message.delete();

        const [meta, levels] = await Promise.all([
            KriptaApiClient.getCardMeta(payload.level, payload.number),
            KriptaApiClient.getLevelsList()
        ]);

        const blob = await KriptaApiClient.getCardImageBlob(meta.imagePath).catch(() => null);
        const imageUrl = blob ? URL.createObjectURL(blob) : "";
        const ownerUser = game.users.get(payload.ownerFoundryUserId);
        const levelName = levels.find((item) => Number(item.id) === Number(payload.level))?.name ?? String(payload.level);

        await createKriptaChatMessage({
          title: localize("Chat.CardRequestConfirmedTitle"),
          subtitle: buildCardReceiveSubtitle({
            playerName: ownerUser?.name ?? payload.playerName ?? localize("Chat.FallbackPlayer"),
            cardName: meta.name,
            levelName
          }),
          imageUrl,
          description: meta.description,
          speakerUser: game.user
        });

        notifyInfo(localize("Notification.CardGiven"));
      } catch (error) {
        notifyError(error, localize("Notification.CardRequestConfirmFailed"));
      }
    });
  }
});
