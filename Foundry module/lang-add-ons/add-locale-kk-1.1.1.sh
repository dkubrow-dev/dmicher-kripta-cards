#!/usr/bin/env sh
set -eu

if [ ! -f "dmicher-kripta-cards/module.json" ]; then
  echo "Run this script from the Foundry module workspace root, next to dmicher-kripta-cards/module.json." >&2
  exit 1
fi

SCRIPT_FILE="$0"
LOCALE_PATH="dmicher-kripta-cards/lang/kk.json"
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
  "lang": "kk",
  "name": "Қазақша",
  "path": "lang/kk.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "Foundry пайдаланушыңыз Kripta Cards модулінде сервер ойыншысымен байланыстырылмаған. Ойын шеберіне хабарласыңыз.",
  "KRIPTA.GMOnly": "Бұл әрекет тек ойын шеберіне қолжетімді.",
  "KRIPTA.Settings.ServerUrl.Name": "Сервер мекенжайы",
  "KRIPTA.Settings.TechAuthUsers.Name": "Техникалық пайдаланушылар",
  "KRIPTA.Settings.PlayerBindings.Name": "Foundry пайдаланушыларын сервер ойыншыларымен байланыстыру",
  "KRIPTA.Settings.UiPrefs.Name": "Жергілікті интерфейс баптаулары",
  "KRIPTA.Settings.Menu.Name": "Kripta Cards",
  "KRIPTA.Settings.Menu.Label": "Модуль баптаулары",
  "KRIPTA.Settings.Menu.Hint": "API қосылымы және техникалық пайдаланушылар.",
  "KRIPTA.Settings.Help.BeforeServerLink": "Егер модульге арналған контент серверін әлі орнатып, баптамаған болсаңыз, мұны істеу үшін ",
  "KRIPTA.Settings.Help.ServerLink": "осы сілтемеге",
  "KRIPTA.Settings.Help.AfterServerLink": " өтіңіз. Жылдам баптау үшін ",
  "KRIPTA.Settings.Help.DocumentationLink": "құжаттаманы",
  "KRIPTA.Settings.Help.AfterDocumentationLink": " пайдаланыңыз.",
  "KRIPTA.Window.Catalog": "Карталар каталогы",
  "KRIPTA.Window.CardDetails": "Каталог картасы",
  "KRIPTA.Window.GiveCard": "Карта беру",
  "KRIPTA.Window.MyCards": "Ойыншы карталары",
  "KRIPTA.Window.Players": "Ойыншыларды басқару",
  "KRIPTA.Window.Registry": "Ойыншылар тізілімі",
  "KRIPTA.Window.RequestCard": "Карта сұрау",
  "KRIPTA.Window.Settings": "Kripta Cards - Баптаулар",
  "KRIPTA.Window.UseCard": "Картаны пайдалану",
  "KRIPTA.Menu.Title": "Kripta Cards",
  "KRIPTA.Menu.Catalog": "Карталар каталогы",
  "KRIPTA.Menu.GetCard": "Карта сұрау",
  "KRIPTA.Menu.MyCards": "Менің карталарым",
  "KRIPTA.Menu.Players": "Ойыншыларды басқару",
  "KRIPTA.Label.Category": "Санат",
  "KRIPTA.Label.Mode": "Режим",
  "KRIPTA.Label.Card": "Карта",
  "KRIPTA.Label.Player": "Ойыншы",
  "KRIPTA.Label.Name": "Аты",
  "KRIPTA.Label.Comment": "Пікір",
  "KRIPTA.Label.CardTypes": "Карта түрлері",
  "KRIPTA.Label.Count": "Саны",
  "KRIPTA.Label.ConfirmationCode": "Растау коды",
  "KRIPTA.Label.Id": "Id",
  "KRIPTA.Label.Key": "Key",
  "KRIPTA.Label.ServerUrl": "Сервер URL",
  "KRIPTA.Label.Writer": "Writer",
  "KRIPTA.Label.Reader": "Reader",
  "KRIPTA.Label.Role": "Рөл",
  "KRIPTA.Label.Binding": "Байланыс",
  "KRIPTA.Role.GM": "Ойын шебері",
  "KRIPTA.Role.Player": "Ойыншы",
  "KRIPTA.Status.InGame": "онлайн",
  "KRIPTA.Status.Offline": "офлайн",
  "KRIPTA.Binding.CardsIssued": "берілген карталар:",
  "KRIPTA.Binding.NoCards": "карта жоқ",
  "KRIPTA.Binding.NotBound": "ойыншы байланыстырылмаған, ойыншыны байланыстырыңыз.",
  "KRIPTA.Binding.CardsCountHint": "Қайталауларды есептемегендегі берілген карта түрлерінің саны",
  "KRIPTA.Button.Add": "Қосу",
  "KRIPTA.Button.Bind": "Байланыстыру",
  "KRIPTA.Button.Cancel": "Болдырмау",
  "KRIPTA.Button.Close": "Жабу",
  "KRIPTA.Button.Confirm": "Растау",
  "KRIPTA.Button.Delete": "Жою",
  "KRIPTA.Button.Edit": "Өзгерту",
  "KRIPTA.Button.Give": "Беру",
  "KRIPTA.Button.GiveCard": "Карта беру",
  "KRIPTA.Button.Info": "Ақпарат",
  "KRIPTA.Button.No": "Жоқ",
  "KRIPTA.Button.Output": "Жариялау",
  "KRIPTA.Button.Refresh": "Жаңарту",
  "KRIPTA.Button.Registry": "Ойыншылар тізілімі",
  "KRIPTA.Button.Request": "Сұрау",
  "KRIPTA.Button.RequestCard": "Сұрау",
  "KRIPTA.Button.SaveChanges": "Өзгерістерді сақтау",
  "KRIPTA.Button.Take": "Алу",
  "KRIPTA.Button.TestAuth": "Техникалық пайдаланушыларды тексеру",
  "KRIPTA.Button.TestServer": "Серверді тексеру",
  "KRIPTA.Button.Unbind": "Байланысты үзу",
  "KRIPTA.Button.Use": "Пайдалану",
  "KRIPTA.Button.Yes": "Иә",
  "KRIPTA.Mode.Manual": "Қолмен таңдау",
  "KRIPTA.Mode.Random": "Кездейсоқ",
  "KRIPTA.Mode.Show": "Көрсету",
  "KRIPTA.Mode.Spend": "Жұмсау",
  "KRIPTA.View.Table": "Кесте",
  "KRIPTA.View.Tiles": "Плиткалар",
  "KRIPTA.Placeholder.Search": "Іздеу",
  "KRIPTA.Select.NotSelected": "-- таңдалмаған --",
  "KRIPTA.Template.EmptyCatalog": "Серверде тіркелген санаттар немесе карталар жоқ.",
  "KRIPTA.Template.MyCardsTitle": "Ойыншы карталары: {playerName}",
  "KRIPTA.Template.UseCardMissing": "Бұл карта енді серверде тіркелмеген.",
  "KRIPTA.Template.UseCardPrompt": "Бұл карта пайдаланылады:",
  "KRIPTA.Card.FallbackName": "Карта {number}",
  "KRIPTA.Card.FallbackAddress": "Карта {level}/{number}",
  "KRIPTA.Card.MissingDescription": "Карта {level}/{number} ағымдағы сервер каталогында жоқ.",
  "KRIPTA.Card.NotRegisteredDescription": "Карта {level}/{number} енді серверде тіркелмеген.",
  "KRIPTA.Level.FallbackName": "Деңгей {level}",
  "KRIPTA.Level.MissingDescription": "Бұл деңгей ойыншының инвентарында бар, бірақ ағымдағы сервер каталогында жоқ.",
  "KRIPTA.Chat.BlobReadFailed": "blob оқылмады",
  "KRIPTA.Chat.CardGivenTitle": "Карта берілді",
  "KRIPTA.Chat.CardReceiveSubtitle": "Ойыншы {playerName} {cardSubtitle} картасын алады",
  "KRIPTA.Chat.CardRequestCanceled": "Карта сұрауы болдырылмады.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "Карта сұрауы расталды",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "Сұрау деректері оқылмады.",
  "KRIPTA.Chat.CardSpentFooter": "КАРТА ЖҰМСАЛДЫ",
  "KRIPTA.Chat.CardSpentTitle": "Карта жұмсалды",
  "KRIPTA.Chat.FallbackPlayer": "ойыншы",
  "KRIPTA.Chat.ManualChoiceFooter": "ҚОЛМЕН ТАҢДАУ",
  "KRIPTA.Chat.ReferenceTitle": "Анықтама",
  "KRIPTA.Chat.RequestManualTitle": "Таңдалған карта сұрауы",
  "KRIPTA.Chat.RequestRandomTitle": "Кездейсоқ карта сұрауы",
  "KRIPTA.Chat.ShowCardTitle": "Карта анықтамасы",
  "KRIPTA.Dialog.BindPlayer.Title": "Сервер ойыншысын байланыстыру",
  "KRIPTA.Dialog.BindPlayer.Header": "{foundryUserName} үшін ойыншы таңдаңыз",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "Foundry пайдаланушысы",
  "KRIPTA.Dialog.Player.AddTitle": "Ойыншы қосу",
  "KRIPTA.Dialog.Player.EditTitle": "Ойыншыны өзгерту",
  "KRIPTA.Dialog.Player.DeleteTitle": "Ойыншыны жою",
  "KRIPTA.Dialog.Player.DeleteWarning": "\"{playerName}\" ойыншысын жоюды қайтару мүмкін емес. \"{code}\" енгізіп, жоюды растаңыз.",
  "KRIPTA.Dialog.Count.TotalCards": "осы түрдегі жалпы карталар - {max}",
  "KRIPTA.Error.InvalidCardLevel": "{context} үшін қате деңгей: {level}",
  "KRIPTA.Error.InvalidCardNumber": "{context} үшін қате нөмір: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "қате карта деңгейі: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "қате карта нөмірі: {number}",
  "KRIPTA.Error.InvalidRequestCard": "Сұрау үшін қате карта",
  "KRIPTA.Error.InvalidGiveCard": "Беру үшін қате карта",
  "KRIPTA.Error.MissingRequestPlayerGuid": "Карта беру үшін playerGuid анықталмады.",
  "KRIPTA.Error.MissingSelectedCard": "Таңдалған карта анықталмады.",
  "KRIPTA.Error.MissingSelectedCardForGive": "Беру үшін таңдалған карта анықталмады.",
  "KRIPTA.Error.MissingGivePlayer": "Карта берілетін ойыншы анықталмады.",
  "KRIPTA.Error.MissingGiveCard": "Берілетін карта анықталмады.",
  "KRIPTA.Error.MissingServerUrl": "Сервер жолының баптауы жоқ.",
  "KRIPTA.Error.InvalidReader": "Reader техникалық пайдаланушысы қате бапталған.",
  "KRIPTA.Error.InvalidWriter": "Writer техникалық пайдаланушысы қате бапталған.",
  "KRIPTA.Error.MenuUnavailable": "Бұл функция қолжетімді емес. Модуль баптауларын тексеріңіз. Толығырақ браузер консолінде.",
  "KRIPTA.Error.Generic": "Қате орын алды",
  "KRIPTA.Error.Unknown": "белгісіз қате",
  "KRIPTA.Error.NameRequired": "Name өрісі міндетті.",
  "KRIPTA.Error.RegistryDeleteReturned": "жоюдан кейін сервер ойыншыны тізілімде қайтарды.",
  "KRIPTA.Notification.CardGiven": "Карта берілді.",
  "KRIPTA.Notification.CardUsed": "Карта пайдаланылып, жұмсалды.",
  "KRIPTA.Notification.CardWrittenOff": "Карта алынып тасталды.",
  "KRIPTA.Notification.CannotUseMissingCard": "Бұл карта енді серверде тіркелмеген. Оны пайдалану мүмкін емес.",
  "KRIPTA.Notification.MissingCard": "Бұл карта енді серверде тіркелмеген.",
  "KRIPTA.Notification.PlayerNotSelected": "Карта беру үшін ойыншы таңдалмаған",
  "KRIPTA.Notification.PlayerBindingMissing": "Карта беру үшін ойыншы байланысы анықталмады",
  "KRIPTA.Notification.RequestSent": "Карта сұрауы чатқа жіберілді.",
  "KRIPTA.Notification.ServerSuccess": "Қосылым сәтті.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "Қосылым сәтті. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "Серверге қосылу мүмкін болмады. Мекенжайды, сервер қолжетімділігін және CORS/HTTPS баптауларын тексеріңіз.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "Сервер тексерілмеді.",
  "KRIPTA.Notification.InvalidServerUrl": "Қате сервер мекенжайы: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "Kripta Cards баптаулары бөлімі тек Ойын шебері және Ойын шеберінің көмекшісі рөлдері үшін қолжетімді.",
  "KRIPTA.Notification.ServerCheckFailed": "Сервер тексерісі сәтсіз",
  "KRIPTA.Notification.TechUserReader": "Reader",
  "KRIPTA.Notification.TechUserWriter": "Writer",
  "KRIPTA.Notification.TechUsersCheckSuccess": "\"Reader\" және \"Writer\" техникалық пайдаланушылары тексерістен өтті.",
  "KRIPTA.Notification.SettingsSaved": "Қосылым баптаулары сақталды.",
  "KRIPTA.Notification.PlayerAdded": "Ойыншы қосылды.",
  "KRIPTA.Notification.PlayerUpdated": "Ойыншы жаңартылды.",
  "KRIPTA.Notification.PlayerDeleted": "Ойыншы жойылды.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "Жою болдырылмады. Растау өрісі қате толтырылған.",
  "KRIPTA.Notification.BindingSaved": "Байланыс сақталды.",
  "KRIPTA.Notification.BindingDeleted": "Байланыс жойылды.",
  "KRIPTA.Notification.BadCatalogCardNumber": "Таңдалған картаның нөмірі қате. getCardsList жауабын және normalizeCardsList-ті тексеріңіз.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "Бұл картаны қолмен беру мүмкін емес, себебі оның нөмірі қате. getCardsList жауабын және normalizeCardsList-ті тексеріңіз.",
  "KRIPTA.Notification.CardOutputFailed": "Картаны чатқа жариялау мүмкін болмады",
  "KRIPTA.Notification.CardGiveFailed": "Карта беру мүмкін болмады",
  "KRIPTA.Notification.CardUseFailed": "Картаны пайдалану мүмкін болмады",
  "KRIPTA.Notification.CardTakeFailed": "Картаны алып тастау мүмкін болмады",
  "KRIPTA.Notification.CardRequestFailed": "Карта сұрауын жіберу мүмкін болмады",
  "KRIPTA.Notification.CardRequestConfirmFailed": "Карта беруді растау мүмкін болмады",
  "KRIPTA.Notification.PlayerAddFailed": "Ойыншы қосу мүмкін болмады",
  "KRIPTA.Notification.PlayerUpdateFailed": "Ойыншыны жаңарту мүмкін болмады",
  "KRIPTA.Notification.PlayerDeleteFailed": "Ойыншыны жою мүмкін болмады",
  "KRIPTA.Notification.CardRollFailed": "Карта алу мүмкін болмады.",
  "KRIPTA.Dialog.TakeCard.Title": "Картаны алу",
  "KRIPTA.Dialog.TakeCard.Message": "Ойыншы {playerName} {cardName} картасынан айырылады.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Карта беру"
}
__END_LOCALE_JSON__
