export const MODULE_ID = "dmicher-kripta-cards";

export const SETTINGS = {
  SERVER_URL: "server-url",
  TECH_AUTH_USERS: "tech-auth-users",
  PLAYER_BINDINGS: "kripta-cards-players",
  UI_PREFS: "ui-prefs"
};

export const ROLES = {
  READER: "reader",
  WRITER: "writer"
};

export const VIEW_MODES = {
  TABLE: "table",
  TILES: "tiles"
};

export const CHAT_ACTIONS = {
  REQUEST_CARD: "request-card"
};

export const DEFAULT_UI_PREFS = {
  myCardsViewMode: VIEW_MODES.TILES,
  catalogViewMode: VIEW_MODES.TILES
};

export const TEMPLATE_ROOT = `modules/${MODULE_ID}/templates`;

export const SERVER_DOWNLOAD_URL = "https://github.com/dkubrow-dev/dmicher-kripta-cards/releases/download/1.2.0/kripta-cards-content-server-1.2.0.zip";
export const AUTHOR_THANKS_URL = "https://boosty.to/dmicher";
export const DOCUMENTATION_ROOT = `modules/${MODULE_ID}/assets/docs`;
export const DOCUMENTATION_FILES = Object.freeze({
  SETUP_GUIDE: "setup-guide",
  CONTENT_CREATION_GUIDE: "content-creation-guide"
});
