#!/usr/bin/env sh
set -eu

if [ ! -f "dmicher-kripta-cards/module.json" ]; then
  echo "Run this script from the Foundry module workspace root, next to dmicher-kripta-cards/module.json." >&2
  exit 1
fi

SCRIPT_FILE="$0"
LOCALE_PATH="dmicher-kripta-cards/lang/av.json"
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
  "lang": "av",
  "name": "МагӀарул мацӀ",
  "path": "lang/av.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "Дуда Foundry участник Криптая карталъул модулалда сервериялъул игрокасде цӀунизе гьечӀо. ХӀалмагъалъул мастерде гьари.",
  "KRIPTA.GMOnly": "Гьаб хӀалтӀи хӀалмагъалъул мастердасанго ккола.",
  "KRIPTA.Settings.ServerUrl.Name": "Сервериялъул адрес",
  "KRIPTA.Settings.TechAuthUsers.Name": "Техникиялъул пайдаланавиял",
  "KRIPTA.Settings.PlayerBindings.Name": "Foundry участникал сервериялъул игрокалде цӀуни",
  "KRIPTA.Settings.UiPrefs.Name": "Интерфейсалъул махӀалиялъул настройкаял",
  "KRIPTA.Settings.Menu.Name": "Криптая картал",
  "KRIPTA.Settings.Menu.Label": "Модулалъул настройка",
  "KRIPTA.Settings.Menu.Hint": "API-де цӀуни ва техникиялъул пайдаланавиял.",
  "KRIPTA.Settings.Help.BeforeServerLink": "Модулалъул контенталъул сервер гьанже биччачӀого ва гӀуцӀичӀого бугони, гьеб гьабизе ",
  "KRIPTA.Settings.Help.ServerLink": "гьаб ссылка",
  "KRIPTA.Settings.Help.AfterServerLink": " бихьизабе. Хадуб кӀвараб гӀуцӀизе ",
  "KRIPTA.Settings.Help.DocumentationLink": "документация",
  "KRIPTA.Settings.Help.AfterDocumentationLink": " пайда босе.",
  "KRIPTA.Window.Catalog": "Карталъул каталог",
  "KRIPTA.Window.CardDetails": "Каталогалъул карта",
  "KRIPTA.Window.GiveCard": "Карта кьезе",
  "KRIPTA.Window.MyCards": "Игрокасул картал",
  "KRIPTA.Window.Players": "Игрокалгун хӀалтӀи",
  "KRIPTA.Window.Registry": "Игрокалъул реестр",
  "KRIPTA.Window.RequestCard": "Карта босизе",
  "KRIPTA.Window.Settings": "Криптая картал - Настройкаял",
  "KRIPTA.Window.UseCard": "Карта пайда босизе",
  "KRIPTA.Menu.Title": "Криптая картал",
  "KRIPTA.Menu.Catalog": "Карталъул каталог",
  "KRIPTA.Menu.GetCard": "Карта босизе",
  "KRIPTA.Menu.MyCards": "Дир картал",
  "KRIPTA.Menu.Players": "Игрокалгун хӀалтӀи",
  "KRIPTA.Label.Category": "Категория",
  "KRIPTA.Label.Mode": "Режим",
  "KRIPTA.Label.Card": "Карта",
  "KRIPTA.Label.Player": "Игрок",
  "KRIPTA.Label.Name": "ЦӀар",
  "KRIPTA.Label.Comment": "Комментарий",
  "KRIPTA.Label.CardTypes": "Карталъул тайпаби",
  "KRIPTA.Label.Count": "Къадар",
  "KRIPTA.Label.ConfirmationCode": "Тасдикъалъул код",
  "KRIPTA.Label.Id": "Идентификатор",
  "KRIPTA.Label.Key": "Ключ",
  "KRIPTA.Label.ServerUrl": "Сервериялъухъе нух",
  "KRIPTA.Label.Writer": "Хъвадарухъан (Writer)",
  "KRIPTA.Label.Reader": "ЦӀалдарухъан (Reader)",
  "KRIPTA.Label.Role": "Роль",
  "KRIPTA.Label.Binding": "ЦӀуни",
  "KRIPTA.Role.GM": "Мастер",
  "KRIPTA.Role.Player": "Игрок",
  "KRIPTA.Status.InGame": "хӀалмагъалъулъ",
  "KRIPTA.Status.Offline": "хӀалмагъалъулъ гьечӀо",
  "KRIPTA.Binding.CardsIssued": "кьурал картал:",
  "KRIPTA.Binding.NoCards": "картал гьечӀо",
  "KRIPTA.Binding.NotBound": "игрок цӀунизе гьечӀо, игрок вищ.",
  "KRIPTA.Binding.CardsCountHint": "Кьурал карталъул тайпабазул къадар (такрарлъи хӀисабизе гьечӀо)",
  "KRIPTA.Button.Add": "ТӀаде жубазе",
  "KRIPTA.Button.Bind": "ЦӀунизе",
  "KRIPTA.Button.Cancel": "Бекаризе",
  "KRIPTA.Button.Close": "Къанлъизе",
  "KRIPTA.Button.Confirm": "Тасдикъизе",
  "KRIPTA.Button.Delete": "Батизе",
  "KRIPTA.Button.Edit": "Хисизе",
  "KRIPTA.Button.Give": "Кьезе",
  "KRIPTA.Button.GiveCard": "Карта кьезе",
  "KRIPTA.Button.Info": "Маълумат",
  "KRIPTA.Button.No": "ГьечӀо",
  "KRIPTA.Button.Output": "Бихьизабизе",
  "KRIPTA.Button.Refresh": "ЦӀиябизе",
  "KRIPTA.Button.Registry": "Игрокалъул реестр",
  "KRIPTA.Button.Request": "Талаб гьабизе",
  "KRIPTA.Button.RequestCard": "Босизе",
  "KRIPTA.Button.SaveChanges": "Хисиял цӀунизе",
  "KRIPTA.Button.Take": "Босизе",
  "KRIPTA.Button.TestAuth": "Техникиялъул пайдаланавиял хал гьаризе",
  "KRIPTA.Button.TestServer": "Сервер хал гьабизе",
  "KRIPTA.Button.Unbind": "ЦӀуни хъвахъизе",
  "KRIPTA.Button.Use": "Пайда босизе",
  "KRIPTA.Button.Yes": "Гьай",
  "KRIPTA.Mode.Manual": "Вищизе",
  "KRIPTA.Mode.Random": "Случайнияб",
  "KRIPTA.Mode.Show": "Бихьизабизе",
  "KRIPTA.Mode.Spend": "Сарф гьабизе",
  "KRIPTA.View.Table": "Таблица",
  "KRIPTA.View.Tiles": "Плиткаял",
  "KRIPTA.Placeholder.Search": "Лахъи",
  "KRIPTA.Select.NotSelected": "-- вищун гьечӀо --",
  "KRIPTA.Template.EmptyCatalog": "Сервериялда регистрация гьабура категориял я картал гьечӀо.",
  "KRIPTA.Template.MyCardsTitle": "Игрокасул картал: {playerName}",
  "KRIPTA.Template.UseCardMissing": "Гьаб карта сервериялда къваридал регистрация гьабура гьечӀо.",
  "KRIPTA.Template.UseCardPrompt": "Пайда босила карта:",
  "KRIPTA.Card.FallbackName": "Карта {number}",
  "KRIPTA.Card.FallbackAddress": "Карта {level}/{number}",
  "KRIPTA.Card.MissingDescription": "Карта {level}/{number} сервериялъул гьанжесеб каталогалда гьечӀо.",
  "KRIPTA.Card.NotRegisteredDescription": "Карта {level}/{number} сервериялда къваридал регистрация гьабура гьечӀо.",
  "KRIPTA.Level.FallbackName": "Даража {level}",
  "KRIPTA.Level.MissingDescription": "Даража игрокасул инвентаралда буго, амма сервериялъул гьанжесеб каталогалда гьечӀо.",
  "KRIPTA.Chat.BlobReadFailed": "BLOB цӀализе кколаро",
  "KRIPTA.Chat.CardGivenTitle": "Карта кьуна",
  "KRIPTA.Chat.CardReceiveSubtitle": "Игрок {playerName} {cardSubtitle} карта босула",
  "KRIPTA.Chat.CardRequestCanceled": "Карта талаб бекаризе гьабуна.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "Карта талаб тасдикъ гьабуна",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "Талабалъул маълумат цӀализе кколаро.",
  "KRIPTA.Chat.CardSpentFooter": "КАРТА САРФ ГЬАБУНА",
  "KRIPTA.Chat.CardSpentTitle": "Карта сарф гьабуна",
  "KRIPTA.Chat.FallbackPlayer": "игрок",
  "KRIPTA.Chat.ManualChoiceFooter": "КЪОБОН ВИЩИ",
  "KRIPTA.Chat.ReferenceTitle": "Кумек",
  "KRIPTA.Chat.RequestManualTitle": "Вищара карталъул талаб",
  "KRIPTA.Chat.RequestRandomTitle": "Случайнияб карталъул талаб",
  "KRIPTA.Chat.ShowCardTitle": "Картаялъул кумек",
  "KRIPTA.Dialog.BindPlayer.Title": "Сервериялъул игрок цӀунизе",
  "KRIPTA.Dialog.BindPlayer.Header": "{foundryUserName} учун игрок вищизе",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "Foundry пайдаланав",
  "KRIPTA.Dialog.Player.AddTitle": "Игрок тӀаде жубазе",
  "KRIPTA.Dialog.Player.EditTitle": "Игрок хисизе",
  "KRIPTA.Dialog.Player.DeleteTitle": "Игрок батизе",
  "KRIPTA.Dialog.Player.DeleteWarning": "\"{playerName}\" игрок батизе юха ккун гьечӀо. \"{code}\" хъвай ва батизе тасдикъ гьабе.",
  "KRIPTA.Dialog.Count.TotalCards": "гьаб тайпа картал жамагӀат - {max}",
  "KRIPTA.Error.InvalidCardLevel": "{context} учун level дурус гьечӀо: {level}",
  "KRIPTA.Error.InvalidCardNumber": "{context} учун number дурус гьечӀо: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "картаялъул level дурус гьечӀо: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "картаялъул number дурус гьечӀо: {number}",
  "KRIPTA.Error.InvalidRequestCard": "Талаб учун карта дурус гьечӀо",
  "KRIPTA.Error.InvalidGiveCard": "Кьезе карта дурус гьечӀо",
  "KRIPTA.Error.MissingRequestPlayerGuid": "Карта кьезе playerGuid бихьизабизе кколаро.",
  "KRIPTA.Error.MissingSelectedCard": "Вищара карта бихьизабизе кколаро.",
  "KRIPTA.Error.MissingSelectedCardForGive": "Кьезе вищара карта бихьизабизе кколаро.",
  "KRIPTA.Error.MissingGivePlayer": "Карта кьезе игрок бихьизабизе кколаро.",
  "KRIPTA.Error.MissingGiveCard": "Кьезе карта бихьизабизе кколаро.",
  "KRIPTA.Error.MissingServerUrl": "Сервериялъухъе нухалъул настройка гьечӀо.",
  "KRIPTA.Error.InvalidReader": "Reader техникиялъул пайдаланав дурус гьабун гьечӀо.",
  "KRIPTA.Error.InvalidWriter": "Writer техникиялъул пайдаланав дурус гьабун гьечӀо.",
  "KRIPTA.Error.MenuUnavailable": "Функция хӀалтӀулеб гьечӀо. Модулалъул настройкаял хал гьаре. Тафсилот браузериялъул консолалда.",
  "KRIPTA.Error.Generic": "ХатӀа ккана",
  "KRIPTA.Error.Unknown": "лъалареб хатӀа",
  "KRIPTA.Error.NameRequired": "ЦӀаралъул майдан тӀаде тӀамуна.",
  "KRIPTA.Error.RegistryDeleteReturned": "сервер батизе гьабулебалдаса хадуб игрок реестрде юха кьуна.",
  "KRIPTA.Notification.CardGiven": "Карта кьуна.",
  "KRIPTA.Notification.CardUsed": "Карта пайда босана ва учеталдаса батана.",
  "KRIPTA.Notification.CardWrittenOff": "Карта учеталдаса батана.",
  "KRIPTA.Notification.CannotUseMissingCard": "Гьаб карта сервериялда къваридал регистрация гьабура гьечӀо. Пайда босизе кколаро.",
  "KRIPTA.Notification.MissingCard": "Гьаб карта сервериялда къваридал регистрация гьабура гьечӀо.",
  "KRIPTA.Notification.PlayerNotSelected": "Карта кьезе игрок вищун гьечӀо",
  "KRIPTA.Notification.PlayerBindingMissing": "Карта кьезе игрокасул цӀуни бихьизабизе кколаро",
  "KRIPTA.Notification.RequestSent": "Карта талаб чатде рехун буго.",
  "KRIPTA.Notification.ServerSuccess": "ЦӀуни кколеб буго.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "ЦӀуни кколеб буго. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "Серверде цӀуни кколаро. Адрес, сервериялъул хӀалтӀи ва CORS/HTTPS настройкаял хал гьаре.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "Сервер хал гьабизе кколаро.",
  "KRIPTA.Notification.InvalidServerUrl": "Сервер адрес дурус гьечӀо: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "«Криптая картал» настройкаялъул раздел «Ведущий» ва «Ведущий помощник» ролалъулъего ккола.",
  "KRIPTA.Notification.ServerCheckFailed": "Сервер хал гьаби кколаро",
  "KRIPTA.Notification.TechUserReader": "ЦӀалдарухъан",
  "KRIPTA.Notification.TechUserWriter": "Хъвадарухъан",
  "KRIPTA.Notification.TechUsersCheckSuccess": "\"Reader\" ва \"Writer\" техникиялъул пайдаланавиял хал гьабиялдаса къваридал тӀолеб буго.",
  "KRIPTA.Notification.SettingsSaved": "ЦӀуниялъул настройкаял цӀунана.",
  "KRIPTA.Notification.PlayerAdded": "Игрок тӀаде жубана.",
  "KRIPTA.Notification.PlayerUpdated": "Игрок цӀиябана.",
  "KRIPTA.Notification.PlayerDeleted": "Игрок батана.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "Бати бекар гьабуна. Контроль майдан дурус цӀун гьечӀо.",
  "KRIPTA.Notification.BindingSaved": "ЦӀуни цӀунана.",
  "KRIPTA.Notification.BindingDeleted": "ЦӀуни батана.",
  "KRIPTA.Notification.BadCatalogCardNumber": "Вищара картаялъул номер дурус гьечӀо. getCardsList жаваб ва normalizeCardsList хал гьаре.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "Гьаб карта къоялда кьезе кколаро: цебесеб номер дурус гьечӀо. getCardsList жаваб ва normalizeCardsList хал гьаре.",
  "KRIPTA.Notification.CardOutputFailed": "Карта чаталда бихьизабизе кколаро",
  "KRIPTA.Notification.CardGiveFailed": "Карта кьезе кколаро",
  "KRIPTA.Notification.CardUseFailed": "Карта пайда босизе кколаро",
  "KRIPTA.Notification.CardTakeFailed": "Карта учеталдаса батизе кколаро",
  "KRIPTA.Notification.CardRequestFailed": "Карта талаб рехизе кколаро",
  "KRIPTA.Notification.CardRequestConfirmFailed": "Карта кьезе тасдикъ гьабизе кколаро",
  "KRIPTA.Notification.PlayerAddFailed": "Игрок тӀаде жубазе кколаро",
  "KRIPTA.Notification.PlayerUpdateFailed": "Игрок цӀиябизе кколаро",
  "KRIPTA.Notification.PlayerDeleteFailed": "Игрок батизе кколаро",
  "KRIPTA.Notification.CardRollFailed": "Карта босизе кколаро.",
  "KRIPTA.Dialog.TakeCard.Title": "Карта босизе",
  "KRIPTA.Dialog.TakeCard.Message": "Игрок {playerName} {cardName} картаялдаса махрум гьавила.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Карта кьезе"
}
__END_LOCALE_JSON__
