#!/usr/bin/env sh
set -eu

if [ ! -f "dmicher-kripta-cards/module.json" ]; then
  echo "Run this script from the Foundry module workspace root, next to dmicher-kripta-cards/module.json." >&2
  exit 1
fi

SCRIPT_FILE="$0"
LOCALE_PATH="dmicher-kripta-cards/lang/tg.json"
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
  "lang": "tg",
  "name": "Тоҷикӣ",
  "path": "lang/tg.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "Иштирокчии Foundry-и шумо ба бозигари сервер дар модули Кортҳои Крипта пайваст нашудааст. Ба устоди бозӣ муроҷиат кунед.",
  "KRIPTA.GMOnly": "Ин амал танҳо барои устод дастрас аст.",
  "KRIPTA.Settings.ServerUrl.Name": "Нишонии сервер",
  "KRIPTA.Settings.TechAuthUsers.Name": "Корбарони техникӣ",
  "KRIPTA.Settings.PlayerBindings.Name": "Пайвастҳои иштирокчиёни Foundry ба бозигарони сервер",
  "KRIPTA.Settings.UiPrefs.Name": "Танзимоти маҳаллии интерфейс",
  "KRIPTA.Settings.Menu.Name": "Кортҳои Крипта",
  "KRIPTA.Settings.Menu.Label": "Танзими модул",
  "KRIPTA.Settings.Menu.Hint": "Пайвастшавӣ ба API ва корбарони техникӣ.",
  "KRIPTA.Settings.Help.BeforeServerLink": "Агар шумо ҳанӯз сервери мундариҷаро барои модул насб ва танзим накарда бошед, барои ин кор ",
  "KRIPTA.Settings.Help.ServerLink": "ба ин пайванд",
  "KRIPTA.Settings.Help.AfterServerLink": " гузаред. Барои танзими зуд аз ",
  "KRIPTA.Settings.Help.DocumentationLink": "ҳуҷҷатҳо",
  "KRIPTA.Settings.Help.AfterDocumentationLink": " истифода баред.",
  "KRIPTA.Window.Catalog": "Каталоги кортҳо",
  "KRIPTA.Window.CardDetails": "Корти каталог",
  "KRIPTA.Window.GiveCard": "Додани корт",
  "KRIPTA.Window.MyCards": "Кортҳои бозигар",
  "KRIPTA.Window.Players": "Идоракунии бозигарон",
  "KRIPTA.Window.Registry": "Феҳристи бозигарон",
  "KRIPTA.Window.RequestCard": "Гирифтани корт",
  "KRIPTA.Window.Settings": "Кортҳои Крипта - Танзимот",
  "KRIPTA.Window.UseCard": "Истифодаи корт",
  "KRIPTA.Menu.Title": "Кортҳои Крипта",
  "KRIPTA.Menu.Catalog": "Каталоги кортҳо",
  "KRIPTA.Menu.GetCard": "Гирифтани корт",
  "KRIPTA.Menu.MyCards": "Кортҳои ман",
  "KRIPTA.Menu.Players": "Идоракунии бозигарон",
  "KRIPTA.Label.Category": "Категория",
  "KRIPTA.Label.Mode": "Режим",
  "KRIPTA.Label.Card": "Корт",
  "KRIPTA.Label.Player": "Бозигар",
  "KRIPTA.Label.Name": "Ном",
  "KRIPTA.Label.Comment": "Шарҳ",
  "KRIPTA.Label.CardTypes": "Намудҳои корт",
  "KRIPTA.Label.Count": "Шумора",
  "KRIPTA.Label.ConfirmationCode": "Рамзи тасдиқ",
  "KRIPTA.Label.Id": "Муайянкунанда",
  "KRIPTA.Label.Key": "Калид",
  "KRIPTA.Label.ServerUrl": "Роҳ ба сервер",
  "KRIPTA.Label.Writer": "Нависанда (Writer)",
  "KRIPTA.Label.Reader": "Хонанда (Reader)",
  "KRIPTA.Label.Role": "Нақш",
  "KRIPTA.Label.Binding": "Пайваст",
  "KRIPTA.Role.GM": "Устод",
  "KRIPTA.Role.Player": "Бозигар",
  "KRIPTA.Status.InGame": "дар бозӣ",
  "KRIPTA.Status.Offline": "берун аз бозӣ",
  "KRIPTA.Binding.CardsIssued": "кортҳои додашуда:",
  "KRIPTA.Binding.NoCards": "корт нест",
  "KRIPTA.Binding.NotBound": "бозигар пайваст нашудааст, бозигарро интихоб кунед.",
  "KRIPTA.Binding.CardsCountHint": "Шумораи намудҳои кортҳои додашуда (такрорҳоро ҳисоб намекунад)",
  "KRIPTA.Button.Add": "Илова кардан",
  "KRIPTA.Button.Bind": "Пайваст кардан",
  "KRIPTA.Button.Cancel": "Бекор кардан",
  "KRIPTA.Button.Close": "Пӯшидан",
  "KRIPTA.Button.Confirm": "Тасдиқ кардан",
  "KRIPTA.Button.Delete": "Нест кардан",
  "KRIPTA.Button.Edit": "Тағйир додан",
  "KRIPTA.Button.Give": "Додан",
  "KRIPTA.Button.GiveCard": "Додани корт",
  "KRIPTA.Button.Info": "Маълумот",
  "KRIPTA.Button.No": "Не",
  "KRIPTA.Button.Output": "Баровардан",
  "KRIPTA.Button.Refresh": "Навсозӣ",
  "KRIPTA.Button.Registry": "Феҳристи бозигарон",
  "KRIPTA.Button.Request": "Дархост кардан",
  "KRIPTA.Button.RequestCard": "Гирифтан",
  "KRIPTA.Button.SaveChanges": "Нигоҳ доштани тағйирот",
  "KRIPTA.Button.Take": "Гирифта партофтан",
  "KRIPTA.Button.TestAuth": "Санҷидани корбарони техникӣ",
  "KRIPTA.Button.TestServer": "Санҷидани сервер",
  "KRIPTA.Button.Unbind": "Ҷудо кардан",
  "KRIPTA.Button.Use": "Истифода бурдан",
  "KRIPTA.Button.Yes": "Ҳа",
  "KRIPTA.Mode.Manual": "Бо интихоб",
  "KRIPTA.Mode.Random": "Тасодуфӣ",
  "KRIPTA.Mode.Show": "Нишон додан",
  "KRIPTA.Mode.Spend": "Сарф кардан",
  "KRIPTA.View.Table": "Ҷадвал",
  "KRIPTA.View.Tiles": "Плиткаҳо",
  "KRIPTA.Placeholder.Search": "Ҷустуҷӯ",
  "KRIPTA.Select.NotSelected": "-- интихоб нашудааст --",
  "KRIPTA.Template.EmptyCatalog": "Дар сервер категорияҳо ё кортҳои сабтшуда вуҷуд надоранд.",
  "KRIPTA.Template.MyCardsTitle": "Кортҳои бозигар: {playerName}",
  "KRIPTA.Template.UseCardMissing": "Ин корт дигар дар сервер сабт нашудааст.",
  "KRIPTA.Template.UseCardPrompt": "Корти зерин истифода мешавад:",
  "KRIPTA.Card.FallbackName": "Корт {number}",
  "KRIPTA.Card.FallbackAddress": "Корт {level}/{number}",
  "KRIPTA.Card.MissingDescription": "Корти {level}/{number} дар каталоги ҷории сервер вуҷуд надорад.",
  "KRIPTA.Card.NotRegisteredDescription": "Корти {level}/{number} дигар дар сервер сабт нашудааст.",
  "KRIPTA.Level.FallbackName": "Сатҳ {level}",
  "KRIPTA.Level.MissingDescription": "Сатҳ дар инвентари бозигар вуҷуд дорад, аммо дар каталоги ҷории сервер нест.",
  "KRIPTA.Chat.BlobReadFailed": "Хондани BLOB муяссар нашуд",
  "KRIPTA.Chat.CardGivenTitle": "Корт дода шуд",
  "KRIPTA.Chat.CardReceiveSubtitle": "Бозигар {playerName} корти {cardSubtitle}-ро мегирад",
  "KRIPTA.Chat.CardRequestCanceled": "Дархости корт бекор карда шуд.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "Дархости корт тасдиқ шуд",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "Хондани маълумоти дархост муяссар нашуд.",
  "KRIPTA.Chat.CardSpentFooter": "КОРТ САРФ ШУД",
  "KRIPTA.Chat.CardSpentTitle": "Корт сарф шуд",
  "KRIPTA.Chat.FallbackPlayer": "бозигар",
  "KRIPTA.Chat.ManualChoiceFooter": "ИНТИХОБИ ДАСТӢ",
  "KRIPTA.Chat.ReferenceTitle": "Маълумотнома",
  "KRIPTA.Chat.RequestManualTitle": "Дархости корти интихобшуда",
  "KRIPTA.Chat.RequestRandomTitle": "Дархости корти тасодуфӣ",
  "KRIPTA.Chat.ShowCardTitle": "Маълумотномаи корт",
  "KRIPTA.Dialog.BindPlayer.Title": "Пайваст кардани бозигари сервер",
  "KRIPTA.Dialog.BindPlayer.Header": "Интихоби бозигар барои {foundryUserName}",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "корбари Foundry",
  "KRIPTA.Dialog.Player.AddTitle": "Илова кардани бозигар",
  "KRIPTA.Dialog.Player.EditTitle": "Тағйир додани бозигар",
  "KRIPTA.Dialog.Player.DeleteTitle": "Нест кардани бозигар",
  "KRIPTA.Dialog.Player.DeleteWarning": "Нест кардани бозигари \"{playerName}\" бебозгашт аст. \"{code}\"-ро ворид кунед ва несткуниро тасдиқ намоед.",
  "KRIPTA.Dialog.Count.TotalCards": "ҳамагӣ кортҳои ин намуд - {max}",
  "KRIPTA.Error.InvalidCardLevel": "level нодуруст барои {context}: {level}",
  "KRIPTA.Error.InvalidCardNumber": "number нодуруст барои {context}: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "level-и корт нодуруст аст: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "number-и корт нодуруст аст: {number}",
  "KRIPTA.Error.InvalidRequestCard": "Корт барои дархост нодуруст аст",
  "KRIPTA.Error.InvalidGiveCard": "Корт барои додан нодуруст аст",
  "KRIPTA.Error.MissingRequestPlayerGuid": "Муайян кардани playerGuid барои додани корт муяссар нашуд.",
  "KRIPTA.Error.MissingSelectedCard": "Муайян кардани корти интихобшуда муяссар нашуд.",
  "KRIPTA.Error.MissingSelectedCardForGive": "Муайян кардани корти интихобшуда барои додан муяссар нашуд.",
  "KRIPTA.Error.MissingGivePlayer": "Муайян кардани бозигар барои додани корт муяссар нашуд.",
  "KRIPTA.Error.MissingGiveCard": "Муайян кардани корт барои додан муяссар нашуд.",
  "KRIPTA.Error.MissingServerUrl": "Танзими роҳ ба сервер вуҷуд надорад.",
  "KRIPTA.Error.InvalidReader": "Корбари техникии Reader нодуруст танзим шудааст.",
  "KRIPTA.Error.InvalidWriter": "Корбари техникии Writer нодуруст танзим шудааст.",
  "KRIPTA.Error.MenuUnavailable": "Функсия кор намекунад. Танзимоти модулро санҷед. Тафсилот дар консоли браузер.",
  "KRIPTA.Error.Generic": "Хато рух дод",
  "KRIPTA.Error.Unknown": "хатои номаълум",
  "KRIPTA.Error.NameRequired": "Майдони ном ҳатмист.",
  "KRIPTA.Error.RegistryDeleteReturned": "сервер пас аз несткунӣ бозигарро ба феҳрист баргардонд.",
  "KRIPTA.Notification.CardGiven": "Корт дода шуд.",
  "KRIPTA.Notification.CardUsed": "Корт истифода ва аз ҳисоб бароварда шуд.",
  "KRIPTA.Notification.CardWrittenOff": "Корт аз ҳисоб бароварда шуд.",
  "KRIPTA.Notification.CannotUseMissingCard": "Ин корт дигар дар сервер сабт нашудааст. Истифода дастрас нест.",
  "KRIPTA.Notification.MissingCard": "Ин корт дигар дар сервер сабт нашудааст.",
  "KRIPTA.Notification.PlayerNotSelected": "Бозигар барои додани корт интихоб нашудааст",
  "KRIPTA.Notification.PlayerBindingMissing": "Муайян кардани пайвасти бозигар барои додани корт муяссар нашуд",
  "KRIPTA.Notification.RequestSent": "Дархости корт ба чат фиристода шуд.",
  "KRIPTA.Notification.ServerSuccess": "Пайвастшавӣ бомуваффақият аст.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "Пайвастшавӣ бомуваффақият аст. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "Пайваст шудан ба сервер муяссар нашуд. Нишонӣ, дастрасии сервер ва танзимоти CORS/HTTPS-ро санҷед.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "Санҷидани сервер муяссар нашуд.",
  "KRIPTA.Notification.InvalidServerUrl": "Нишонии сервер нодуруст аст: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "Бахши танзимоти «Кортҳои Крипта» танҳо барои нақшҳои «Устод» ва «Ёвари устод» дастрас аст.",
  "KRIPTA.Notification.ServerCheckFailed": "Санҷиши сервер ноком шуд",
  "KRIPTA.Notification.TechUserReader": "Хонанда",
  "KRIPTA.Notification.TechUserWriter": "Нависанда",
  "KRIPTA.Notification.TechUsersCheckSuccess": "Корбарони техникии \"Reader\" ва \"Writer\" санҷишро бомуваффақият мегузаранд.",
  "KRIPTA.Notification.SettingsSaved": "Танзимоти пайвастшавӣ нигоҳ дошта шуд.",
  "KRIPTA.Notification.PlayerAdded": "Бозигар илова шуд.",
  "KRIPTA.Notification.PlayerUpdated": "Бозигар навсозӣ шуд.",
  "KRIPTA.Notification.PlayerDeleted": "Бозигар нест карда шуд.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "Несткунӣ бекор шуд. Майдони назоратӣ нодуруст пур шудааст.",
  "KRIPTA.Notification.BindingSaved": "Пайваст нигоҳ дошта шуд.",
  "KRIPTA.Notification.BindingDeleted": "Пайваст нест карда шуд.",
  "KRIPTA.Notification.BadCatalogCardNumber": "Рақами корти интихобшуда нодуруст аст. Ҷавоби getCardsList ва normalizeCardsList-ро санҷед.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "Ин кортро дастӣ додан мумкин нест: рақами он нодуруст аст. Ҷавоби getCardsList ва normalizeCardsList-ро санҷед.",
  "KRIPTA.Notification.CardOutputFailed": "Баровардани корт ба чат муяссар нашуд",
  "KRIPTA.Notification.CardGiveFailed": "Додани корт муяссар нашуд",
  "KRIPTA.Notification.CardUseFailed": "Истифодаи корт муяссар нашуд",
  "KRIPTA.Notification.CardTakeFailed": "Аз ҳисоб баровардани корт муяссар нашуд",
  "KRIPTA.Notification.CardRequestFailed": "Фиристодани дархости корт муяссар нашуд",
  "KRIPTA.Notification.CardRequestConfirmFailed": "Тасдиқи додани корт муяссар нашуд",
  "KRIPTA.Notification.PlayerAddFailed": "Илова кардани бозигар муяссар нашуд",
  "KRIPTA.Notification.PlayerUpdateFailed": "Навсозии бозигар муяссар нашуд",
  "KRIPTA.Notification.PlayerDeleteFailed": "Нест кардани бозигар муяссар нашуд",
  "KRIPTA.Notification.CardRollFailed": "Гирифтани корт муяссар нашуд.",
  "KRIPTA.Dialog.TakeCard.Title": "Гирифта партофтани корт",
  "KRIPTA.Dialog.TakeCard.Message": "Бозигар {playerName} аз корти {cardName} маҳрум мешавад.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Додани корт"
}
__END_LOCALE_JSON__
