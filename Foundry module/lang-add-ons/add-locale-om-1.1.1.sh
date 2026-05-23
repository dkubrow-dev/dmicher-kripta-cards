#!/usr/bin/env sh
set -eu

if [ ! -f "dmicher-kripta-cards/module.json" ]; then
  echo "Run this script from the Foundry module workspace root, next to dmicher-kripta-cards/module.json." >&2
  exit 1
fi

SCRIPT_FILE="$0"
LOCALE_PATH="dmicher-kripta-cards/lang/om.json"
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
  "lang": "om",
  "name": "Afaan Oromoo",
  "path": "lang/om.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "Fayyadamaan Foundry kee moojula Kaardiiwwan Kripta keessatti Taphataa Sarvarii wajjin hin hidhamne. Gaggeessaa Taphaa qunnami.",
  "KRIPTA.GMOnly": "Gocha kana Gaggeessaa Taphaa qofatu raawwachuu danda'a.",
  "KRIPTA.Settings.ServerUrl.Name": "Teessoo sarvarii",
  "KRIPTA.Settings.TechAuthUsers.Name": "Fayyadamtoota teeknikaa",
  "KRIPTA.Settings.PlayerBindings.Name": "Hidhaa fayyadamaa Foundry gara taphataa sarvarii",
  "KRIPTA.Settings.UiPrefs.Name": "Qindaa'ina interfeesii naannoo",
  "KRIPTA.Settings.Menu.Name": "Kaardiiwwan Kripta",
  "KRIPTA.Settings.Menu.Label": "Qindaa'ina moojulaa",
  "KRIPTA.Settings.Menu.Hint": "Walitti hidhamiinsa API fi fayyadamtoota teeknikaa.",
  "KRIPTA.Settings.Help.BeforeServerLink": "Yoo sarvarii qabiyyee mooduulichaaf hanga ammaatti hin install goone fi hin qindeessine ta'e, kana gochuuf ",
  "KRIPTA.Settings.Help.ServerLink": "hidhaa kana",
  "KRIPTA.Settings.Help.AfterServerLink": " hordofaa. Qindaa'ina saffisaa'f ",
  "KRIPTA.Settings.Help.DocumentationLink": "galmee qajeelfamaa",
  "KRIPTA.Settings.Help.AfterDocumentationLink": " fayyadamaa.",
  "KRIPTA.Window.Catalog": "Kaataalogii Kaardii",
  "KRIPTA.Window.CardDetails": "Kaardii Kaataalogii",
  "KRIPTA.Window.GiveCard": "Kaardii Kenni",
  "KRIPTA.Window.MyCards": "Kaardiiwwan Taphataa",
  "KRIPTA.Window.Players": "Taphattoota Bulchi",
  "KRIPTA.Window.Registry": "Galmee Taphattootaa",
  "KRIPTA.Window.RequestCard": "Kaardii Gaafadhu",
  "KRIPTA.Window.Settings": "Kaardiiwwan Kripta - Qindaa'ina",
  "KRIPTA.Window.UseCard": "Kaardii Fayyadami",
  "KRIPTA.Menu.Title": "Kaardiiwwan Kripta",
  "KRIPTA.Menu.Catalog": "Kaataalogii Kaardii",
  "KRIPTA.Menu.GetCard": "Kaardii Gaafadhu",
  "KRIPTA.Menu.MyCards": "Kaardiiwwan Koo",
  "KRIPTA.Menu.Players": "Taphattoota Bulchi",
  "KRIPTA.Label.Category": "Ramaddii",
  "KRIPTA.Label.Mode": "Haala",
  "KRIPTA.Label.Card": "Kaardii",
  "KRIPTA.Label.Player": "Taphataa",
  "KRIPTA.Label.Name": "Maqaa",
  "KRIPTA.Label.Comment": "Yaada",
  "KRIPTA.Label.CardTypes": "Gosoota kaardii",
  "KRIPTA.Label.Count": "Baay'ina",
  "KRIPTA.Label.ConfirmationCode": "Koodii mirkaneessaa",
  "KRIPTA.Label.Id": "Eenyummaa",
  "KRIPTA.Label.Key": "Furtuu",
  "KRIPTA.Label.ServerUrl": "URL sarvarii",
  "KRIPTA.Label.Writer": "Barreessaa",
  "KRIPTA.Label.Reader": "Dubbisaa",
  "KRIPTA.Label.Role": "Gahee",
  "KRIPTA.Label.Binding": "Hidhaa",
  "KRIPTA.Role.GM": "Gaggeessaa Taphaa",
  "KRIPTA.Role.Player": "Taphataa",
  "KRIPTA.Status.InGame": "toora irra",
  "KRIPTA.Status.Offline": "toora irraa ala",
  "KRIPTA.Binding.CardsIssued": "kaardiiwwan kennaman:",
  "KRIPTA.Binding.NoCards": "kaardii hin jiru",
  "KRIPTA.Binding.NotBound": "taphataan hin hidhamne, taphataa hidhi.",
  "KRIPTA.Binding.CardsCountHint": "Baay'ina gosoota kaardii kennaman, irra deebi'aman osoo hin lakkaa'in",
  "KRIPTA.Button.Add": "Dabali",
  "KRIPTA.Button.Bind": "Hidhi",
  "KRIPTA.Button.Cancel": "Haquu",
  "KRIPTA.Button.Close": "Cufi",
  "KRIPTA.Button.Confirm": "Mirkaneessi",
  "KRIPTA.Button.Delete": "Haqi",
  "KRIPTA.Button.Edit": "Gulaali",
  "KRIPTA.Button.Give": "Kenni",
  "KRIPTA.Button.GiveCard": "Kaardii Kenni",
  "KRIPTA.Button.Info": "Odeeffannoo",
  "KRIPTA.Button.No": "Lakki",
  "KRIPTA.Button.Output": "Maxxansi",
  "KRIPTA.Button.Refresh": "Haaromsi",
  "KRIPTA.Button.Registry": "Galmee Taphattootaa",
  "KRIPTA.Button.Request": "Gaafadhu",
  "KRIPTA.Button.RequestCard": "Gaafadhu",
  "KRIPTA.Button.SaveChanges": "Jijjiirama Olkaa'i",
  "KRIPTA.Button.Take": "Fuudhi",
  "KRIPTA.Button.TestAuth": "Fayyadamtoota teeknikaa sakatta'i",
  "KRIPTA.Button.TestServer": "Sarvarii sakatta'i",
  "KRIPTA.Button.Unbind": "Hidhaa hiiki",
  "KRIPTA.Button.Use": "Fayyadami",
  "KRIPTA.Button.Yes": "Eeyyee",
  "KRIPTA.Mode.Manual": "Harkaan filadhu",
  "KRIPTA.Mode.Random": "Carraa",
  "KRIPTA.Mode.Show": "Agarsiisi",
  "KRIPTA.Mode.Spend": "Baasi",
  "KRIPTA.View.Table": "Gabatee",
  "KRIPTA.View.Tiles": "Taayiloota",
  "KRIPTA.Placeholder.Search": "Barbaadi",
  "KRIPTA.Select.NotSelected": "-- hin filatamne --",
  "KRIPTA.Template.EmptyCatalog": "Sarvarii irratti ramaddiin yookaan kaardiin galmaa'e hin jiru.",
  "KRIPTA.Template.MyCardsTitle": "Kaardiiwwan taphataa: {playerName}",
  "KRIPTA.Template.UseCardMissing": "Kaardiin kun sarvarii irratti kana booda hin galmaa'u.",
  "KRIPTA.Template.UseCardPrompt": "Kaardiin kun ni fayyadama:",
  "KRIPTA.Card.FallbackName": "Kaardii {number}",
  "KRIPTA.Card.FallbackAddress": "Kaardii {level}/{number}",
  "KRIPTA.Card.MissingDescription": "Kaardiin {level}/{number} kaataalogii sarvarii ammaa keessaa dhabameera.",
  "KRIPTA.Card.NotRegisteredDescription": "Kaardiin {level}/{number} sarvarii irratti kana booda hin galmaa'u.",
  "KRIPTA.Level.FallbackName": "Sadarkaa {level}",
  "KRIPTA.Level.MissingDescription": "Sadarkaan kun kuusaa taphataa keessa jira, garuu kaataalogii sarvarii ammaa keessaa dhabameera.",
  "KRIPTA.Chat.BlobReadFailed": "blob dubbisuun hin milkoofne",
  "KRIPTA.Chat.CardGivenTitle": "Kaardiin Kenname",
  "KRIPTA.Chat.CardReceiveSubtitle": "Taphataan {playerName} kaardii {cardSubtitle} fudhata",
  "KRIPTA.Chat.CardRequestCanceled": "Gaaffiin kaardii haqameera.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "Gaaffiin Kaardii Mirkanaa'e",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "Deetaa gaaffii dubbisuun hin milkoofne.",
  "KRIPTA.Chat.CardSpentFooter": "KAARDIIN BAHEERA",
  "KRIPTA.Chat.CardSpentTitle": "Kaardiin Baheera",
  "KRIPTA.Chat.FallbackPlayer": "taphataa",
  "KRIPTA.Chat.ManualChoiceFooter": "FILANNOO HARKAA",
  "KRIPTA.Chat.ReferenceTitle": "Wabii",
  "KRIPTA.Chat.RequestManualTitle": "Gaaffii Kaardii Filatamee",
  "KRIPTA.Chat.RequestRandomTitle": "Gaaffii Kaardii Carraa",
  "KRIPTA.Chat.ShowCardTitle": "Wabii Kaardii",
  "KRIPTA.Dialog.BindPlayer.Title": "Taphataa Sarvarii Hidhi",
  "KRIPTA.Dialog.BindPlayer.Header": "{foundryUserName} dhaaf taphataa filadhu",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "fayyadamaa Foundry",
  "KRIPTA.Dialog.Player.AddTitle": "Taphataa Dabali",
  "KRIPTA.Dialog.Player.EditTitle": "Taphataa Gulaali",
  "KRIPTA.Dialog.Player.DeleteTitle": "Taphataa Haqi",
  "KRIPTA.Dialog.Player.DeleteWarning": "Taphataa \"{playerName}\" haquun deebi'uu hin danda'u. \"{code}\" galchiitii haquu mirkaneessi.",
  "KRIPTA.Dialog.Count.TotalCards": "waliigala kaardii gosa kanaa - {max}",
  "KRIPTA.Error.InvalidCardLevel": "{context} dhaaf sadarkaa sirrii hin taane: {level}",
  "KRIPTA.Error.InvalidCardNumber": "{context} dhaaf lakkoofsa sirrii hin taane: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "sadarkaa kaardii sirrii hin taane: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "lakkoofsa kaardii sirrii hin taane: {number}",
  "KRIPTA.Error.InvalidRequestCard": "Gaaffiidhaaf kaardii sirrii hin taane",
  "KRIPTA.Error.InvalidGiveCard": "Kennuudhaaf kaardii sirrii hin taane",
  "KRIPTA.Error.MissingRequestPlayerGuid": "Kaardii kennuudhaaf playerGuid murteessuun hin milkoofne.",
  "KRIPTA.Error.MissingSelectedCard": "Kaardii filatame murteessuun hin milkoofne.",
  "KRIPTA.Error.MissingSelectedCardForGive": "Kaardii kennuudhaaf filatame murteessuun hin milkoofne.",
  "KRIPTA.Error.MissingGivePlayer": "Taphataa kaardii itti kennamu murteessuun hin milkoofne.",
  "KRIPTA.Error.MissingGiveCard": "Kaardii kennamu murteessuun hin milkoofne.",
  "KRIPTA.Error.MissingServerUrl": "Qindaa'inni karaa sarvarii hin jiru.",
  "KRIPTA.Error.InvalidReader": "Fayyadamaan teeknikaa Reader dogoggoraan qindaa'eera.",
  "KRIPTA.Error.InvalidWriter": "Fayyadamaan teeknikaa Writer dogoggoraan qindaa'eera.",
  "KRIPTA.Error.MenuUnavailable": "Amalli kun hin argamu. Qindaa'ina moojulaa sakatta'i. Bal'inaan console biraawzarii keessa jira.",
  "KRIPTA.Error.Generic": "Dogoggorri uumameera",
  "KRIPTA.Error.Unknown": "dogoggora hin beekamne",
  "KRIPTA.Error.NameRequired": "Dirreen Maqaa barbaachisaadha.",
  "KRIPTA.Error.RegistryDeleteReturned": "sarvariin erga haqamee booda taphataa galmee keessatti deebise.",
  "KRIPTA.Notification.CardGiven": "Kaardiin kennameera.",
  "KRIPTA.Notification.CardUsed": "Kaardiin fayyadamee baheera.",
  "KRIPTA.Notification.CardWrittenOff": "Kaardiin haqameera.",
  "KRIPTA.Notification.CannotUseMissingCard": "Kaardiin kun sarvarii irratti kana booda hin galmaa'u. Fayyadamuun hin danda'amu.",
  "KRIPTA.Notification.MissingCard": "Kaardiin kun sarvarii irratti kana booda hin galmaa'u.",
  "KRIPTA.Notification.PlayerNotSelected": "Kaardii kennuudhaaf taphataan hin filatamne",
  "KRIPTA.Notification.PlayerBindingMissing": "Kaardii kennuudhaaf hidhaa taphataa murteessuun hin milkoofne",
  "KRIPTA.Notification.RequestSent": "Gaaffiin kaardii gara chaatitti ergameera.",
  "KRIPTA.Notification.ServerSuccess": "Walitti hidhamiinsi milkaa'eera.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "Walitti hidhamiinsi milkaa'eera. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "Sarvarii wajjin walitti hidhamiinsi hin milkoofne. Teessoo, argamummaa sarvarii, fi qindaa'ina CORS/HTTPS sakatta'i.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "Sarvarii sakatta'uun hin milkoofne.",
  "KRIPTA.Notification.InvalidServerUrl": "Teessoo sarvarii sirrii hin taane: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "Kutaan qindaa'ina Kaardiiwwan Kripta gahee Gaggeessaa Taphaa fi Gargaaraa Gaggeessaa Taphaa qofaf argama.",
  "KRIPTA.Notification.ServerCheckFailed": "Sakatta'iinsi sarvarii hin milkoofne",
  "KRIPTA.Notification.TechUserReader": "Dubbisaa",
  "KRIPTA.Notification.TechUserWriter": "Barreessaa",
  "KRIPTA.Notification.TechUsersCheckSuccess": "Fayyadamtoonni teeknikaa \"Reader\" fi \"Writer\" sakatta'iinsa darbu.",
  "KRIPTA.Notification.SettingsSaved": "Qindaa'inni walitti hidhamiinsaa olkaa'ameera.",
  "KRIPTA.Notification.PlayerAdded": "Taphataan dabalameera.",
  "KRIPTA.Notification.PlayerUpdated": "Taphataan haaromfameera.",
  "KRIPTA.Notification.PlayerDeleted": "Taphataan haqameera.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "Haquun haqameera. Dirreen mirkaneessaa sirnaan hin guutamne.",
  "KRIPTA.Notification.BindingSaved": "Hidhaan olkaa'ameera.",
  "KRIPTA.Notification.BindingDeleted": "Hidhaan haqameera.",
  "KRIPTA.Notification.BadCatalogCardNumber": "Kaardiin filatame lakkoofsa sirrii hin taane qaba. Deebii getCardsList fi normalizeCardsList sakatta'i.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "Kaardiin kun harkaan kennamuu hin danda'u, sababni isaa lakkoofsa sirrii hin taane qaba. Deebii getCardsList fi normalizeCardsList sakatta'i.",
  "KRIPTA.Notification.CardOutputFailed": "Kaardii chaatitti maxxansuun hin milkoofne",
  "KRIPTA.Notification.CardGiveFailed": "Kaardii kennuun hin milkoofne",
  "KRIPTA.Notification.CardUseFailed": "Kaardii fayyadamuun hin milkoofne",
  "KRIPTA.Notification.CardTakeFailed": "Kaardii haquun hin milkoofne",
  "KRIPTA.Notification.CardRequestFailed": "Gaaffii kaardii erguun hin milkoofne",
  "KRIPTA.Notification.CardRequestConfirmFailed": "Kenninsa kaardii mirkaneessuun hin milkoofne",
  "KRIPTA.Notification.PlayerAddFailed": "Taphataa dabaluu hin milkoofne",
  "KRIPTA.Notification.PlayerUpdateFailed": "Taphataa haaromsuun hin milkoofne",
  "KRIPTA.Notification.PlayerDeleteFailed": "Taphataa haquun hin milkoofne",
  "KRIPTA.Notification.CardRollFailed": "Kaardii fudhachuun hin milkoofne.",
  "KRIPTA.Dialog.TakeCard.Title": "Kaardii Fuudhi",
  "KRIPTA.Dialog.TakeCard.Message": "Taphataan {playerName} kaardii {cardName} ni dhaba.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Kaardii Kenni"
}
__END_LOCALE_JSON__
