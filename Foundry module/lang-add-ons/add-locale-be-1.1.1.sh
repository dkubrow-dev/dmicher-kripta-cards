#!/usr/bin/env sh
set -eu

if [ ! -f "dmicher-kripta-cards/module.json" ]; then
  echo "Run this script from the Foundry module workspace root, next to dmicher-kripta-cards/module.json." >&2
  exit 1
fi

SCRIPT_FILE="$0"
LOCALE_PATH="dmicher-kripta-cards/lang/be.json"
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
  "lang": "be",
  "name": "Беларуская",
  "path": "lang/be.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "Ваш карыстальнік Foundry не прывязаны да гульца сервера ў модулі Kripta Cards. Звярніцеся да майстра гульні.",
  "KRIPTA.GMOnly": "Гэта дзеянне даступнае толькі майстру гульні.",
  "KRIPTA.Settings.ServerUrl.Name": "Адрас сервера",
  "KRIPTA.Settings.TechAuthUsers.Name": "Тэхнічныя карыстальнікі",
  "KRIPTA.Settings.PlayerBindings.Name": "Прывязкі карыстальнікаў Foundry да гульцоў сервера",
  "KRIPTA.Settings.UiPrefs.Name": "Лакальныя налады інтэрфейсу",
  "KRIPTA.Settings.Menu.Name": "Kripta Cards",
  "KRIPTA.Settings.Menu.Label": "Налады модуля",
  "KRIPTA.Settings.Menu.Hint": "Падключэнне да API і тэхнічныя карыстальнікі.",
  "KRIPTA.Settings.Help.BeforeServerLink": "Калі вы яшчэ не ўсталявалі і не наладзілі сервер кантэнту для модуля, перайдзіце ",
  "KRIPTA.Settings.Help.ServerLink": "па спасылцы",
  "KRIPTA.Settings.Help.AfterServerLink": ", каб зрабіць гэта. Для хуткай наладкі скарыстайцеся ",
  "KRIPTA.Settings.Help.DocumentationLink": "дакументацыяй",
  "KRIPTA.Settings.Help.AfterDocumentationLink": ".",
  "KRIPTA.Window.Catalog": "Каталог картак",
  "KRIPTA.Window.CardDetails": "Картка каталога",
  "KRIPTA.Window.GiveCard": "Выдаць картку",
  "KRIPTA.Window.MyCards": "Карткі гульца",
  "KRIPTA.Window.Players": "Кіраванне гульцамі",
  "KRIPTA.Window.Registry": "Рэестр гульцоў",
  "KRIPTA.Window.RequestCard": "Запытаць картку",
  "KRIPTA.Window.Settings": "Kripta Cards - Налады",
  "KRIPTA.Window.UseCard": "Выкарыстаць картку",
  "KRIPTA.Menu.Title": "Kripta Cards",
  "KRIPTA.Menu.Catalog": "Каталог картак",
  "KRIPTA.Menu.GetCard": "Запытаць картку",
  "KRIPTA.Menu.MyCards": "Мае карткі",
  "KRIPTA.Menu.Players": "Кіраванне гульцамі",
  "KRIPTA.Label.Category": "Катэгорыя",
  "KRIPTA.Label.Mode": "Рэжым",
  "KRIPTA.Label.Card": "Картка",
  "KRIPTA.Label.Player": "Гулец",
  "KRIPTA.Label.Name": "Імя",
  "KRIPTA.Label.Comment": "Каментар",
  "KRIPTA.Label.CardTypes": "Тыпы картак",
  "KRIPTA.Label.Count": "Колькасць",
  "KRIPTA.Label.ConfirmationCode": "Код пацвярджэння",
  "KRIPTA.Label.Id": "Id",
  "KRIPTA.Label.Key": "Key",
  "KRIPTA.Label.ServerUrl": "URL сервера",
  "KRIPTA.Label.Writer": "Writer",
  "KRIPTA.Label.Reader": "Reader",
  "KRIPTA.Label.Role": "Роля",
  "KRIPTA.Label.Binding": "Прывязка",
  "KRIPTA.Role.GM": "Майстар гульні",
  "KRIPTA.Role.Player": "Гулец",
  "KRIPTA.Status.InGame": "анлайн",
  "KRIPTA.Status.Offline": "афлайн",
  "KRIPTA.Binding.CardsIssued": "выдадзена картак:",
  "KRIPTA.Binding.NoCards": "няма картак",
  "KRIPTA.Binding.NotBound": "гулец не прывязаны, прывяжыце гульца.",
  "KRIPTA.Binding.CardsCountHint": "Колькасць выдадзеных тыпаў картак без уліку паўтораў",
  "KRIPTA.Button.Add": "Дадаць",
  "KRIPTA.Button.Bind": "Прывязаць",
  "KRIPTA.Button.Cancel": "Скасаваць",
  "KRIPTA.Button.Close": "Закрыць",
  "KRIPTA.Button.Confirm": "Пацвердзіць",
  "KRIPTA.Button.Delete": "Выдаліць",
  "KRIPTA.Button.Edit": "Змяніць",
  "KRIPTA.Button.Give": "Выдаць",
  "KRIPTA.Button.GiveCard": "Выдаць картку",
  "KRIPTA.Button.Info": "Інфармацыя",
  "KRIPTA.Button.No": "Не",
  "KRIPTA.Button.Output": "Апублікаваць",
  "KRIPTA.Button.Refresh": "Абнавіць",
  "KRIPTA.Button.Registry": "Рэестр гульцоў",
  "KRIPTA.Button.Request": "Запытаць",
  "KRIPTA.Button.RequestCard": "Запытаць",
  "KRIPTA.Button.SaveChanges": "Захаваць змены",
  "KRIPTA.Button.Take": "Забраць",
  "KRIPTA.Button.TestAuth": "Праверыць тэхнічных карыстальнікаў",
  "KRIPTA.Button.TestServer": "Праверыць сервер",
  "KRIPTA.Button.Unbind": "Адвязаць",
  "KRIPTA.Button.Use": "Выкарыстаць",
  "KRIPTA.Button.Yes": "Так",
  "KRIPTA.Mode.Manual": "Выбраць уручную",
  "KRIPTA.Mode.Random": "Выпадкова",
  "KRIPTA.Mode.Show": "Паказаць",
  "KRIPTA.Mode.Spend": "Выдаткаваць",
  "KRIPTA.View.Table": "Табліца",
  "KRIPTA.View.Tiles": "Пліткі",
  "KRIPTA.Placeholder.Search": "Пошук",
  "KRIPTA.Select.NotSelected": "-- не выбрана --",
  "KRIPTA.Template.EmptyCatalog": "На серверы няма зарэгістраваных катэгорый або картак.",
  "KRIPTA.Template.MyCardsTitle": "Карткі гульца: {playerName}",
  "KRIPTA.Template.UseCardMissing": "Гэтая картка больш не зарэгістравана на серверы.",
  "KRIPTA.Template.UseCardPrompt": "Будзе выкарыстана гэтая картка:",
  "KRIPTA.Card.FallbackName": "Картка {number}",
  "KRIPTA.Card.FallbackAddress": "Картка {level}/{number}",
  "KRIPTA.Card.MissingDescription": "Картка {level}/{number} адсутнічае ў бягучым каталогу сервера.",
  "KRIPTA.Card.NotRegisteredDescription": "Картка {level}/{number} больш не зарэгістравана на серверы.",
  "KRIPTA.Level.FallbackName": "Узровень {level}",
  "KRIPTA.Level.MissingDescription": "Гэты ўзровень ёсць у інвентары гульца, але адсутнічае ў бягучым каталогу сервера.",
  "KRIPTA.Chat.BlobReadFailed": "Не ўдалося прачытаць blob",
  "KRIPTA.Chat.CardGivenTitle": "Картка выдадзена",
  "KRIPTA.Chat.CardReceiveSubtitle": "Гулец {playerName} атрымлівае картку {cardSubtitle}",
  "KRIPTA.Chat.CardRequestCanceled": "Запыт карткі скасаваны.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "Запыт карткі пацверджаны",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "Не ўдалося прачытаць даныя запыту.",
  "KRIPTA.Chat.CardSpentFooter": "КАРТКА ВЫДАТКАВАНА",
  "KRIPTA.Chat.CardSpentTitle": "Картка выдаткавана",
  "KRIPTA.Chat.FallbackPlayer": "гулец",
  "KRIPTA.Chat.ManualChoiceFooter": "РУЧНЫ ВЫБАР",
  "KRIPTA.Chat.ReferenceTitle": "Даведка",
  "KRIPTA.Chat.RequestManualTitle": "Запыт выбранай карткі",
  "KRIPTA.Chat.RequestRandomTitle": "Запыт выпадковай карткі",
  "KRIPTA.Chat.ShowCardTitle": "Даведка па картцы",
  "KRIPTA.Dialog.BindPlayer.Title": "Прывязаць гульца сервера",
  "KRIPTA.Dialog.BindPlayer.Header": "Выберыце гульца для {foundryUserName}",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "карыстальніка Foundry",
  "KRIPTA.Dialog.Player.AddTitle": "Дадаць гульца",
  "KRIPTA.Dialog.Player.EditTitle": "Змяніць гульца",
  "KRIPTA.Dialog.Player.DeleteTitle": "Выдаліць гульца",
  "KRIPTA.Dialog.Player.DeleteWarning": "Выдаленне гульца \"{playerName}\" немагчыма адмяніць. Увядзіце \"{code}\" і пацвердзіце выдаленне.",
  "KRIPTA.Dialog.Count.TotalCards": "усяго картак гэтага тыпу - {max}",
  "KRIPTA.Error.InvalidCardLevel": "Няправільны ўзровень для {context}: {level}",
  "KRIPTA.Error.InvalidCardNumber": "Няправільны нумар для {context}: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "няправільны ўзровень карткі: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "няправільны нумар карткі: {number}",
  "KRIPTA.Error.InvalidRequestCard": "Няправільная картка для запыту",
  "KRIPTA.Error.InvalidGiveCard": "Няправільная картка для выдачы",
  "KRIPTA.Error.MissingRequestPlayerGuid": "Не ўдалося вызначыць playerGuid для выдачы карткі.",
  "KRIPTA.Error.MissingSelectedCard": "Не ўдалося вызначыць выбраную картку.",
  "KRIPTA.Error.MissingSelectedCardForGive": "Не ўдалося вызначыць выбраную картку для выдачы.",
  "KRIPTA.Error.MissingGivePlayer": "Не ўдалося вызначыць гульца для выдачы карткі.",
  "KRIPTA.Error.MissingGiveCard": "Не ўдалося вызначыць картку для выдачы.",
  "KRIPTA.Error.MissingServerUrl": "Адсутнічае налада шляху да сервера.",
  "KRIPTA.Error.InvalidReader": "Тэхнічны карыстальнік Reader настроены няправільна.",
  "KRIPTA.Error.InvalidWriter": "Тэхнічны карыстальнік Writer настроены няправільна.",
  "KRIPTA.Error.MenuUnavailable": "Гэтая функцыя недаступная. Праверце налады модуля. Падрабязнасці ў кансолі браўзера.",
  "KRIPTA.Error.Generic": "Адбылася памылка",
  "KRIPTA.Error.Unknown": "невядомая памылка",
  "KRIPTA.Error.NameRequired": "Поле Name абавязковае.",
  "KRIPTA.Error.RegistryDeleteReturned": "сервер вярнуў гульца ў рэестры пасля выдалення.",
  "KRIPTA.Notification.CardGiven": "Картка выдадзена.",
  "KRIPTA.Notification.CardUsed": "Картка выкарыстана і спісана.",
  "KRIPTA.Notification.CardWrittenOff": "Картка выдалена.",
  "KRIPTA.Notification.CannotUseMissingCard": "Гэтая картка больш не зарэгістравана на серверы. Яе нельга выкарыстаць.",
  "KRIPTA.Notification.MissingCard": "Гэтая картка больш не зарэгістравана на серверы.",
  "KRIPTA.Notification.PlayerNotSelected": "Не выбраны гулец для выдачы карткі",
  "KRIPTA.Notification.PlayerBindingMissing": "Не ўдалося вызначыць прывязку гульца для выдачы карткі",
  "KRIPTA.Notification.RequestSent": "Запыт карткі адпраўлены ў чат.",
  "KRIPTA.Notification.ServerSuccess": "Падключэнне паспяховае.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "Падключэнне паспяховае. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "Не ўдалося падключыцца да сервера. Праверце адрас, даступнасць сервера і налады CORS/HTTPS.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "Не ўдалося праверыць сервер.",
  "KRIPTA.Notification.InvalidServerUrl": "Няправільны адрас сервера: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "Раздзел налад Kripta Cards даступны толькі ролям Майстар гульні і Памочнік майстра гульні.",
  "KRIPTA.Notification.ServerCheckFailed": "Праверка сервера не ўдалася",
  "KRIPTA.Notification.TechUserReader": "Reader",
  "KRIPTA.Notification.TechUserWriter": "Writer",
  "KRIPTA.Notification.TechUsersCheckSuccess": "Тэхнічныя карыстальнікі \"Reader\" і \"Writer\" паспяхова прайшлі праверку.",
  "KRIPTA.Notification.SettingsSaved": "Налады падключэння захаваныя.",
  "KRIPTA.Notification.PlayerAdded": "Гулец дададзены.",
  "KRIPTA.Notification.PlayerUpdated": "Гулец абноўлены.",
  "KRIPTA.Notification.PlayerDeleted": "Гулец выдалены.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "Выдаленне скасавана. Поле пацвярджэння запоўнена няправільна.",
  "KRIPTA.Notification.BindingSaved": "Прывязка захаваная.",
  "KRIPTA.Notification.BindingDeleted": "Прывязка выдаленая.",
  "KRIPTA.Notification.BadCatalogCardNumber": "Выбраная картка мае няправільны нумар. Праверце адказ getCardsList і normalizeCardsList.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "Гэтую картку нельга выдаць уручную, бо яна мае няправільны нумар. Праверце адказ getCardsList і normalizeCardsList.",
  "KRIPTA.Notification.CardOutputFailed": "Не ўдалося апублікаваць картку ў чаце",
  "KRIPTA.Notification.CardGiveFailed": "Не ўдалося выдаць картку",
  "KRIPTA.Notification.CardUseFailed": "Не ўдалося выкарыстаць картку",
  "KRIPTA.Notification.CardTakeFailed": "Не ўдалося выдаліць картку",
  "KRIPTA.Notification.CardRequestFailed": "Не ўдалося адправіць запыт карткі",
  "KRIPTA.Notification.CardRequestConfirmFailed": "Не ўдалося пацвердзіць выдачу карткі",
  "KRIPTA.Notification.PlayerAddFailed": "Не ўдалося дадаць гульца",
  "KRIPTA.Notification.PlayerUpdateFailed": "Не ўдалося абнавіць гульца",
  "KRIPTA.Notification.PlayerDeleteFailed": "Не ўдалося выдаліць гульца",
  "KRIPTA.Notification.CardRollFailed": "Не ўдалося атрымаць картку.",
  "KRIPTA.Dialog.TakeCard.Title": "Забраць картку",
  "KRIPTA.Dialog.TakeCard.Message": "Гулец {playerName} страціць картку {cardName}.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Выдаць картку"
}
__END_LOCALE_JSON__
