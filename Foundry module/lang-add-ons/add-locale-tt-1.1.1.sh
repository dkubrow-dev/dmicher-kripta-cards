#!/usr/bin/env sh
set -eu

if [ ! -f "dmicher-kripta-cards/module.json" ]; then
  echo "Run this script from the Foundry module workspace root, next to dmicher-kripta-cards/module.json." >&2
  exit 1
fi

SCRIPT_FILE="$0"
LOCALE_PATH="dmicher-kripta-cards/lang/tt.json"
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
  "lang": "tt",
  "name": "Татарча",
  "path": "lang/tt.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "Сезнең Foundry катнашучысы Крипта карточкалары модулендә сервер уенчысы белән бәйләнмәгән. Уен остасына мөрәҗәгать итегез.",
  "KRIPTA.GMOnly": "Бу гамәл уен остасына гына мөмкин.",
  "KRIPTA.Settings.ServerUrl.Name": "Сервер адресы",
  "KRIPTA.Settings.TechAuthUsers.Name": "Техник кулланучылар",
  "KRIPTA.Settings.PlayerBindings.Name": "Катнашучыларны сервер уенчыларына бәйләү",
  "KRIPTA.Settings.UiPrefs.Name": "Интерфейсның җирле көйләүләре",
  "KRIPTA.Settings.Menu.Name": "Крипта карточкалары",
  "KRIPTA.Settings.Menu.Label": "Модуль көйләүләре",
  "KRIPTA.Settings.Menu.Hint": "API-га тоташу һәм техник кулланучылар.",
  "KRIPTA.Settings.Help.BeforeServerLink": "Әгәр модуль өчен контент серверын әле урнаштырмаган һәм көйләмәгән булсагыз, моны эшләү өчен ",
  "KRIPTA.Settings.Help.ServerLink": "бу сылтамага",
  "KRIPTA.Settings.Help.AfterServerLink": " күчегез. Тиз көйләү өчен ",
  "KRIPTA.Settings.Help.DocumentationLink": "документацияне",
  "KRIPTA.Settings.Help.AfterDocumentationLink": " кулланыгыз.",
  "KRIPTA.Window.Catalog": "Карточкалар каталогы",
  "KRIPTA.Window.CardDetails": "Каталог карточкасы",
  "KRIPTA.Window.GiveCard": "Карточка бирү",
  "KRIPTA.Window.MyCards": "Уенчы карточкалары",
  "KRIPTA.Window.Players": "Уенчылар белән идарә итү",
  "KRIPTA.Window.Registry": "Уенчылар реестры",
  "KRIPTA.Window.RequestCard": "Карточка алу",
  "KRIPTA.Window.Settings": "Крипта карточкалары - Көйләүләр",
  "KRIPTA.Window.UseCard": "Карточканы куллану",
  "KRIPTA.Menu.Title": "Крипта карточкалары",
  "KRIPTA.Menu.Catalog": "Карточкалар каталогы",
  "KRIPTA.Menu.GetCard": "Карточка алу",
  "KRIPTA.Menu.MyCards": "Минем карточкалар",
  "KRIPTA.Menu.Players": "Уенчылар белән идарә итү",
  "KRIPTA.Label.Category": "Категория",
  "KRIPTA.Label.Mode": "Режим",
  "KRIPTA.Label.Card": "Карточка",
  "KRIPTA.Label.Player": "Уенчы",
  "KRIPTA.Label.Name": "Исем",
  "KRIPTA.Label.Comment": "Комментарий",
  "KRIPTA.Label.CardTypes": "Карточка төрләре",
  "KRIPTA.Label.Count": "Сан",
  "KRIPTA.Label.ConfirmationCode": "Раслау коды",
  "KRIPTA.Label.Id": "Идентификатор",
  "KRIPTA.Label.Key": "Ачкыч",
  "KRIPTA.Label.ServerUrl": "Сервер юлы",
  "KRIPTA.Label.Writer": "Язучы (Writer)",
  "KRIPTA.Label.Reader": "Укучы (Reader)",
  "KRIPTA.Label.Role": "Роль",
  "KRIPTA.Label.Binding": "Бәйләнеш",
  "KRIPTA.Role.GM": "Уен остасы",
  "KRIPTA.Role.Player": "Уенчы",
  "KRIPTA.Status.InGame": "уенда",
  "KRIPTA.Status.Offline": "уеннан тыш",
  "KRIPTA.Binding.CardsIssued": "бирелгән карточкалар:",
  "KRIPTA.Binding.NoCards": "карточкалар юк",
  "KRIPTA.Binding.NotBound": "уенчы бәйләнмәгән, уенчыны сайлагыз.",
  "KRIPTA.Binding.CardsCountHint": "Бирелгән карточка төрләре саны (кабатланулар исәпләнми)",
  "KRIPTA.Button.Add": "Өстәү",
  "KRIPTA.Button.Bind": "Бәйләү",
  "KRIPTA.Button.Cancel": "Кире кагу",
  "KRIPTA.Button.Close": "Ябу",
  "KRIPTA.Button.Confirm": "Раслау",
  "KRIPTA.Button.Delete": "Бетерү",
  "KRIPTA.Button.Edit": "Үзгәртү",
  "KRIPTA.Button.Give": "Бирү",
  "KRIPTA.Button.GiveCard": "Карточка бирү",
  "KRIPTA.Button.Info": "Мәгълүмат",
  "KRIPTA.Button.No": "Юк",
  "KRIPTA.Button.Output": "Күрсәтү",
  "KRIPTA.Button.Refresh": "Яңарту",
  "KRIPTA.Button.Registry": "Уенчылар реестры",
  "KRIPTA.Button.Request": "Сорау",
  "KRIPTA.Button.RequestCard": "Алу",
  "KRIPTA.Button.SaveChanges": "Үзгәрешләрне саклау",
  "KRIPTA.Button.Take": "Алып кую",
  "KRIPTA.Button.TestAuth": "Техник кулланучыларны тикшерү",
  "KRIPTA.Button.TestServer": "Серверны тикшерү",
  "KRIPTA.Button.Unbind": "Бәйләнешне өзү",
  "KRIPTA.Button.Use": "Куллану",
  "KRIPTA.Button.Yes": "Әйе",
  "KRIPTA.Mode.Manual": "Сайлап",
  "KRIPTA.Mode.Random": "Очраклы",
  "KRIPTA.Mode.Show": "Күрсәтү",
  "KRIPTA.Mode.Spend": "Сарыф итү",
  "KRIPTA.View.Table": "Таблица",
  "KRIPTA.View.Tiles": "Плиткалар",
  "KRIPTA.Placeholder.Search": "Эзләү",
  "KRIPTA.Select.NotSelected": "-- сайланмаган --",
  "KRIPTA.Template.EmptyCatalog": "Серверда теркәлгән категорияләр яки карточкалар юк.",
  "KRIPTA.Template.MyCardsTitle": "Уенчы карточкалары: {playerName}",
  "KRIPTA.Template.UseCardMissing": "Бу карточка серверда инде теркәлмәгән.",
  "KRIPTA.Template.UseCardPrompt": "Түбәндәге карточка кулланылачак:",
  "KRIPTA.Card.FallbackName": "Карточка {number}",
  "KRIPTA.Card.FallbackAddress": "Карточка {level}/{number}",
  "KRIPTA.Card.MissingDescription": "{level}/{number} карточкасы серверның хәзерге каталогында юк.",
  "KRIPTA.Card.NotRegisteredDescription": "{level}/{number} карточкасы серверда инде теркәлмәгән.",
  "KRIPTA.Level.FallbackName": "Дәрәҗә {level}",
  "KRIPTA.Level.MissingDescription": "Дәрәҗә уенчы инвентарендә бар, ләкин серверның хәзерге каталогында юк.",
  "KRIPTA.Chat.BlobReadFailed": "BLOB укып булмады",
  "KRIPTA.Chat.CardGivenTitle": "Карточка бирелде",
  "KRIPTA.Chat.CardReceiveSubtitle": "{playerName} уенчысы {cardSubtitle} карточкасын ала",
  "KRIPTA.Chat.CardRequestCanceled": "Карточка соравы кире кагылды.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "Карточка соравы расланды",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "Сорау мәгълүматларын укып булмады.",
  "KRIPTA.Chat.CardSpentFooter": "КАРТОЧКА САРЫФ ИТЕЛДЕ",
  "KRIPTA.Chat.CardSpentTitle": "Карточка сарыф ителде",
  "KRIPTA.Chat.FallbackPlayer": "уенчы",
  "KRIPTA.Chat.ManualChoiceFooter": "КУЛДАН САЙЛАУ",
  "KRIPTA.Chat.ReferenceTitle": "Белешмә",
  "KRIPTA.Chat.RequestManualTitle": "Сайланган карточка соравы",
  "KRIPTA.Chat.RequestRandomTitle": "Очраклы карточка соравы",
  "KRIPTA.Chat.ShowCardTitle": "Карточка белешмәсе",
  "KRIPTA.Dialog.BindPlayer.Title": "Сервер уенчысын бәйләү",
  "KRIPTA.Dialog.BindPlayer.Header": "{foundryUserName} өчен уенчы сайлау",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "Foundry кулланучысы",
  "KRIPTA.Dialog.Player.AddTitle": "Уенчы өстәү",
  "KRIPTA.Dialog.Player.EditTitle": "Уенчыны үзгәртү",
  "KRIPTA.Dialog.Player.DeleteTitle": "Уенчыны бетерү",
  "KRIPTA.Dialog.Player.DeleteWarning": "\"{playerName}\" уенчысын бетерү кире кайтарылмый. \"{code}\" кертегез һәм бетерүне раслагыз.",
  "KRIPTA.Dialog.Count.TotalCards": "бу төр карточкаларның гомуми саны - {max}",
  "KRIPTA.Error.InvalidCardLevel": "{context} өчен level дөрес түгел: {level}",
  "KRIPTA.Error.InvalidCardNumber": "{context} өчен number дөрес түгел: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "карточканың level дөрес түгел: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "карточканың number дөрес түгел: {number}",
  "KRIPTA.Error.InvalidRequestCard": "Сорау өчен карточка дөрес түгел",
  "KRIPTA.Error.InvalidGiveCard": "Бирү өчен карточка дөрес түгел",
  "KRIPTA.Error.MissingRequestPlayerGuid": "Карточка бирү өчен playerGuid билгеләп булмады.",
  "KRIPTA.Error.MissingSelectedCard": "Сайланган карточканы билгеләп булмады.",
  "KRIPTA.Error.MissingSelectedCardForGive": "Бирү өчен сайланган карточканы билгеләп булмады.",
  "KRIPTA.Error.MissingGivePlayer": "Карточка бирү өчен уенчыны билгеләп булмады.",
  "KRIPTA.Error.MissingGiveCard": "Бирү өчен карточканы билгеләп булмады.",
  "KRIPTA.Error.MissingServerUrl": "Сервер юлы көйләве юк.",
  "KRIPTA.Error.InvalidReader": "Reader техник кулланучысы дөрес көйләнмәгән.",
  "KRIPTA.Error.InvalidWriter": "Writer техник кулланучысы дөрес көйләнмәгән.",
  "KRIPTA.Error.MenuUnavailable": "Функция эшләми. Модуль көйләүләрен тикшерегез. Тулырак мәгълүмат браузер консолында.",
  "KRIPTA.Error.Generic": "Хата килеп чыкты",
  "KRIPTA.Error.Unknown": "билгесез хата",
  "KRIPTA.Error.NameRequired": "Исем кыры мәҗбүри.",
  "KRIPTA.Error.RegistryDeleteReturned": "сервер бетергәннән соң уенчыны реестрга кире кайтарды.",
  "KRIPTA.Notification.CardGiven": "Карточка бирелде.",
  "KRIPTA.Notification.CardUsed": "Карточка кулланылды һәм исәптән чыгарылды.",
  "KRIPTA.Notification.CardWrittenOff": "Карточка исәптән чыгарылды.",
  "KRIPTA.Notification.CannotUseMissingCard": "Бу карточка серверда инде теркәлмәгән. Куллану мөмкин түгел.",
  "KRIPTA.Notification.MissingCard": "Бу карточка серверда инде теркәлмәгән.",
  "KRIPTA.Notification.PlayerNotSelected": "Карточка бирү өчен уенчы сайланмаган",
  "KRIPTA.Notification.PlayerBindingMissing": "Карточка бирү өчен уенчы бәйләнешен билгеләп булмады",
  "KRIPTA.Notification.RequestSent": "Карточка соравы чатка җибәрелде.",
  "KRIPTA.Notification.ServerSuccess": "Тоташу уңышлы.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "Тоташу уңышлы. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "Серверга тоташып булмады. Адресны, серверның эшләвен һәм CORS/HTTPS көйләүләрен тикшерегез.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "Серверны тикшереп булмады.",
  "KRIPTA.Notification.InvalidServerUrl": "Сервер адресы дөрес түгел: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "«Крипта карточкалары» көйләүләре бүлеге «Алып баручы» һәм «Алып баручы ярдәмчесе» рольләренә генә мөмкин.",
  "KRIPTA.Notification.ServerCheckFailed": "Серверны тикшерү уңышсыз булды",
  "KRIPTA.Notification.TechUserReader": "Укучы",
  "KRIPTA.Notification.TechUserWriter": "Язучы",
  "KRIPTA.Notification.TechUsersCheckSuccess": "\"Reader\" һәм \"Writer\" техник кулланучылары тикшерүне уңышлы үтә.",
  "KRIPTA.Notification.SettingsSaved": "Тоташу көйләүләре сакланды.",
  "KRIPTA.Notification.PlayerAdded": "Уенчы өстәлде.",
  "KRIPTA.Notification.PlayerUpdated": "Уенчы яңартылды.",
  "KRIPTA.Notification.PlayerDeleted": "Уенчы бетерелде.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "Бетерү кире кагылды. Контроль кыр дөрес тутырылмаган.",
  "KRIPTA.Notification.BindingSaved": "Бәйләнеш сакланды.",
  "KRIPTA.Notification.BindingDeleted": "Бәйләнеш бетерелде.",
  "KRIPTA.Notification.BadCatalogCardNumber": "Сайланган карточканың номеры дөрес түгел. getCardsList җавабын һәм normalizeCardsList тикшерегез.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "Бу карточканы кулдан биреп булмый: аның номеры дөрес түгел. getCardsList җавабын һәм normalizeCardsList тикшерегез.",
  "KRIPTA.Notification.CardOutputFailed": "Карточканы чатка чыгарып булмады",
  "KRIPTA.Notification.CardGiveFailed": "Карточка биреп булмады",
  "KRIPTA.Notification.CardUseFailed": "Карточканы кулланып булмады",
  "KRIPTA.Notification.CardTakeFailed": "Карточканы исәптән чыгарып булмады",
  "KRIPTA.Notification.CardRequestFailed": "Карточка соравын җибәреп булмады",
  "KRIPTA.Notification.CardRequestConfirmFailed": "Карточка бирүне раслап булмады",
  "KRIPTA.Notification.PlayerAddFailed": "Уенчыны өстәп булмады",
  "KRIPTA.Notification.PlayerUpdateFailed": "Уенчыны яңартып булмады",
  "KRIPTA.Notification.PlayerDeleteFailed": "Уенчыны бетереп булмады",
  "KRIPTA.Notification.CardRollFailed": "Карточка алып булмады.",
  "KRIPTA.Dialog.TakeCard.Title": "Карточканы алу",
  "KRIPTA.Dialog.TakeCard.Message": "{playerName} уенчысы {cardName} карточкасыннан мәхрүм ителәчәк.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Карточка бирү"
}
__END_LOCALE_JSON__
