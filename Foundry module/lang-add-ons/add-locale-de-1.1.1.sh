#!/usr/bin/env sh
set -eu

if [ ! -f "dmicher-kripta-cards/module.json" ]; then
  echo "Run this script from the Foundry module workspace root, next to dmicher-kripta-cards/module.json." >&2
  exit 1
fi

SCRIPT_FILE="$0"
LOCALE_PATH="dmicher-kripta-cards/lang/de.json"
mkdir -p "dmicher-kripta-cards/lang"
awk '/^__LOCALE_JSON__$/ {p=1; next} /^__END_LOCALE_JSON__$/ {p=0} p' "$SCRIPT_FILE" > "$LOCALE_PATH"

if command -v node >/dev/null 2>&1; then
  SCRIPT_FILE="$SCRIPT_FILE" node <<'NODE'
const fs = require("fs");
const script = fs.readFileSync(process.env.SCRIPT_FILE, "utf8");
function block(name) {
  const match = script.match(new RegExp("__" + name + "__\\r?\\n([\\s\\S]*?)\\r?\\n__END_" + name + "__"));
  if (!match) throw new Error("Missing block " + name);
  return match[1].trim();
}
const entry = JSON.parse(block("MANIFEST_JSON"));
const manifestPath = "dmicher-kripta-cards/module.json";
const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
manifest.languages = Array.isArray(manifest.languages) ? manifest.languages : [];
if (!manifest.languages.some((item) => item.lang === entry.lang)) {
  manifest.languages.push(entry);
}
fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2) + "\n", "utf8");
console.log("Locale " + entry.lang + " installed.");
NODE
elif command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1; then
  PYTHON_BIN="$(command -v python3 || command -v python)"
  SCRIPT_FILE="$SCRIPT_FILE" "$PYTHON_BIN" <<'PY'
import json
import os
import re

with open(os.environ["SCRIPT_FILE"], "r", encoding="utf-8") as script_file:
    script = script_file.read()

def block(name):
    match = re.search(r"__" + re.escape(name) + r"__\r?\n([\s\S]*?)\r?\n__END_" + re.escape(name) + r"__", script)
    if not match:
        raise RuntimeError("Missing block " + name)
    return match.group(1).strip()

entry = json.loads(block("MANIFEST_JSON"))
manifest_path = "dmicher-kripta-cards/module.json"
with open(manifest_path, "r", encoding="utf-8") as manifest_file:
    manifest = json.load(manifest_file)
manifest["languages"] = manifest.get("languages") or []
if not any(item.get("lang") == entry["lang"] for item in manifest["languages"]):
    manifest["languages"].append(entry)
with open(manifest_path, "w", encoding="utf-8") as manifest_file:
    json.dump(manifest, manifest_file, ensure_ascii=False, indent=2)
    manifest_file.write("\n")
print("Locale " + entry["lang"] + " installed.")
PY
else
  echo "Locale file was written, but module.json was not updated: install node or python and rerun the script." >&2
  exit 1
fi

exit 0
__MANIFEST_JSON__
{
  "lang": "de",
  "name": "Deutsch",
  "path": "lang/de.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "Dein Foundry-Benutzer ist im Modul Kripta Cards nicht mit einem Server-Spieler verknüpft. Bitte wende dich an die Spielleitung.",
  "KRIPTA.GMOnly": "Diese Aktion ist nur für die Spielleitung verfügbar.",
  "KRIPTA.Settings.ServerUrl.Name": "Serveradresse",
  "KRIPTA.Settings.TechAuthUsers.Name": "Technische Benutzer",
  "KRIPTA.Settings.PlayerBindings.Name": "Verknüpfungen von Foundry-Benutzern mit Server-Spielern",
  "KRIPTA.Settings.UiPrefs.Name": "Lokale Oberflächeneinstellungen",
  "KRIPTA.Settings.Menu.Name": "Kripta Cards",
  "KRIPTA.Settings.Menu.Label": "Moduleinstellungen",
  "KRIPTA.Settings.Menu.Hint": "API-Verbindung und technische Benutzer.",
  "KRIPTA.Settings.Help.BeforeServerLink": "Wenn Sie den Content-Server für das Modul noch nicht installiert und eingerichtet haben, folgen Sie ",
  "KRIPTA.Settings.Help.ServerLink": "diesem Link",
  "KRIPTA.Settings.Help.AfterServerLink": ", um dies zu tun. Für die schnelle Einrichtung verwenden Sie die ",
  "KRIPTA.Settings.Help.DocumentationLink": "Dokumentation",
  "KRIPTA.Settings.Help.AfterDocumentationLink": ".",
  "KRIPTA.Window.Catalog": "Kartenkatalog",
  "KRIPTA.Window.CardDetails": "Katalogkarte",
  "KRIPTA.Window.GiveCard": "Karte geben",
  "KRIPTA.Window.MyCards": "Spielerkarten",
  "KRIPTA.Window.Players": "Spieler verwalten",
  "KRIPTA.Window.Registry": "Spielerregister",
  "KRIPTA.Window.RequestCard": "Karte anfordern",
  "KRIPTA.Window.Settings": "Kripta Cards - Einstellungen",
  "KRIPTA.Window.UseCard": "Karte verwenden",
  "KRIPTA.Menu.Title": "Kripta Cards",
  "KRIPTA.Menu.Catalog": "Kartenkatalog",
  "KRIPTA.Menu.GetCard": "Karte anfordern",
  "KRIPTA.Menu.MyCards": "Meine Karten",
  "KRIPTA.Menu.Players": "Spieler verwalten",
  "KRIPTA.Label.Category": "Kategorie",
  "KRIPTA.Label.Mode": "Modus",
  "KRIPTA.Label.Card": "Karte",
  "KRIPTA.Label.Player": "Spieler",
  "KRIPTA.Label.Name": "Name",
  "KRIPTA.Label.Comment": "Kommentar",
  "KRIPTA.Label.CardTypes": "Kartentypen",
  "KRIPTA.Label.Count": "Anzahl",
  "KRIPTA.Label.ConfirmationCode": "Bestätigungscode",
  "KRIPTA.Label.Id": "Id",
  "KRIPTA.Label.Key": "Schlüssel",
  "KRIPTA.Label.ServerUrl": "Server-URL",
  "KRIPTA.Label.Writer": "Writer",
  "KRIPTA.Label.Reader": "Reader",
  "KRIPTA.Label.Role": "Rolle",
  "KRIPTA.Label.Binding": "Verknüpfung",
  "KRIPTA.Role.GM": "Spielleitung",
  "KRIPTA.Role.Player": "Spieler",
  "KRIPTA.Status.InGame": "im Spiel",
  "KRIPTA.Status.Offline": "offline",
  "KRIPTA.Binding.CardsIssued": "ausgegebene Karten:",
  "KRIPTA.Binding.NoCards": "keine Karten",
  "KRIPTA.Binding.NotBound": "Spieler ist nicht verknüpft, wähle einen Spieler.",
  "KRIPTA.Binding.CardsCountHint": "Anzahl ausgegebener Kartentypen, Duplikate nicht mitgezählt",
  "KRIPTA.Button.Add": "Hinzufügen",
  "KRIPTA.Button.Bind": "Verknüpfen",
  "KRIPTA.Button.Cancel": "Abbrechen",
  "KRIPTA.Button.Close": "Schließen",
  "KRIPTA.Button.Confirm": "Bestätigen",
  "KRIPTA.Button.Delete": "Löschen",
  "KRIPTA.Button.Edit": "Bearbeiten",
  "KRIPTA.Button.Give": "Geben",
  "KRIPTA.Button.GiveCard": "Karte geben",
  "KRIPTA.Button.Info": "Info",
  "KRIPTA.Button.No": "Nein",
  "KRIPTA.Button.Output": "Posten",
  "KRIPTA.Button.Refresh": "Aktualisieren",
  "KRIPTA.Button.Registry": "Spielerregister",
  "KRIPTA.Button.Request": "Anfordern",
  "KRIPTA.Button.RequestCard": "Anfordern",
  "KRIPTA.Button.SaveChanges": "Änderungen speichern",
  "KRIPTA.Button.Take": "Entziehen",
  "KRIPTA.Button.TestAuth": "Technische Benutzer prüfen",
  "KRIPTA.Button.TestServer": "Server prüfen",
  "KRIPTA.Button.Unbind": "Verknüpfung lösen",
  "KRIPTA.Button.Use": "Verwenden",
  "KRIPTA.Button.Yes": "Ja",
  "KRIPTA.Mode.Manual": "Manuell auswählen",
  "KRIPTA.Mode.Random": "Zufällig",
  "KRIPTA.Mode.Show": "Zeigen",
  "KRIPTA.Mode.Spend": "Ausgeben",
  "KRIPTA.View.Table": "Tabelle",
  "KRIPTA.View.Tiles": "Kacheln",
  "KRIPTA.Placeholder.Search": "Suchen",
  "KRIPTA.Select.NotSelected": "-- nicht ausgewählt --",
  "KRIPTA.Template.EmptyCatalog": "Auf dem Server sind keine Kategorien oder Karten registriert.",
  "KRIPTA.Template.MyCardsTitle": "Karten von Spieler: {playerName}",
  "KRIPTA.Template.UseCardMissing": "Diese Karte ist nicht mehr auf dem Server registriert.",
  "KRIPTA.Template.UseCardPrompt": "Diese Karte wird verwendet:",
  "KRIPTA.Card.FallbackName": "Karte {number}",
  "KRIPTA.Card.FallbackAddress": "Karte {level}/{number}",
  "KRIPTA.Card.MissingDescription": "Karte {level}/{number} fehlt im aktuellen Serverkatalog.",
  "KRIPTA.Card.NotRegisteredDescription": "Karte {level}/{number} ist nicht mehr auf dem Server registriert.",
  "KRIPTA.Level.FallbackName": "Stufe {level}",
  "KRIPTA.Level.MissingDescription": "Diese Stufe existiert im Inventar des Spielers, fehlt aber im aktuellen Serverkatalog.",
  "KRIPTA.Chat.BlobReadFailed": "Blob konnte nicht gelesen werden",
  "KRIPTA.Chat.CardGivenTitle": "Karte gegeben",
  "KRIPTA.Chat.CardReceiveSubtitle": "Spieler {playerName} erhält Karte {cardSubtitle}",
  "KRIPTA.Chat.CardRequestCanceled": "Kartenanforderung abgebrochen.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "Kartenanforderung bestätigt",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "Anforderungsdaten konnten nicht gelesen werden.",
  "KRIPTA.Chat.CardSpentFooter": "KARTE AUSGEGEBEN",
  "KRIPTA.Chat.CardSpentTitle": "Karte ausgegeben",
  "KRIPTA.Chat.FallbackPlayer": "Spieler",
  "KRIPTA.Chat.ManualChoiceFooter": "MANUELLE AUSWAHL",
  "KRIPTA.Chat.ReferenceTitle": "Referenz",
  "KRIPTA.Chat.RequestManualTitle": "Anforderung einer ausgewählten Karte",
  "KRIPTA.Chat.RequestRandomTitle": "Anforderung einer zufälligen Karte",
  "KRIPTA.Chat.ShowCardTitle": "Kartenreferenz",
  "KRIPTA.Dialog.BindPlayer.Title": "Server-Spieler verknüpfen",
  "KRIPTA.Dialog.BindPlayer.Header": "Spieler für {foundryUserName} auswählen",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "Foundry-Benutzer",
  "KRIPTA.Dialog.Player.AddTitle": "Spieler hinzufügen",
  "KRIPTA.Dialog.Player.EditTitle": "Spieler bearbeiten",
  "KRIPTA.Dialog.Player.DeleteTitle": "Spieler löschen",
  "KRIPTA.Dialog.Player.DeleteWarning": "Das Löschen von Spieler \"{playerName}\" kann nicht rückgängig gemacht werden. Gib {code} ein und bestätige das Löschen.",
  "KRIPTA.Dialog.Count.TotalCards": "Gesamtzahl der Karten dieses Typs - {max}",
  "KRIPTA.Error.InvalidCardLevel": "Ungültige Stufe für {context}: {level}",
  "KRIPTA.Error.InvalidCardNumber": "Ungültige Nummer für {context}: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "ungültige Kartenstufe: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "ungültige Kartennummer: {number}",
  "KRIPTA.Error.InvalidRequestCard": "Ungültige Karte für die Anforderung",
  "KRIPTA.Error.InvalidGiveCard": "Ungültige Karte zum Geben",
  "KRIPTA.Error.MissingRequestPlayerGuid": "playerGuid zum Geben der Karte konnte nicht ermittelt werden.",
  "KRIPTA.Error.MissingSelectedCard": "Ausgewählte Karte konnte nicht ermittelt werden.",
  "KRIPTA.Error.MissingSelectedCardForGive": "Ausgewählte Karte zum Geben konnte nicht ermittelt werden.",
  "KRIPTA.Error.MissingGivePlayer": "Spieler, der die Karte erhalten soll, konnte nicht ermittelt werden.",
  "KRIPTA.Error.MissingGiveCard": "Zu gebende Karte konnte nicht ermittelt werden.",
  "KRIPTA.Error.MissingServerUrl": "Serverpfad-Einstellung fehlt.",
  "KRIPTA.Error.InvalidReader": "Der technische Benutzer Reader ist falsch konfiguriert.",
  "KRIPTA.Error.InvalidWriter": "Der technische Benutzer Writer ist falsch konfiguriert.",
  "KRIPTA.Error.MenuUnavailable": "Diese Funktion ist nicht verfügbar. Prüfe die Moduleinstellungen. Details stehen in der Browserkonsole.",
  "KRIPTA.Error.Generic": "Ein Fehler ist aufgetreten",
  "KRIPTA.Error.Unknown": "unbekannter Fehler",
  "KRIPTA.Error.NameRequired": "api 400: Das Feld Name ist erforderlich.",
  "KRIPTA.Error.RegistryDeleteReturned": "der Server hat den Spieler nach dem Löschen wieder im Register zurückgegeben.",
  "KRIPTA.Notification.CardGiven": "Karte gegeben.",
  "KRIPTA.Notification.CardUsed": "Karte verwendet und ausgegeben.",
  "KRIPTA.Notification.CardWrittenOff": "Karte entfernt.",
  "KRIPTA.Notification.CannotUseMissingCard": "Diese Karte ist nicht mehr auf dem Server registriert. Sie kann nicht verwendet werden.",
  "KRIPTA.Notification.MissingCard": "Diese Karte ist nicht mehr auf dem Server registriert.",
  "KRIPTA.Notification.PlayerNotSelected": "Kein Spieler zum Geben der Karte ausgewählt",
  "KRIPTA.Notification.PlayerBindingMissing": "Spielerverknüpfung zum Geben der Karte konnte nicht ermittelt werden",
  "KRIPTA.Notification.RequestSent": "Kartenanforderung an den Chat gesendet.",
  "KRIPTA.Notification.ServerSuccess": "Verbindung erfolgreich.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "Verbindung erfolgreich. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "Verbindung zum Server fehlgeschlagen. Prüfe Adresse, Serververfügbarkeit und CORS/HTTPS-Einstellungen.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "Server konnte nicht geprüft werden.",
  "KRIPTA.Notification.InvalidServerUrl": "Ungültige Serveradresse: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "Der Einstellungsbereich von Kripta Cards ist nur für die Rollen Spielleitung und Assistierende Spielleitung verfügbar.",
  "KRIPTA.Notification.ServerCheckFailed": "Serverprüfung fehlgeschlagen",
  "KRIPTA.Notification.TechUserReader": "Reader",
  "KRIPTA.Notification.TechUserWriter": "Writer",
  "KRIPTA.Notification.TechUsersCheckSuccess": "Reader und Writer bestehen die Prüfung.",
  "KRIPTA.Notification.SettingsSaved": "Verbindungseinstellungen gespeichert.",
  "KRIPTA.Notification.PlayerAdded": "Spieler hinzugefügt.",
  "KRIPTA.Notification.PlayerUpdated": "Spieler aktualisiert.",
  "KRIPTA.Notification.PlayerDeleted": "Spieler gelöscht.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "Löschen abgebrochen. Das Bestätigungsfeld wurde falsch ausgefüllt.",
  "KRIPTA.Notification.BindingSaved": "Verknüpfung gespeichert.",
  "KRIPTA.Notification.BindingDeleted": "Verknüpfung entfernt.",
  "KRIPTA.Notification.BadCatalogCardNumber": "Die ausgewählte Karte hat eine ungültige Nummer. Prüfe die Antwort von getCardsList und normalizeCardsList.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "Diese Karte kann nicht manuell gegeben werden, da sie eine ungültige Nummer hat. Prüfe die Antwort von getCardsList und normalizeCardsList.",
  "KRIPTA.Notification.CardOutputFailed": "Karte konnte nicht in den Chat gepostet werden",
  "KRIPTA.Notification.CardGiveFailed": "Karte konnte nicht gegeben werden",
  "KRIPTA.Notification.CardUseFailed": "Karte konnte nicht verwendet werden",
  "KRIPTA.Notification.CardTakeFailed": "Karte konnte nicht entfernt werden",
  "KRIPTA.Notification.CardRequestFailed": "Kartenanforderung konnte nicht gesendet werden",
  "KRIPTA.Notification.CardRequestConfirmFailed": "Geben der Karte konnte nicht bestätigt werden",
  "KRIPTA.Notification.PlayerAddFailed": "Spieler konnte nicht hinzugefügt werden",
  "KRIPTA.Notification.PlayerUpdateFailed": "Spieler konnte nicht aktualisiert werden",
  "KRIPTA.Notification.PlayerDeleteFailed": "Spieler konnte nicht gelöscht werden",
  "KRIPTA.Notification.CardRollFailed": "Karte konnte nicht empfangen werden.",
  "KRIPTA.Dialog.TakeCard.Title": "Karte entziehen",
  "KRIPTA.Dialog.TakeCard.Message": "Spieler {playerName} verliert Karte {cardName}.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Karte geben"
}
__END_LOCALE_JSON__
