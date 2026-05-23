#!/usr/bin/env sh
set -eu

if [ ! -f "dmicher-kripta-cards/module.json" ]; then
  echo "Run this script from the Foundry module workspace root, next to dmicher-kripta-cards/module.json." >&2
  exit 1
fi

SCRIPT_FILE="$0"
LOCALE_PATH="dmicher-kripta-cards/lang/sv.json"
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
  "lang": "sv",
  "name": "Svenska",
  "path": "lang/sv.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "Din Foundry-deltagare är inte kopplad till en serverspelare i modulen Kripta-kort. Kontakta spelledaren.",
  "KRIPTA.GMOnly": "Den här åtgärden är bara tillgänglig för spelledaren.",
  "KRIPTA.Settings.ServerUrl.Name": "Serveradress",
  "KRIPTA.Settings.TechAuthUsers.Name": "Tekniska användare",
  "KRIPTA.Settings.PlayerBindings.Name": "Kopplingar mellan deltagare och serverspelare",
  "KRIPTA.Settings.UiPrefs.Name": "Lokala gränssnittsinställningar",
  "KRIPTA.Settings.Menu.Name": "Kripta-kort",
  "KRIPTA.Settings.Menu.Label": "Modulinställningar",
  "KRIPTA.Settings.Menu.Hint": "API-anslutning och tekniska användare.",
  "KRIPTA.Settings.Help.BeforeServerLink": "Om du ännu inte har installerat och konfigurerat innehållsservern för modulen, följ ",
  "KRIPTA.Settings.Help.ServerLink": "den här länken",
  "KRIPTA.Settings.Help.AfterServerLink": " för att göra det. För snabb konfiguration, använd ",
  "KRIPTA.Settings.Help.DocumentationLink": "dokumentationen",
  "KRIPTA.Settings.Help.AfterDocumentationLink": ".",
  "KRIPTA.Window.Catalog": "Kortkatalog",
  "KRIPTA.Window.CardDetails": "Katalogkort",
  "KRIPTA.Window.GiveCard": "Ge kort",
  "KRIPTA.Window.MyCards": "Spelarens kort",
  "KRIPTA.Window.Players": "Hantera spelare",
  "KRIPTA.Window.Registry": "Spelarregister",
  "KRIPTA.Window.RequestCard": "Hämta kort",
  "KRIPTA.Window.Settings": "Kripta-kort - Inställningar",
  "KRIPTA.Window.UseCard": "Använd kort",
  "KRIPTA.Menu.Title": "Kripta-kort",
  "KRIPTA.Menu.Catalog": "Kortkatalog",
  "KRIPTA.Menu.GetCard": "Hämta kort",
  "KRIPTA.Menu.MyCards": "Mina kort",
  "KRIPTA.Menu.Players": "Hantera spelare",
  "KRIPTA.Label.Category": "Kategori",
  "KRIPTA.Label.Mode": "Läge",
  "KRIPTA.Label.Card": "Kort",
  "KRIPTA.Label.Player": "Spelare",
  "KRIPTA.Label.Name": "Namn",
  "KRIPTA.Label.Comment": "Kommentar",
  "KRIPTA.Label.CardTypes": "Korttyper",
  "KRIPTA.Label.Count": "Antal",
  "KRIPTA.Label.ConfirmationCode": "Bekräftelsekod",
  "KRIPTA.Label.Id": "Identifierare",
  "KRIPTA.Label.Key": "Nyckel",
  "KRIPTA.Label.ServerUrl": "Sökväg till servern",
  "KRIPTA.Label.Writer": "Skribent (Writer)",
  "KRIPTA.Label.Reader": "Läsare (Reader)",
  "KRIPTA.Label.Role": "Roll",
  "KRIPTA.Label.Binding": "Koppling",
  "KRIPTA.Role.GM": "Spelledare",
  "KRIPTA.Role.Player": "Spelare",
  "KRIPTA.Status.InGame": "i spel",
  "KRIPTA.Status.Offline": "utanför spel",
  "KRIPTA.Binding.CardsIssued": "utdelade kort:",
  "KRIPTA.Binding.NoCards": "inga kort",
  "KRIPTA.Binding.NotBound": "spelaren är inte kopplad, välj en spelare.",
  "KRIPTA.Binding.CardsCountHint": "Antal utdelade korttyper (dubbletter räknas inte)",
  "KRIPTA.Button.Add": "Lägg till",
  "KRIPTA.Button.Bind": "Koppla",
  "KRIPTA.Button.Cancel": "Avbryt",
  "KRIPTA.Button.Close": "Stäng",
  "KRIPTA.Button.Confirm": "Bekräfta",
  "KRIPTA.Button.Delete": "Ta bort",
  "KRIPTA.Button.Edit": "Ändra",
  "KRIPTA.Button.Give": "Ge",
  "KRIPTA.Button.GiveCard": "Ge kort",
  "KRIPTA.Button.Info": "Information",
  "KRIPTA.Button.No": "Nej",
  "KRIPTA.Button.Output": "Visa",
  "KRIPTA.Button.Refresh": "Uppdatera",
  "KRIPTA.Button.Registry": "Spelarregister",
  "KRIPTA.Button.Request": "Begär",
  "KRIPTA.Button.RequestCard": "Hämta",
  "KRIPTA.Button.SaveChanges": "Spara ändringar",
  "KRIPTA.Button.Take": "Ta",
  "KRIPTA.Button.TestAuth": "Kontrollera tekniska användare",
  "KRIPTA.Button.TestServer": "Kontrollera servern",
  "KRIPTA.Button.Unbind": "Ta bort koppling",
  "KRIPTA.Button.Use": "Använd",
  "KRIPTA.Button.Yes": "Ja",
  "KRIPTA.Mode.Manual": "Valfri",
  "KRIPTA.Mode.Random": "Slumpmässig",
  "KRIPTA.Mode.Show": "Visa",
  "KRIPTA.Mode.Spend": "Spendera",
  "KRIPTA.View.Table": "Tabell",
  "KRIPTA.View.Tiles": "Brickor",
  "KRIPTA.Placeholder.Search": "Sök",
  "KRIPTA.Select.NotSelected": "-- inte vald --",
  "KRIPTA.Template.EmptyCatalog": "Det finns inga registrerade kategorier eller kort på servern.",
  "KRIPTA.Template.MyCardsTitle": "Spelarens kort: {playerName}",
  "KRIPTA.Template.UseCardMissing": "Det här kortet är inte längre registrerat på servern.",
  "KRIPTA.Template.UseCardPrompt": "Följande kort kommer att användas:",
  "KRIPTA.Card.FallbackName": "Kort {number}",
  "KRIPTA.Card.FallbackAddress": "Kort {level}/{number}",
  "KRIPTA.Card.MissingDescription": "Kortet {level}/{number} saknas i serverns aktuella katalog.",
  "KRIPTA.Card.NotRegisteredDescription": "Kortet {level}/{number} är inte längre registrerat på servern.",
  "KRIPTA.Level.FallbackName": "Nivå {level}",
  "KRIPTA.Level.MissingDescription": "Nivån finns i spelarens inventarium men saknas i serverns aktuella katalog.",
  "KRIPTA.Chat.BlobReadFailed": "Det gick inte att läsa BLOB",
  "KRIPTA.Chat.CardGivenTitle": "Kort utdelat",
  "KRIPTA.Chat.CardReceiveSubtitle": "Spelare {playerName} får kortet {cardSubtitle}",
  "KRIPTA.Chat.CardRequestCanceled": "Kortbegäran avbröts.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "Kortbegäran bekräftad",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "Det gick inte att läsa begärans data.",
  "KRIPTA.Chat.CardSpentFooter": "KORTET SPENDERAT",
  "KRIPTA.Chat.CardSpentTitle": "Kort spenderat",
  "KRIPTA.Chat.FallbackPlayer": "spelare",
  "KRIPTA.Chat.ManualChoiceFooter": "MANUELLT VAL",
  "KRIPTA.Chat.ReferenceTitle": "Hjälp",
  "KRIPTA.Chat.RequestManualTitle": "Begäran om valt kort",
  "KRIPTA.Chat.RequestRandomTitle": "Begäran om slumpkort",
  "KRIPTA.Chat.ShowCardTitle": "Kortinformation",
  "KRIPTA.Dialog.BindPlayer.Title": "Koppla serverspelare",
  "KRIPTA.Dialog.BindPlayer.Header": "Välj spelare för {foundryUserName}",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "Foundry-användaren",
  "KRIPTA.Dialog.Player.AddTitle": "Lägg till spelare",
  "KRIPTA.Dialog.Player.EditTitle": "Ändra spelare",
  "KRIPTA.Dialog.Player.DeleteTitle": "Ta bort spelare",
  "KRIPTA.Dialog.Player.DeleteWarning": "Borttagning av spelaren \"{playerName}\" kan inte ångras. Ange \"{code}\" och bekräfta borttagningen.",
  "KRIPTA.Dialog.Count.TotalCards": "totalt antal kort av den här typen - {max}",
  "KRIPTA.Error.InvalidCardLevel": "Ogiltig level för {context}: {level}",
  "KRIPTA.Error.InvalidCardNumber": "Ogiltig number för {context}: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "ogiltig kort-level: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "ogiltigt kort-number: {number}",
  "KRIPTA.Error.InvalidRequestCard": "Ogiltigt kort för begäran",
  "KRIPTA.Error.InvalidGiveCard": "Ogiltigt kort att ge",
  "KRIPTA.Error.MissingRequestPlayerGuid": "Det gick inte att fastställa playerGuid för kortutdelning.",
  "KRIPTA.Error.MissingSelectedCard": "Det gick inte att fastställa valt kort.",
  "KRIPTA.Error.MissingSelectedCardForGive": "Det gick inte att fastställa valt kort för utdelning.",
  "KRIPTA.Error.MissingGivePlayer": "Det gick inte att fastställa spelaren för kortutdelning.",
  "KRIPTA.Error.MissingGiveCard": "Det gick inte att fastställa kortet för utdelning.",
  "KRIPTA.Error.MissingServerUrl": "Inställningen för sökväg till servern saknas.",
  "KRIPTA.Error.InvalidReader": "Den tekniska användaren Reader är felaktigt konfigurerad.",
  "KRIPTA.Error.InvalidWriter": "Den tekniska användaren Writer är felaktigt konfigurerad.",
  "KRIPTA.Error.MenuUnavailable": "Funktionen fungerar inte. Kontrollera modulens inställningar. Detaljer finns i webbläsarkonsolen.",
  "KRIPTA.Error.Generic": "Ett fel inträffade",
  "KRIPTA.Error.Unknown": "okänt fel",
  "KRIPTA.Error.NameRequired": "Namnfältet är obligatoriskt.",
  "KRIPTA.Error.RegistryDeleteReturned": "servern returnerade spelaren i registret efter borttagning.",
  "KRIPTA.Notification.CardGiven": "Kortet har delats ut.",
  "KRIPTA.Notification.CardUsed": "Kortet har använts och skrivits av.",
  "KRIPTA.Notification.CardWrittenOff": "Kortet har skrivits av.",
  "KRIPTA.Notification.CannotUseMissingCard": "Det här kortet är inte längre registrerat på servern. Det kan inte användas.",
  "KRIPTA.Notification.MissingCard": "Det här kortet är inte längre registrerat på servern.",
  "KRIPTA.Notification.PlayerNotSelected": "Ingen spelare vald för kortutdelning",
  "KRIPTA.Notification.PlayerBindingMissing": "Det gick inte att fastställa spelarens koppling för kortutdelning",
  "KRIPTA.Notification.RequestSent": "Kortbegäran skickades till chatten.",
  "KRIPTA.Notification.ServerSuccess": "Anslutningen lyckades.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "Anslutningen lyckades. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "Det gick inte att ansluta till servern. Kontrollera adressen, serverns tillgänglighet och CORS/HTTPS-inställningar.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "Det gick inte att kontrollera servern.",
  "KRIPTA.Notification.InvalidServerUrl": "Ogiltig serveradress: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "Inställningsdelen ”Kripta-kort” är bara tillgänglig för rollerna ”Spelledare” och ”Assisterande spelledare”.",
  "KRIPTA.Notification.ServerCheckFailed": "Serverkontrollen misslyckades",
  "KRIPTA.Notification.TechUserReader": "Läsare",
  "KRIPTA.Notification.TechUserWriter": "Skribent",
  "KRIPTA.Notification.TechUsersCheckSuccess": "De tekniska användarna \"Reader\" och \"Writer\" klarar kontrollen.",
  "KRIPTA.Notification.SettingsSaved": "Anslutningsinställningarna har sparats.",
  "KRIPTA.Notification.PlayerAdded": "Spelare tillagd.",
  "KRIPTA.Notification.PlayerUpdated": "Spelare uppdaterad.",
  "KRIPTA.Notification.PlayerDeleted": "Spelare borttagen.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "Borttagningen avbröts. Kontrollfältet är felaktigt ifyllt.",
  "KRIPTA.Notification.BindingSaved": "Kopplingen sparades.",
  "KRIPTA.Notification.BindingDeleted": "Kopplingen togs bort.",
  "KRIPTA.Notification.BadCatalogCardNumber": "Det valda kortet har ett ogiltigt nummer. Kontrollera svaret från getCardsList och normalizeCardsList.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "Det här kortet kan inte ges manuellt: det har ett ogiltigt nummer. Kontrollera svaret från getCardsList och normalizeCardsList.",
  "KRIPTA.Notification.CardOutputFailed": "Det gick inte att visa kortet i chatten",
  "KRIPTA.Notification.CardGiveFailed": "Det gick inte att ge kortet",
  "KRIPTA.Notification.CardUseFailed": "Det gick inte att använda kortet",
  "KRIPTA.Notification.CardTakeFailed": "Det gick inte att skriva av kortet",
  "KRIPTA.Notification.CardRequestFailed": "Det gick inte att skicka kortbegäran",
  "KRIPTA.Notification.CardRequestConfirmFailed": "Det gick inte att bekräfta kortutdelningen",
  "KRIPTA.Notification.PlayerAddFailed": "Det gick inte att lägga till spelaren",
  "KRIPTA.Notification.PlayerUpdateFailed": "Det gick inte att uppdatera spelaren",
  "KRIPTA.Notification.PlayerDeleteFailed": "Det gick inte att ta bort spelaren",
  "KRIPTA.Notification.CardRollFailed": "Det gick inte att hämta kortet.",
  "KRIPTA.Dialog.TakeCard.Title": "Ta kort",
  "KRIPTA.Dialog.TakeCard.Message": "Spelare {playerName} kommer att fråntas kortet {cardName}.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Ge kort"
}
__END_LOCALE_JSON__
