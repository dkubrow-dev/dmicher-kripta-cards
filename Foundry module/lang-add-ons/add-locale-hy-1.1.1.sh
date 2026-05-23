#!/usr/bin/env sh
set -eu

if [ ! -f "dmicher-kripta-cards/module.json" ]; then
  echo "Run this script from the Foundry module workspace root, next to dmicher-kripta-cards/module.json." >&2
  exit 1
fi

SCRIPT_FILE="$0"
LOCALE_PATH="dmicher-kripta-cards/lang/hy.json"
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
  "lang": "hy",
  "name": "Հայերեն",
  "path": "lang/hy.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "Ձեր Foundry մասնակիցը կապված չէ Կրիպտայի քարտերի մոդուլի սերվերի խաղացողի հետ։ Դիմեք խաղավարին։",
  "KRIPTA.GMOnly": "Այս գործողությունը հասանելի է միայն խաղավարին։",
  "KRIPTA.Settings.ServerUrl.Name": "Սերվերի հասցե",
  "KRIPTA.Settings.TechAuthUsers.Name": "Տեխնիկական օգտատերեր",
  "KRIPTA.Settings.PlayerBindings.Name": "Foundry մասնակիցների կապերը սերվերի խաղացողների հետ",
  "KRIPTA.Settings.UiPrefs.Name": "Տեղային միջերեսի կարգավորումներ",
  "KRIPTA.Settings.Menu.Name": "Կրիպտայի քարտեր",
  "KRIPTA.Settings.Menu.Label": "Մոդուլի կարգավորում",
  "KRIPTA.Settings.Menu.Hint": "API-ի միացում և տեխնիկական օգտատերեր։",
  "KRIPTA.Settings.Help.BeforeServerLink": "Եթե դեռ չեք տեղադրել և կարգավորել մոդուլի բովանդակության սերվերը, անցեք ",
  "KRIPTA.Settings.Help.ServerLink": "այս հղումով",
  "KRIPTA.Settings.Help.AfterServerLink": "՝ դա անելու համար։ Արագ կարգավորման համար օգտագործեք ",
  "KRIPTA.Settings.Help.DocumentationLink": "փաստաթղթերը",
  "KRIPTA.Settings.Help.AfterDocumentationLink": "։",
  "KRIPTA.Window.Catalog": "Քարտերի կատալոգ",
  "KRIPTA.Window.CardDetails": "Կատալոգի քարտ",
  "KRIPTA.Window.GiveCard": "Տալ քարտ",
  "KRIPTA.Window.MyCards": "Խաղացողի քարտեր",
  "KRIPTA.Window.Players": "Խաղացողների կառավարում",
  "KRIPTA.Window.Registry": "Խաղացողների ռեեստր",
  "KRIPTA.Window.RequestCard": "Ստանալ քարտ",
  "KRIPTA.Window.Settings": "Կրիպտայի քարտեր - Կարգավորումներ",
  "KRIPTA.Window.UseCard": "Օգտագործել քարտը",
  "KRIPTA.Menu.Title": "Կրիպտայի քարտեր",
  "KRIPTA.Menu.Catalog": "Քարտերի կատալոգ",
  "KRIPTA.Menu.GetCard": "Ստանալ քարտ",
  "KRIPTA.Menu.MyCards": "Իմ քարտերը",
  "KRIPTA.Menu.Players": "Խաղացողների կառավարում",
  "KRIPTA.Label.Category": "Կատեգորիա",
  "KRIPTA.Label.Mode": "Ռեժիմ",
  "KRIPTA.Label.Card": "Քարտ",
  "KRIPTA.Label.Player": "Խաղացող",
  "KRIPTA.Label.Name": "Անուն",
  "KRIPTA.Label.Comment": "Մեկնաբանություն",
  "KRIPTA.Label.CardTypes": "Քարտերի տեսակներ",
  "KRIPTA.Label.Count": "Քանակ",
  "KRIPTA.Label.ConfirmationCode": "Հաստատման կոդ",
  "KRIPTA.Label.Id": "Նույնացուցիչ",
  "KRIPTA.Label.Key": "Բանալի",
  "KRIPTA.Label.ServerUrl": "Սերվերի ուղի",
  "KRIPTA.Label.Writer": "Գրող (Writer)",
  "KRIPTA.Label.Reader": "Ընթերցող (Reader)",
  "KRIPTA.Label.Role": "Դեր",
  "KRIPTA.Label.Binding": "Կապ",
  "KRIPTA.Role.GM": "Խաղավար",
  "KRIPTA.Role.Player": "Խաղացող",
  "KRIPTA.Status.InGame": "խաղում է",
  "KRIPTA.Status.Offline": "անցանց",
  "KRIPTA.Binding.CardsIssued": "տրված քարտեր՝",
  "KRIPTA.Binding.NoCards": "քարտեր չկան",
  "KRIPTA.Binding.NotBound": "խաղացողը կապված չէ, ընտրեք խաղացող։",
  "KRIPTA.Binding.CardsCountHint": "Տրված քարտերի տեսակների քանակը (կրկնվողները հաշվի չեն առնվում)",
  "KRIPTA.Button.Add": "Ավելացնել",
  "KRIPTA.Button.Bind": "Կապել",
  "KRIPTA.Button.Cancel": "Չեղարկել",
  "KRIPTA.Button.Close": "Փակել",
  "KRIPTA.Button.Confirm": "Հաստատել",
  "KRIPTA.Button.Delete": "Ջնջել",
  "KRIPTA.Button.Edit": "Փոփոխել",
  "KRIPTA.Button.Give": "Տալ",
  "KRIPTA.Button.GiveCard": "Տալ քարտ",
  "KRIPTA.Button.Info": "Տեղեկություն",
  "KRIPTA.Button.No": "Ոչ",
  "KRIPTA.Button.Output": "Ցուցադրել",
  "KRIPTA.Button.Refresh": "Թարմացնել",
  "KRIPTA.Button.Registry": "Խաղացողների ռեեստր",
  "KRIPTA.Button.Request": "Հարցում ուղարկել",
  "KRIPTA.Button.RequestCard": "Ստանալ",
  "KRIPTA.Button.SaveChanges": "Պահպանել փոփոխությունները",
  "KRIPTA.Button.Take": "Վերցնել",
  "KRIPTA.Button.TestAuth": "Ստուգել տեխնիկական օգտատերերին",
  "KRIPTA.Button.TestServer": "Ստուգել սերվերը",
  "KRIPTA.Button.Unbind": "Անջատել կապը",
  "KRIPTA.Button.Use": "Օգտագործել",
  "KRIPTA.Button.Yes": "Այո",
  "KRIPTA.Mode.Manual": "Ընտրությամբ",
  "KRIPTA.Mode.Random": "Պատահական",
  "KRIPTA.Mode.Show": "Ցույց տալ",
  "KRIPTA.Mode.Spend": "Ծախսել",
  "KRIPTA.View.Table": "Աղյուսակ",
  "KRIPTA.View.Tiles": "Սալիկներ",
  "KRIPTA.Placeholder.Search": "Որոնում",
  "KRIPTA.Select.NotSelected": "-- ընտրված չէ --",
  "KRIPTA.Template.EmptyCatalog": "Սերվերում գրանցված կատեգորիաներ կամ քարտեր չկան։",
  "KRIPTA.Template.MyCardsTitle": "Խաղացողի քարտեր՝ {playerName}",
  "KRIPTA.Template.UseCardMissing": "Այս քարտը այլևս գրանցված չէ սերվերում։",
  "KRIPTA.Template.UseCardPrompt": "Կօգտագործվի քարտը՝",
  "KRIPTA.Card.FallbackName": "Քարտ {number}",
  "KRIPTA.Card.FallbackAddress": "Քարտ {level}/{number}",
  "KRIPTA.Card.MissingDescription": "Քարտը {level}/{number} բացակայում է սերվերի ընթացիկ կատալոգում։",
  "KRIPTA.Card.NotRegisteredDescription": "Քարտը {level}/{number} այլևս գրանցված չէ սերվերում։",
  "KRIPTA.Level.FallbackName": "Մակարդակ {level}",
  "KRIPTA.Level.MissingDescription": "Մակարդակը կա խաղացողի գույքագրում, բայց բացակայում է սերվերի ընթացիկ կատալոգում։",
  "KRIPTA.Chat.BlobReadFailed": "Չհաջողվեց կարդալ BLOB-ը",
  "KRIPTA.Chat.CardGivenTitle": "Քարտը տրված է",
  "KRIPTA.Chat.CardReceiveSubtitle": "Խաղացող {playerName}-ը ստանում է {cardSubtitle} քարտը",
  "KRIPTA.Chat.CardRequestCanceled": "Քարտի հարցումը չեղարկվել է։",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "Քարտի հարցումը հաստատվել է",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "Չհաջողվեց կարդալ հարցման տվյալները։",
  "KRIPTA.Chat.CardSpentFooter": "ՔԱՐՏԸ ԾԱԽՍՎԱԾ Է",
  "KRIPTA.Chat.CardSpentTitle": "Քարտը ծախսված է",
  "KRIPTA.Chat.FallbackPlayer": "խաղացող",
  "KRIPTA.Chat.ManualChoiceFooter": "ՁԵՌՔՈՎ ԸՆՏՐՈՒԹՅՈՒՆ",
  "KRIPTA.Chat.ReferenceTitle": "Տեղեկանք",
  "KRIPTA.Chat.RequestManualTitle": "Ընտրված քարտի հարցում",
  "KRIPTA.Chat.RequestRandomTitle": "Պատահական քարտի հարցում",
  "KRIPTA.Chat.ShowCardTitle": "Քարտի տեղեկանք",
  "KRIPTA.Dialog.BindPlayer.Title": "Կապել սերվերի խաղացողին",
  "KRIPTA.Dialog.BindPlayer.Header": "Ընտրել խաղացող {foundryUserName}-ի համար",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "Foundry օգտատեր",
  "KRIPTA.Dialog.Player.AddTitle": "Ավելացնել խաղացող",
  "KRIPTA.Dialog.Player.EditTitle": "Փոփոխել խաղացողին",
  "KRIPTA.Dialog.Player.DeleteTitle": "Ջնջել խաղացողին",
  "KRIPTA.Dialog.Player.DeleteWarning": "\"{playerName}\" խաղացողի ջնջումը անշրջելի է։ Մուտքագրեք \"{code}\" և հաստատեք ջնջումը։",
  "KRIPTA.Dialog.Count.TotalCards": "այս տեսակի քարտերի ընդհանուր քանակը՝ {max}",
  "KRIPTA.Error.InvalidCardLevel": "{context}-ի համար սխալ level՝ {level}",
  "KRIPTA.Error.InvalidCardNumber": "{context}-ի համար սխալ number՝ {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "քարտի սխալ level՝ {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "քարտի սխալ number՝ {number}",
  "KRIPTA.Error.InvalidRequestCard": "Հարցման համար սխալ քարտ",
  "KRIPTA.Error.InvalidGiveCard": "Տալու համար սխալ քարտ",
  "KRIPTA.Error.MissingRequestPlayerGuid": "Չհաջողվեց որոշել playerGuid-ը քարտ տալու համար։",
  "KRIPTA.Error.MissingSelectedCard": "Չհաջողվեց որոշել ընտրված քարտը։",
  "KRIPTA.Error.MissingSelectedCardForGive": "Չհաջողվեց որոշել ընտրված քարտը տալու համար։",
  "KRIPTA.Error.MissingGivePlayer": "Չհաջողվեց որոշել խաղացողին քարտ տալու համար։",
  "KRIPTA.Error.MissingGiveCard": "Չհաջողվեց որոշել քարտը տալու համար։",
  "KRIPTA.Error.MissingServerUrl": "Սերվերի ուղու կարգավորումը բացակայում է։",
  "KRIPTA.Error.InvalidReader": "Reader տեխնիկական օգտատերը սխալ է կարգավորված։",
  "KRIPTA.Error.InvalidWriter": "Writer տեխնիկական օգտատերը սխալ է կարգավորված։",
  "KRIPTA.Error.MenuUnavailable": "Գործառույթը չի աշխատում։ Ստուգեք մոդուլի կարգավորումները։ Մանրամասները՝ դիտարկիչի վահանակում։",
  "KRIPTA.Error.Generic": "Սխալ է տեղի ունեցել",
  "KRIPTA.Error.Unknown": "անհայտ սխալ",
  "KRIPTA.Error.NameRequired": "Անվան դաշտը պարտադիր է։",
  "KRIPTA.Error.RegistryDeleteReturned": "սերվերը ջնջումից հետո խաղացողին վերադարձրեց ռեեստրում։",
  "KRIPTA.Notification.CardGiven": "Քարտը տրված է։",
  "KRIPTA.Notification.CardUsed": "Քարտը օգտագործվել և դուրս է գրվել։",
  "KRIPTA.Notification.CardWrittenOff": "Քարտը դուրս է գրվել։",
  "KRIPTA.Notification.CannotUseMissingCard": "Այս քարտը այլևս գրանցված չէ սերվերում։ Օգտագործումը հասանելի չէ։",
  "KRIPTA.Notification.MissingCard": "Այս քարտը այլևս գրանցված չէ սերվերում։",
  "KRIPTA.Notification.PlayerNotSelected": "Քարտ տալու համար խաղացող ընտրված չէ",
  "KRIPTA.Notification.PlayerBindingMissing": "Չհաջողվեց որոշել խաղացողի կապը քարտ տալու համար",
  "KRIPTA.Notification.RequestSent": "Քարտի հարցումը ուղարկվել է չատ։",
  "KRIPTA.Notification.ServerSuccess": "Միացումը հաջող է։",
  "KRIPTA.Notification.ServerSuccessWithDetails": "Միացումը հաջող է։ {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "Չհաջողվեց միանալ սերվերին։ Ստուգեք հասցեն, սերվերի հասանելիությունը և CORS/HTTPS կարգավորումները։",
  "KRIPTA.Notification.ServerCheckFailedFallback": "Չհաջողվեց ստուգել սերվերը։",
  "KRIPTA.Notification.InvalidServerUrl": "Սերվերի սխալ հասցե՝ {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "«Կրիպտայի քարտեր» կարգավորումների բաժինը հասանելի է միայն «Վարող» և «Վարողի օգնական» դերերին։",
  "KRIPTA.Notification.ServerCheckFailed": "Սերվերի ստուգումը ձախողվեց",
  "KRIPTA.Notification.TechUserReader": "Ընթերցող",
  "KRIPTA.Notification.TechUserWriter": "Գրող",
  "KRIPTA.Notification.TechUsersCheckSuccess": "\"Reader\" և \"Writer\" տեխնիկական օգտատերերը հաջողությամբ անցնում են ստուգումը։",
  "KRIPTA.Notification.SettingsSaved": "Միացման կարգավորումները պահպանվել են։",
  "KRIPTA.Notification.PlayerAdded": "Խաղացողը ավելացվել է։",
  "KRIPTA.Notification.PlayerUpdated": "Խաղացողը թարմացվել է։",
  "KRIPTA.Notification.PlayerDeleted": "Խաղացողը ջնջվել է։",
  "KRIPTA.Notification.DeleteCanceledBadCode": "Ջնջումը չեղարկվել է։ Ստուգիչ դաշտը սխալ է լրացված։",
  "KRIPTA.Notification.BindingSaved": "Կապը պահպանվել է։",
  "KRIPTA.Notification.BindingDeleted": "Կապը ջնջվել է։",
  "KRIPTA.Notification.BadCatalogCardNumber": "Ընտրված քարտի համարը սխալ է։ Ստուգեք getCardsList-ի պատասխանը և normalizeCardsList-ը։",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "Այս քարտը հնարավոր չէ ձեռքով տալ․ այն ունի սխալ համար։ Ստուգեք getCardsList-ի պատասխանը և normalizeCardsList-ը։",
  "KRIPTA.Notification.CardOutputFailed": "Չհաջողվեց քարտը դուրս բերել չատ",
  "KRIPTA.Notification.CardGiveFailed": "Չհաջողվեց տալ քարտը",
  "KRIPTA.Notification.CardUseFailed": "Չհաջողվեց օգտագործել քարտը",
  "KRIPTA.Notification.CardTakeFailed": "Չհաջողվեց դուրս գրել քարտը",
  "KRIPTA.Notification.CardRequestFailed": "Չհաջողվեց ուղարկել քարտի հարցումը",
  "KRIPTA.Notification.CardRequestConfirmFailed": "Չհաջողվեց հաստատել քարտի տրամադրումը",
  "KRIPTA.Notification.PlayerAddFailed": "Չհաջողվեց ավելացնել խաղացողին",
  "KRIPTA.Notification.PlayerUpdateFailed": "Չհաջողվեց թարմացնել խաղացողին",
  "KRIPTA.Notification.PlayerDeleteFailed": "Չհաջողվեց ջնջել խաղացողին",
  "KRIPTA.Notification.CardRollFailed": "Չհաջողվեց ստանալ քարտը։",
  "KRIPTA.Dialog.TakeCard.Title": "Վերցնել քարտը",
  "KRIPTA.Dialog.TakeCard.Message": "Խաղացող {playerName}-ը կզրկվի {cardName} քարտից։",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Տալ քարտ"
}
__END_LOCALE_JSON__
