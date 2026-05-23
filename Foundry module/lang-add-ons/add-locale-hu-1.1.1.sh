#!/usr/bin/env sh
set -eu

if [ ! -f "dmicher-kripta-cards/module.json" ]; then
  echo "Run this script from the Foundry module workspace root, next to dmicher-kripta-cards/module.json." >&2
  exit 1
fi

SCRIPT_FILE="$0"
LOCALE_PATH="dmicher-kripta-cards/lang/hu.json"
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
  "lang": "hu",
  "name": "Magyar",
  "path": "lang/hu.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "A Foundry-résztvevőd nincs összekapcsolva egy szerverjátékossal a Kripta kártyák modulban. Fordulj a játékmesterhez.",
  "KRIPTA.GMOnly": "Ez a művelet csak a játékmester számára érhető el.",
  "KRIPTA.Settings.ServerUrl.Name": "Szerver címe",
  "KRIPTA.Settings.TechAuthUsers.Name": "Technikai felhasználók",
  "KRIPTA.Settings.PlayerBindings.Name": "Foundry-résztvevők összekapcsolása szerverjátékosokkal",
  "KRIPTA.Settings.UiPrefs.Name": "Helyi felületbeállítások",
  "KRIPTA.Settings.Menu.Name": "Kripta kártyák",
  "KRIPTA.Settings.Menu.Label": "Modul beállítása",
  "KRIPTA.Settings.Menu.Hint": "API-kapcsolat és technikai felhasználók.",
  "KRIPTA.Settings.Help.BeforeServerLink": "Ha még nem telepítette és nem állította be a modul tartalomszerverét, kövesse ",
  "KRIPTA.Settings.Help.ServerLink": "ezt a hivatkozást",
  "KRIPTA.Settings.Help.AfterServerLink": " a művelethez. A gyors beállításhoz használja a ",
  "KRIPTA.Settings.Help.DocumentationLink": "dokumentációt",
  "KRIPTA.Settings.Help.AfterDocumentationLink": ".",
  "KRIPTA.Window.Catalog": "Kártyakatalógus",
  "KRIPTA.Window.CardDetails": "Katalóguskártya",
  "KRIPTA.Window.GiveCard": "Kártya kiadása",
  "KRIPTA.Window.MyCards": "Játékos kártyái",
  "KRIPTA.Window.Players": "Játékosok kezelése",
  "KRIPTA.Window.Registry": "Játékos-nyilvántartás",
  "KRIPTA.Window.RequestCard": "Kártya szerzése",
  "KRIPTA.Window.Settings": "Kripta kártyák - Beállítások",
  "KRIPTA.Window.UseCard": "Kártya használata",
  "KRIPTA.Menu.Title": "Kripta kártyák",
  "KRIPTA.Menu.Catalog": "Kártyakatalógus",
  "KRIPTA.Menu.GetCard": "Kártya szerzése",
  "KRIPTA.Menu.MyCards": "Saját kártyáim",
  "KRIPTA.Menu.Players": "Játékosok kezelése",
  "KRIPTA.Label.Category": "Kategória",
  "KRIPTA.Label.Mode": "Mód",
  "KRIPTA.Label.Card": "Kártya",
  "KRIPTA.Label.Player": "Játékos",
  "KRIPTA.Label.Name": "Név",
  "KRIPTA.Label.Comment": "Megjegyzés",
  "KRIPTA.Label.CardTypes": "Kártyatípusok",
  "KRIPTA.Label.Count": "Mennyiség",
  "KRIPTA.Label.ConfirmationCode": "Megerősítő kód",
  "KRIPTA.Label.Id": "Azonosító",
  "KRIPTA.Label.Key": "Kulcs",
  "KRIPTA.Label.ServerUrl": "Szerver elérési útja",
  "KRIPTA.Label.Writer": "Író (Writer)",
  "KRIPTA.Label.Reader": "Olvasó (Reader)",
  "KRIPTA.Label.Role": "Szerep",
  "KRIPTA.Label.Binding": "Összekapcsolás",
  "KRIPTA.Role.GM": "Játékmester",
  "KRIPTA.Role.Player": "Játékos",
  "KRIPTA.Status.InGame": "játékban",
  "KRIPTA.Status.Offline": "játékon kívül",
  "KRIPTA.Binding.CardsIssued": "kiadott kártyák:",
  "KRIPTA.Binding.NoCards": "nincs kártya",
  "KRIPTA.Binding.NotBound": "a játékos nincs összekapcsolva, válassz játékost.",
  "KRIPTA.Binding.CardsCountHint": "A kiadott kártyatípusok száma (az ismétlődők nélkül)",
  "KRIPTA.Button.Add": "Hozzáadás",
  "KRIPTA.Button.Bind": "Összekapcsolás",
  "KRIPTA.Button.Cancel": "Mégse",
  "KRIPTA.Button.Close": "Bezárás",
  "KRIPTA.Button.Confirm": "Megerősítés",
  "KRIPTA.Button.Delete": "Törlés",
  "KRIPTA.Button.Edit": "Módosítás",
  "KRIPTA.Button.Give": "Kiadás",
  "KRIPTA.Button.GiveCard": "Kártya kiadása",
  "KRIPTA.Button.Info": "Információ",
  "KRIPTA.Button.No": "Nem",
  "KRIPTA.Button.Output": "Megjelenítés",
  "KRIPTA.Button.Refresh": "Frissítés",
  "KRIPTA.Button.Registry": "Játékos-nyilvántartás",
  "KRIPTA.Button.Request": "Kérés",
  "KRIPTA.Button.RequestCard": "Szerzés",
  "KRIPTA.Button.SaveChanges": "Változások mentése",
  "KRIPTA.Button.Take": "Elvétel",
  "KRIPTA.Button.TestAuth": "Technikai felhasználók ellenőrzése",
  "KRIPTA.Button.TestServer": "Szerver ellenőrzése",
  "KRIPTA.Button.Unbind": "Kapcsolat törlése",
  "KRIPTA.Button.Use": "Használat",
  "KRIPTA.Button.Yes": "Igen",
  "KRIPTA.Mode.Manual": "Választható",
  "KRIPTA.Mode.Random": "Véletlenszerű",
  "KRIPTA.Mode.Show": "Megjelenítés",
  "KRIPTA.Mode.Spend": "Elköltés",
  "KRIPTA.View.Table": "Táblázat",
  "KRIPTA.View.Tiles": "Csempék",
  "KRIPTA.Placeholder.Search": "Keresés",
  "KRIPTA.Select.NotSelected": "-- nincs kiválasztva --",
  "KRIPTA.Template.EmptyCatalog": "A szerveren nincs regisztrált kategória vagy kártya.",
  "KRIPTA.Template.MyCardsTitle": "Játékos kártyái: {playerName}",
  "KRIPTA.Template.UseCardMissing": "Ez a kártya már nincs regisztrálva a szerveren.",
  "KRIPTA.Template.UseCardPrompt": "A következő kártya lesz használva:",
  "KRIPTA.Card.FallbackName": "Kártya {number}",
  "KRIPTA.Card.FallbackAddress": "Kártya {level}/{number}",
  "KRIPTA.Card.MissingDescription": "A(z) {level}/{number} kártya hiányzik a szerver aktuális katalógusából.",
  "KRIPTA.Card.NotRegisteredDescription": "A(z) {level}/{number} kártya már nincs regisztrálva a szerveren.",
  "KRIPTA.Level.FallbackName": "Szint {level}",
  "KRIPTA.Level.MissingDescription": "A szint szerepel a játékos készletében, de hiányzik a szerver aktuális katalógusából.",
  "KRIPTA.Chat.BlobReadFailed": "A BLOB beolvasása nem sikerült",
  "KRIPTA.Chat.CardGivenTitle": "Kártya kiadva",
  "KRIPTA.Chat.CardReceiveSubtitle": "{playerName} játékos megkapja a(z) {cardSubtitle} kártyát",
  "KRIPTA.Chat.CardRequestCanceled": "A kártyakérés törölve.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "Kártyakérés megerősítve",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "A kérés adatai nem olvashatók.",
  "KRIPTA.Chat.CardSpentFooter": "KÁRTYA ELKÖLTVE",
  "KRIPTA.Chat.CardSpentTitle": "Kártya elköltve",
  "KRIPTA.Chat.FallbackPlayer": "játékos",
  "KRIPTA.Chat.ManualChoiceFooter": "KÉZI VÁLASZTÁS",
  "KRIPTA.Chat.ReferenceTitle": "Súgó",
  "KRIPTA.Chat.RequestManualTitle": "Kiválasztott kártya kérése",
  "KRIPTA.Chat.RequestRandomTitle": "Véletlen kártya kérése",
  "KRIPTA.Chat.ShowCardTitle": "Kártya súgója",
  "KRIPTA.Dialog.BindPlayer.Title": "Szerverjátékos összekapcsolása",
  "KRIPTA.Dialog.BindPlayer.Header": "Játékos kiválasztása ehhez: {foundryUserName}",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "Foundry-felhasználó",
  "KRIPTA.Dialog.Player.AddTitle": "Játékos hozzáadása",
  "KRIPTA.Dialog.Player.EditTitle": "Játékos módosítása",
  "KRIPTA.Dialog.Player.DeleteTitle": "Játékos törlése",
  "KRIPTA.Dialog.Player.DeleteWarning": "A(z) \"{playerName}\" játékos törlése visszavonhatatlan. Írd be ezt: \"{code}\", majd erősítsd meg a törlést.",
  "KRIPTA.Dialog.Count.TotalCards": "ebből a típusból összesen ennyi kártya van - {max}",
  "KRIPTA.Error.InvalidCardLevel": "Érvénytelen level ehhez: {context}: {level}",
  "KRIPTA.Error.InvalidCardNumber": "Érvénytelen number ehhez: {context}: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "érvénytelen kártya-level: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "érvénytelen kártya-number: {number}",
  "KRIPTA.Error.InvalidRequestCard": "Érvénytelen kártya a kéréshez",
  "KRIPTA.Error.InvalidGiveCard": "Érvénytelen kártya a kiadáshoz",
  "KRIPTA.Error.MissingRequestPlayerGuid": "Nem sikerült meghatározni a playerGuid értéket a kártya kiadásához.",
  "KRIPTA.Error.MissingSelectedCard": "Nem sikerült meghatározni a kiválasztott kártyát.",
  "KRIPTA.Error.MissingSelectedCardForGive": "Nem sikerült meghatározni a kiadandó kiválasztott kártyát.",
  "KRIPTA.Error.MissingGivePlayer": "Nem sikerült meghatározni a játékost a kártya kiadásához.",
  "KRIPTA.Error.MissingGiveCard": "Nem sikerült meghatározni a kiadandó kártyát.",
  "KRIPTA.Error.MissingServerUrl": "Hiányzik a szerver elérési útjának beállítása.",
  "KRIPTA.Error.InvalidReader": "A Reader technikai felhasználó hibásan van beállítva.",
  "KRIPTA.Error.InvalidWriter": "A Writer technikai felhasználó hibásan van beállítva.",
  "KRIPTA.Error.MenuUnavailable": "A funkció nem működik. Ellenőrizd a modul beállításait. Részletek a böngésző konzoljában.",
  "KRIPTA.Error.Generic": "Hiba történt",
  "KRIPTA.Error.Unknown": "ismeretlen hiba",
  "KRIPTA.Error.NameRequired": "A név mező kötelező.",
  "KRIPTA.Error.RegistryDeleteReturned": "a szerver törlés után visszaadta a játékost a nyilvántartásban.",
  "KRIPTA.Notification.CardGiven": "A kártya kiadva.",
  "KRIPTA.Notification.CardUsed": "A kártya használva és leírva.",
  "KRIPTA.Notification.CardWrittenOff": "A kártya leírva.",
  "KRIPTA.Notification.CannotUseMissingCard": "Ez a kártya már nincs regisztrálva a szerveren. A használat nem érhető el.",
  "KRIPTA.Notification.MissingCard": "Ez a kártya már nincs regisztrálva a szerveren.",
  "KRIPTA.Notification.PlayerNotSelected": "Nincs kiválasztva játékos a kártya kiadásához",
  "KRIPTA.Notification.PlayerBindingMissing": "Nem sikerült meghatározni a játékos összekapcsolását a kártya kiadásához",
  "KRIPTA.Notification.RequestSent": "A kártyakérés elküldve a chatbe.",
  "KRIPTA.Notification.ServerSuccess": "Sikeres kapcsolat.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "Sikeres kapcsolat. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "Nem sikerült csatlakozni a szerverhez. Ellenőrizd a címet, a szerver elérhetőségét és a CORS/HTTPS beállításokat.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "Nem sikerült ellenőrizni a szervert.",
  "KRIPTA.Notification.InvalidServerUrl": "Érvénytelen szervercím: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "A „Kripta kártyák” beállítási rész csak a „Játékmester” és „Játékmester-asszisztens” szerepeknek érhető el.",
  "KRIPTA.Notification.ServerCheckFailed": "A szerver ellenőrzése sikertelen",
  "KRIPTA.Notification.TechUserReader": "Olvasó",
  "KRIPTA.Notification.TechUserWriter": "Író",
  "KRIPTA.Notification.TechUsersCheckSuccess": "A \"Reader\" és \"Writer\" technikai felhasználók sikeresen átmennek az ellenőrzésen.",
  "KRIPTA.Notification.SettingsSaved": "A kapcsolati beállítások mentve.",
  "KRIPTA.Notification.PlayerAdded": "Játékos hozzáadva.",
  "KRIPTA.Notification.PlayerUpdated": "Játékos frissítve.",
  "KRIPTA.Notification.PlayerDeleted": "Játékos törölve.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "A törlés megszakítva. Az ellenőrző mező hibásan van kitöltve.",
  "KRIPTA.Notification.BindingSaved": "Összekapcsolás mentve.",
  "KRIPTA.Notification.BindingDeleted": "Összekapcsolás törölve.",
  "KRIPTA.Notification.BadCatalogCardNumber": "A kiválasztott kártya száma érvénytelen. Ellenőrizd a getCardsList válaszát és a normalizeCardsList függvényt.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "Ez a kártya kézzel nem adható ki: érvénytelen a száma. Ellenőrizd a getCardsList válaszát és a normalizeCardsList függvényt.",
  "KRIPTA.Notification.CardOutputFailed": "Nem sikerült megjeleníteni a kártyát a chatben",
  "KRIPTA.Notification.CardGiveFailed": "Nem sikerült kiadni a kártyát",
  "KRIPTA.Notification.CardUseFailed": "Nem sikerült használni a kártyát",
  "KRIPTA.Notification.CardTakeFailed": "Nem sikerült leírni a kártyát",
  "KRIPTA.Notification.CardRequestFailed": "Nem sikerült elküldeni a kártyakérést",
  "KRIPTA.Notification.CardRequestConfirmFailed": "Nem sikerült megerősíteni a kártya kiadását",
  "KRIPTA.Notification.PlayerAddFailed": "Nem sikerült hozzáadni a játékost",
  "KRIPTA.Notification.PlayerUpdateFailed": "Nem sikerült frissíteni a játékost",
  "KRIPTA.Notification.PlayerDeleteFailed": "Nem sikerült törölni a játékost",
  "KRIPTA.Notification.CardRollFailed": "Nem sikerült kártyát szerezni.",
  "KRIPTA.Dialog.TakeCard.Title": "Kártya elvétele",
  "KRIPTA.Dialog.TakeCard.Message": "{playerName} játékos elveszíti a(z) {cardName} kártyát.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Kártya kiadása"
}
__END_LOCALE_JSON__
