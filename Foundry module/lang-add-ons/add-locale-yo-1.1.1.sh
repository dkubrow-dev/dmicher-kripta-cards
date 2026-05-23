#!/usr/bin/env sh
set -eu

if [ ! -f "dmicher-kripta-cards/module.json" ]; then
  echo "Run this script from the Foundry module workspace root, next to dmicher-kripta-cards/module.json." >&2
  exit 1
fi

SCRIPT_FILE="$0"
LOCALE_PATH="dmicher-kripta-cards/lang/yo.json"
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
  "lang": "yo",
  "name": "Yorùbá",
  "path": "lang/yo.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "Olùlò Foundry rẹ kò tíì so mọ́ Ẹlẹ́ṣeré Sáfà nínú mójúùlù Kaadi Kripta. Jọ̀wọ́ kan sí Olùdarí Ere.",
  "KRIPTA.GMOnly": "Ìṣe yìí wà fún Olùdarí Ere nìkan.",
  "KRIPTA.Settings.ServerUrl.Name": "Àdírẹ́sì sáfà",
  "KRIPTA.Settings.TechAuthUsers.Name": "Àwọn olùlò imọ̀-ẹ̀rọ",
  "KRIPTA.Settings.PlayerBindings.Name": "Ìsọ̀kan olùlò Foundry sí ẹlẹ́ṣeré sáfà",
  "KRIPTA.Settings.UiPrefs.Name": "Ètò ìbánisọ̀rọ̀ agbègbè",
  "KRIPTA.Settings.Menu.Name": "Àwọn Kaadi Kripta",
  "KRIPTA.Settings.Menu.Label": "Ètò mójúùlù",
  "KRIPTA.Settings.Menu.Hint": "Ìsopọ̀ API àti àwọn olùlò imọ̀-ẹ̀rọ.",
  "KRIPTA.Settings.Help.BeforeServerLink": "Tí o kò bá tíì fi olupin àkóónú fún modulu náà sílẹ̀ tí o sì túnto rẹ̀, tẹle ",
  "KRIPTA.Settings.Help.ServerLink": "ìjápọ̀ yìí",
  "KRIPTA.Settings.Help.AfterServerLink": " láti ṣe bẹ́ẹ̀. Fún ìtòlẹ́sẹẹsẹ yára, lo ",
  "KRIPTA.Settings.Help.DocumentationLink": "àkọsílẹ̀ ìtọ́nisọ́nà",
  "KRIPTA.Settings.Help.AfterDocumentationLink": ".",
  "KRIPTA.Window.Catalog": "Kátálọ́ọ̀gù Kaadi",
  "KRIPTA.Window.CardDetails": "Kaadi Kátálọ́ọ̀gù",
  "KRIPTA.Window.GiveCard": "Fúnni ní Kaadi",
  "KRIPTA.Window.MyCards": "Àwọn Kaadi Ẹlẹ́ṣeré",
  "KRIPTA.Window.Players": "Ṣàkóso Àwọn Ẹlẹ́ṣeré",
  "KRIPTA.Window.Registry": "Ìforúkọsílẹ̀ Ẹlẹ́ṣeré",
  "KRIPTA.Window.RequestCard": "Béèrè Kaadi",
  "KRIPTA.Window.Settings": "Àwọn Kaadi Kripta - Ètò",
  "KRIPTA.Window.UseCard": "Lo Kaadi",
  "KRIPTA.Menu.Title": "Àwọn Kaadi Kripta",
  "KRIPTA.Menu.Catalog": "Kátálọ́ọ̀gù Kaadi",
  "KRIPTA.Menu.GetCard": "Béèrè Kaadi",
  "KRIPTA.Menu.MyCards": "Àwọn Kaadi Mi",
  "KRIPTA.Menu.Players": "Ṣàkóso Àwọn Ẹlẹ́ṣeré",
  "KRIPTA.Label.Category": "Ẹ̀ka",
  "KRIPTA.Label.Mode": "Móòdù",
  "KRIPTA.Label.Card": "Kaadi",
  "KRIPTA.Label.Player": "Ẹlẹ́ṣeré",
  "KRIPTA.Label.Name": "Orúkọ",
  "KRIPTA.Label.Comment": "Àlàyé",
  "KRIPTA.Label.CardTypes": "Irú kaadi",
  "KRIPTA.Label.Count": "Ìye",
  "KRIPTA.Label.ConfirmationCode": "Kóòdù ìmúdájú",
  "KRIPTA.Label.Id": "Ìdánimọ̀",
  "KRIPTA.Label.Key": "Kọ́kọ́rọ́",
  "KRIPTA.Label.ServerUrl": "URL sáfà",
  "KRIPTA.Label.Writer": "Akọ̀wé",
  "KRIPTA.Label.Reader": "Olùkà",
  "KRIPTA.Label.Role": "Ipa",
  "KRIPTA.Label.Binding": "Ìsọ̀kan",
  "KRIPTA.Role.GM": "Olùdarí Ere",
  "KRIPTA.Role.Player": "Ẹlẹ́ṣeré",
  "KRIPTA.Status.InGame": "lórí ayélujára",
  "KRIPTA.Status.Offline": "kúrò lórí ayélujára",
  "KRIPTA.Binding.CardsIssued": "àwọn kaadi tí a fúnni:",
  "KRIPTA.Binding.NoCards": "kò sí kaadi",
  "KRIPTA.Binding.NotBound": "ẹlẹ́ṣeré kò tíì so mọ́, so ẹlẹ́ṣeré kan.",
  "KRIPTA.Binding.CardsCountHint": "Ìye irú kaadi tí a fúnni, láìka àwọn tí ó tún ṣe",
  "KRIPTA.Button.Add": "Fi kún",
  "KRIPTA.Button.Bind": "So mọ́",
  "KRIPTA.Button.Cancel": "Fagilé",
  "KRIPTA.Button.Close": "Pa",
  "KRIPTA.Button.Confirm": "Jẹ́risi",
  "KRIPTA.Button.Delete": "Paarẹ",
  "KRIPTA.Button.Edit": "Ṣàtúnṣe",
  "KRIPTA.Button.Give": "Fúnni",
  "KRIPTA.Button.GiveCard": "Fúnni ní Kaadi",
  "KRIPTA.Button.Info": "Ìwífún",
  "KRIPTA.Button.No": "Bẹ́ẹ̀kọ́",
  "KRIPTA.Button.Output": "Firanṣẹ",
  "KRIPTA.Button.Refresh": "Túnṣe",
  "KRIPTA.Button.Registry": "Ìforúkọsílẹ̀ Ẹlẹ́ṣeré",
  "KRIPTA.Button.Request": "Béèrè",
  "KRIPTA.Button.RequestCard": "Béèrè",
  "KRIPTA.Button.SaveChanges": "Fi Ìyípadà Pamọ́",
  "KRIPTA.Button.Take": "Yọ kúrò",
  "KRIPTA.Button.TestAuth": "Ṣàyẹ̀wò àwọn olùlò imọ̀-ẹ̀rọ",
  "KRIPTA.Button.TestServer": "Ṣàyẹ̀wò sáfà",
  "KRIPTA.Button.Unbind": "Yọ ìsọ̀kan",
  "KRIPTA.Button.Use": "Lo",
  "KRIPTA.Button.Yes": "Bẹ́ẹ̀ni",
  "KRIPTA.Mode.Manual": "Yan pẹ̀lú ọwọ́",
  "KRIPTA.Mode.Random": "Láìlétò",
  "KRIPTA.Mode.Show": "Fihàn",
  "KRIPTA.Mode.Spend": "Ná",
  "KRIPTA.View.Table": "Tábìlì",
  "KRIPTA.View.Tiles": "Àwọn tile",
  "KRIPTA.Placeholder.Search": "Wá",
  "KRIPTA.Select.NotSelected": "-- a kò yan --",
  "KRIPTA.Template.EmptyCatalog": "Kò sí ẹ̀ka tàbí kaadi tí a forúkọ sí lórí sáfà.",
  "KRIPTA.Template.MyCardsTitle": "Àwọn kaadi ẹlẹ́ṣeré: {playerName}",
  "KRIPTA.Template.UseCardMissing": "Kaadi yìí kò sí ní ìforúkọsílẹ̀ sáfà mọ́.",
  "KRIPTA.Template.UseCardPrompt": "A ó lo kaadi yìí:",
  "KRIPTA.Card.FallbackName": "Kaadi {number}",
  "KRIPTA.Card.FallbackAddress": "Kaadi {level}/{number}",
  "KRIPTA.Card.MissingDescription": "Kaadi {level}/{number} kò sí nínú kátálọ́ọ̀gù sáfà lọwọlọwọ.",
  "KRIPTA.Card.NotRegisteredDescription": "Kaadi {level}/{number} kò sí ní ìforúkọsílẹ̀ sáfà mọ́.",
  "KRIPTA.Level.FallbackName": "Ìpele {level}",
  "KRIPTA.Level.MissingDescription": "Ìpele yìí wà nínú àkójọ ohun ẹlẹ́ṣeré, ṣùgbọ́n kò sí nínú kátálọ́ọ̀gù sáfà lọwọlọwọ.",
  "KRIPTA.Chat.BlobReadFailed": "Kò ṣeé ka blob",
  "KRIPTA.Chat.CardGivenTitle": "A Ti Fúnni Ní Kaadi",
  "KRIPTA.Chat.CardReceiveSubtitle": "Ẹlẹ́ṣeré {playerName} gba kaadi {cardSubtitle}",
  "KRIPTA.Chat.CardRequestCanceled": "A fagilé ìbéèrè kaadi.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "A Ti Jẹ́risi Ìbéèrè Kaadi",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "Kò ṣeé ka data ìbéèrè.",
  "KRIPTA.Chat.CardSpentFooter": "A TI NÁ KAADI",
  "KRIPTA.Chat.CardSpentTitle": "A Ti Ná Kaadi",
  "KRIPTA.Chat.FallbackPlayer": "ẹlẹ́ṣeré",
  "KRIPTA.Chat.ManualChoiceFooter": "YÍYAN PẸ̀LÚ ỌWỌ́",
  "KRIPTA.Chat.ReferenceTitle": "Ìtọ́kasí",
  "KRIPTA.Chat.RequestManualTitle": "Ìbéèrè Kaadi Tí A Yan",
  "KRIPTA.Chat.RequestRandomTitle": "Ìbéèrè Kaadi Láìlétò",
  "KRIPTA.Chat.ShowCardTitle": "Ìtọ́kasí Kaadi",
  "KRIPTA.Dialog.BindPlayer.Title": "So Ẹlẹ́ṣeré Sáfà Mọ́",
  "KRIPTA.Dialog.BindPlayer.Header": "Yan ẹlẹ́ṣeré fún {foundryUserName}",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "olùlò Foundry",
  "KRIPTA.Dialog.Player.AddTitle": "Fi Ẹlẹ́ṣeré Kún",
  "KRIPTA.Dialog.Player.EditTitle": "Ṣàtúnṣe Ẹlẹ́ṣeré",
  "KRIPTA.Dialog.Player.DeleteTitle": "Paarẹ Ẹlẹ́ṣeré",
  "KRIPTA.Dialog.Player.DeleteWarning": "Pípaarẹ ẹlẹ́ṣeré \"{playerName}\" kò le yí padà. Tẹ \"{code}\" kí o sì jẹ́risi pípaarẹ.",
  "KRIPTA.Dialog.Count.TotalCards": "àpapọ̀ kaadi irú yìí - {max}",
  "KRIPTA.Error.InvalidCardLevel": "Ìpele tí kò tọ́ fún {context}: {level}",
  "KRIPTA.Error.InvalidCardNumber": "Nọ́ńbà tí kò tọ́ fún {context}: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "ìpele kaadi tí kò tọ́: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "nọ́ńbà kaadi tí kò tọ́: {number}",
  "KRIPTA.Error.InvalidRequestCard": "Kaadi tí kò tọ́ fún ìbéèrè",
  "KRIPTA.Error.InvalidGiveCard": "Kaadi tí kò tọ́ fún fífúnni",
  "KRIPTA.Error.MissingRequestPlayerGuid": "Kò ṣeé pinnu playerGuid fún fífúnni ní kaadi.",
  "KRIPTA.Error.MissingSelectedCard": "Kò ṣeé pinnu kaadi tí a yan.",
  "KRIPTA.Error.MissingSelectedCardForGive": "Kò ṣeé pinnu kaadi tí a yan láti fúnni.",
  "KRIPTA.Error.MissingGivePlayer": "Kò ṣeé pinnu ẹlẹ́ṣeré tí a ó fún ní kaadi.",
  "KRIPTA.Error.MissingGiveCard": "Kò ṣeé pinnu kaadi tí a ó fúnni.",
  "KRIPTA.Error.MissingServerUrl": "Ètò ipa sáfà kò sí.",
  "KRIPTA.Error.InvalidReader": "Olùlò imọ̀-ẹ̀rọ Reader ni a ti ṣètò lọ́nà tí kò tọ́.",
  "KRIPTA.Error.InvalidWriter": "Olùlò imọ̀-ẹ̀rọ Writer ni a ti ṣètò lọ́nà tí kò tọ́.",
  "KRIPTA.Error.MenuUnavailable": "Ẹ̀ya yìí kò sí. Ṣàyẹ̀wò àwọn ètò mójúùlù. Àwọn àlàyé wà nínú console aṣàwákiri.",
  "KRIPTA.Error.Generic": "Àṣìṣe ṣẹlẹ̀",
  "KRIPTA.Error.Unknown": "àṣìṣe tí a kò mọ̀",
  "KRIPTA.Error.NameRequired": "A nílò ààyè Orúkọ.",
  "KRIPTA.Error.RegistryDeleteReturned": "sáfà dá ẹlẹ́ṣeré padà sí ìforúkọsílẹ̀ lẹ́yìn pípaarẹ.",
  "KRIPTA.Notification.CardGiven": "A ti fúnni ní kaadi.",
  "KRIPTA.Notification.CardUsed": "A ti lo kaadi, a sì ti ná a.",
  "KRIPTA.Notification.CardWrittenOff": "A ti yọ kaadi kúrò.",
  "KRIPTA.Notification.CannotUseMissingCard": "Kaadi yìí kò sí ní ìforúkọsílẹ̀ sáfà mọ́. Kò ṣeé lo.",
  "KRIPTA.Notification.MissingCard": "Kaadi yìí kò sí ní ìforúkọsílẹ̀ sáfà mọ́.",
  "KRIPTA.Notification.PlayerNotSelected": "A kò yan ẹlẹ́ṣeré fún fífúnni ní kaadi",
  "KRIPTA.Notification.PlayerBindingMissing": "Kò ṣeé pinnu ìsọ̀kan ẹlẹ́ṣeré fún fífúnni ní kaadi",
  "KRIPTA.Notification.RequestSent": "A ti fi ìbéèrè kaadi ránṣẹ́ sí ìfọ̀rọ̀wérọ̀.",
  "KRIPTA.Notification.ServerSuccess": "Ìsopọ̀ ṣàṣeyọrí.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "Ìsopọ̀ ṣàṣeyọrí. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "Kò ṣeé sopọ̀ mọ́ sáfà. Ṣàyẹ̀wò àdírẹ́sì, wíwà sáfà, àti ètò CORS/HTTPS.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "Kò ṣeé ṣàyẹ̀wò sáfà.",
  "KRIPTA.Notification.InvalidServerUrl": "Àdírẹ́sì sáfà tí kò tọ́: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "Ẹ̀ka ètò Kaadi Kripta wà fún àwọn ipa Olùdarí Ere àti Olùrànlọ́wọ́ Olùdarí Ere nìkan.",
  "KRIPTA.Notification.ServerCheckFailed": "Ìyẹ̀wò sáfà kùnà",
  "KRIPTA.Notification.TechUserReader": "Olùkà",
  "KRIPTA.Notification.TechUserWriter": "Akọ̀wé",
  "KRIPTA.Notification.TechUsersCheckSuccess": "Àwọn olùlò imọ̀-ẹ̀rọ \"Reader\" àti \"Writer\" kọjá ìyẹ̀wò.",
  "KRIPTA.Notification.SettingsSaved": "A ti fi ètò ìsopọ̀ pamọ́.",
  "KRIPTA.Notification.PlayerAdded": "A ti fi ẹlẹ́ṣeré kún.",
  "KRIPTA.Notification.PlayerUpdated": "A ti ṣe àfikún tuntun sí ẹlẹ́ṣeré.",
  "KRIPTA.Notification.PlayerDeleted": "A ti pa ẹlẹ́ṣeré rẹ́.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "A fagilé pípaarẹ. Ààyè ìmúdájú ni a kún lọ́nà tí kò tọ́.",
  "KRIPTA.Notification.BindingSaved": "A ti fi ìsọ̀kan pamọ́.",
  "KRIPTA.Notification.BindingDeleted": "A ti yọ ìsọ̀kan kúrò.",
  "KRIPTA.Notification.BadCatalogCardNumber": "Kaadi tí a yan ní nọ́ńbà tí kò tọ́. Ṣàyẹ̀wò ìdáhùn getCardsList àti normalizeCardsList.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "A kò le fúnni ní kaadi yìí pẹ̀lú ọwọ́ nítorí pé ó ní nọ́ńbà tí kò tọ́. Ṣàyẹ̀wò ìdáhùn getCardsList àti normalizeCardsList.",
  "KRIPTA.Notification.CardOutputFailed": "Kò ṣeé fi kaadi ránṣẹ́ sí ìfọ̀rọ̀wérọ̀",
  "KRIPTA.Notification.CardGiveFailed": "Kò ṣeé fúnni ní kaadi",
  "KRIPTA.Notification.CardUseFailed": "Kò ṣeé lo kaadi",
  "KRIPTA.Notification.CardTakeFailed": "Kò ṣeé yọ kaadi kúrò",
  "KRIPTA.Notification.CardRequestFailed": "Kò ṣeé fi ìbéèrè kaadi ránṣẹ́",
  "KRIPTA.Notification.CardRequestConfirmFailed": "Kò ṣeé jẹ́risi fífúnni ní kaadi",
  "KRIPTA.Notification.PlayerAddFailed": "Kò ṣeé fi ẹlẹ́ṣeré kún",
  "KRIPTA.Notification.PlayerUpdateFailed": "Kò ṣeé ṣe àfikún tuntun sí ẹlẹ́ṣeré",
  "KRIPTA.Notification.PlayerDeleteFailed": "Kò ṣeé pa ẹlẹ́ṣeré rẹ́",
  "KRIPTA.Notification.CardRollFailed": "Kò ṣeé gba kaadi.",
  "KRIPTA.Dialog.TakeCard.Title": "Yọ Kaadi Kúrò",
  "KRIPTA.Dialog.TakeCard.Message": "Ẹlẹ́ṣeré {playerName} yóò pàdánù kaadi {cardName}.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Fúnni ní Kaadi"
}
__END_LOCALE_JSON__
