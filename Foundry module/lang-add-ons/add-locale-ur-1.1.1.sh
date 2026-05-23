#!/usr/bin/env sh
set -eu

if [ ! -f "dmicher-kripta-cards/module.json" ]; then
  echo "Run this script from the Foundry module workspace root, next to dmicher-kripta-cards/module.json." >&2
  exit 1
fi

SCRIPT_FILE="$0"
LOCALE_PATH="dmicher-kripta-cards/lang/ur.json"
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
  "lang": "ur",
  "name": "اردو",
  "path": "lang/ur.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "آپ کا Foundry صارف Kripta Cards ماڈیول میں کسی سرور کھلاڑی سے منسلک نہیں ہے۔ براہ کرم گیم ماسٹر سے رابطہ کریں۔",
  "KRIPTA.GMOnly": "یہ کارروائی صرف گیم ماسٹر کے لیے دستیاب ہے۔",
  "KRIPTA.Settings.ServerUrl.Name": "سرور کا پتہ",
  "KRIPTA.Settings.TechAuthUsers.Name": "تکنیکی صارفین",
  "KRIPTA.Settings.PlayerBindings.Name": "Foundry صارفین اور سرور کھلاڑیوں کی وابستگیاں",
  "KRIPTA.Settings.UiPrefs.Name": "مقامی انٹرفیس ترتیبات",
  "KRIPTA.Settings.Menu.Name": "Kripta Cards",
  "KRIPTA.Settings.Menu.Label": "ماڈیول ترتیبات",
  "KRIPTA.Settings.Menu.Hint": "API کنکشن اور تکنیکی صارفین۔",
  "KRIPTA.Settings.Help.BeforeServerLink": "اگر آپ نے ماڈیول کے لیے مواد کا سرور ابھی تک انسٹال اور ترتیب نہیں دیا ہے، تو ایسا کرنے کے لیے ",
  "KRIPTA.Settings.Help.ServerLink": "اس لنک",
  "KRIPTA.Settings.Help.AfterServerLink": " پر جائیں۔ فوری ترتیب کے لیے ",
  "KRIPTA.Settings.Help.DocumentationLink": "دستاویزات",
  "KRIPTA.Settings.Help.AfterDocumentationLink": " استعمال کریں۔",
  "KRIPTA.Window.Catalog": "کارڈ کیٹلاگ",
  "KRIPTA.Window.CardDetails": "کیٹلاگ کارڈ",
  "KRIPTA.Window.GiveCard": "کارڈ دیں",
  "KRIPTA.Window.MyCards": "کھلاڑی کے کارڈ",
  "KRIPTA.Window.Players": "کھلاڑیوں کا انتظام",
  "KRIPTA.Window.Registry": "کھلاڑی رجسٹری",
  "KRIPTA.Window.RequestCard": "کارڈ کی درخواست",
  "KRIPTA.Window.Settings": "Kripta Cards - ترتیبات",
  "KRIPTA.Window.UseCard": "کارڈ استعمال کریں",
  "KRIPTA.Menu.Title": "Kripta Cards",
  "KRIPTA.Menu.Catalog": "کارڈ کیٹلاگ",
  "KRIPTA.Menu.GetCard": "کارڈ کی درخواست",
  "KRIPTA.Menu.MyCards": "میرے کارڈ",
  "KRIPTA.Menu.Players": "کھلاڑیوں کا انتظام",
  "KRIPTA.Label.Category": "زمرہ",
  "KRIPTA.Label.Mode": "موڈ",
  "KRIPTA.Label.Card": "کارڈ",
  "KRIPTA.Label.Player": "کھلاڑی",
  "KRIPTA.Label.Name": "نام",
  "KRIPTA.Label.Comment": "تبصرہ",
  "KRIPTA.Label.CardTypes": "کارڈ کی اقسام",
  "KRIPTA.Label.Count": "تعداد",
  "KRIPTA.Label.ConfirmationCode": "تصدیقی کوڈ",
  "KRIPTA.Label.Id": "Id",
  "KRIPTA.Label.Key": "Key",
  "KRIPTA.Label.ServerUrl": "سرور URL",
  "KRIPTA.Label.Writer": "Writer",
  "KRIPTA.Label.Reader": "Reader",
  "KRIPTA.Label.Role": "کردار",
  "KRIPTA.Label.Binding": "وابستگی",
  "KRIPTA.Role.GM": "گیم ماسٹر",
  "KRIPTA.Role.Player": "کھلاڑی",
  "KRIPTA.Status.InGame": "آن لائن",
  "KRIPTA.Status.Offline": "آف لائن",
  "KRIPTA.Binding.CardsIssued": "دیے گئے کارڈ:",
  "KRIPTA.Binding.NoCards": "کوئی کارڈ نہیں",
  "KRIPTA.Binding.NotBound": "کھلاڑی منسلک نہیں ہے، کھلاڑی کو منسلک کریں۔",
  "KRIPTA.Binding.CardsCountHint": "دی گئی کارڈ اقسام کی تعداد، تکرار کے بغیر",
  "KRIPTA.Button.Add": "شامل کریں",
  "KRIPTA.Button.Bind": "منسلک کریں",
  "KRIPTA.Button.Cancel": "منسوخ",
  "KRIPTA.Button.Close": "بند کریں",
  "KRIPTA.Button.Confirm": "تصدیق",
  "KRIPTA.Button.Delete": "حذف کریں",
  "KRIPTA.Button.Edit": "ترمیم",
  "KRIPTA.Button.Give": "دیں",
  "KRIPTA.Button.GiveCard": "کارڈ دیں",
  "KRIPTA.Button.Info": "معلومات",
  "KRIPTA.Button.No": "نہیں",
  "KRIPTA.Button.Output": "پوسٹ کریں",
  "KRIPTA.Button.Refresh": "تازہ کریں",
  "KRIPTA.Button.Registry": "کھلاڑی رجسٹری",
  "KRIPTA.Button.Request": "درخواست",
  "KRIPTA.Button.RequestCard": "درخواست",
  "KRIPTA.Button.SaveChanges": "تبدیلیاں محفوظ کریں",
  "KRIPTA.Button.Take": "واپس لیں",
  "KRIPTA.Button.TestAuth": "تکنیکی صارفین چیک کریں",
  "KRIPTA.Button.TestServer": "سرور چیک کریں",
  "KRIPTA.Button.Unbind": "وابستگی ختم کریں",
  "KRIPTA.Button.Use": "استعمال کریں",
  "KRIPTA.Button.Yes": "ہاں",
  "KRIPTA.Mode.Manual": "دستی انتخاب",
  "KRIPTA.Mode.Random": "تصادفی",
  "KRIPTA.Mode.Show": "دکھائیں",
  "KRIPTA.Mode.Spend": "خرچ کریں",
  "KRIPTA.View.Table": "جدول",
  "KRIPTA.View.Tiles": "ٹائلز",
  "KRIPTA.Placeholder.Search": "تلاش",
  "KRIPTA.Select.NotSelected": "-- منتخب نہیں --",
  "KRIPTA.Template.EmptyCatalog": "سرور پر کوئی رجسٹرڈ زمرہ یا کارڈ موجود نہیں۔",
  "KRIPTA.Template.MyCardsTitle": "کھلاڑی کے کارڈ: {playerName}",
  "KRIPTA.Template.UseCardMissing": "یہ کارڈ اب سرور پر رجسٹرڈ نہیں ہے۔",
  "KRIPTA.Template.UseCardPrompt": "یہ کارڈ استعمال کیا جائے گا:",
  "KRIPTA.Card.FallbackName": "کارڈ {number}",
  "KRIPTA.Card.FallbackAddress": "کارڈ {level}/{number}",
  "KRIPTA.Card.MissingDescription": "کارڈ {level}/{number} موجودہ سرور کیٹلاگ میں موجود نہیں۔",
  "KRIPTA.Card.NotRegisteredDescription": "کارڈ {level}/{number} اب سرور پر رجسٹرڈ نہیں ہے۔",
  "KRIPTA.Level.FallbackName": "سطح {level}",
  "KRIPTA.Level.MissingDescription": "یہ سطح کھلاڑی کی انوینٹری میں موجود ہے، لیکن موجودہ سرور کیٹلاگ میں موجود نہیں۔",
  "KRIPTA.Chat.BlobReadFailed": "blob پڑھنے میں ناکامی",
  "KRIPTA.Chat.CardGivenTitle": "کارڈ دے دیا گیا",
  "KRIPTA.Chat.CardReceiveSubtitle": "کھلاڑی {playerName} کو کارڈ {cardSubtitle} ملتا ہے",
  "KRIPTA.Chat.CardRequestCanceled": "کارڈ کی درخواست منسوخ ہو گئی۔",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "کارڈ کی درخواست کی تصدیق ہو گئی",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "درخواست کا ڈیٹا پڑھنے میں ناکامی۔",
  "KRIPTA.Chat.CardSpentFooter": "کارڈ خرچ ہو گیا",
  "KRIPTA.Chat.CardSpentTitle": "کارڈ خرچ ہو گیا",
  "KRIPTA.Chat.FallbackPlayer": "کھلاڑی",
  "KRIPTA.Chat.ManualChoiceFooter": "دستی انتخاب",
  "KRIPTA.Chat.ReferenceTitle": "حوالہ",
  "KRIPTA.Chat.RequestManualTitle": "منتخب کارڈ کی درخواست",
  "KRIPTA.Chat.RequestRandomTitle": "تصادفی کارڈ کی درخواست",
  "KRIPTA.Chat.ShowCardTitle": "کارڈ حوالہ",
  "KRIPTA.Dialog.BindPlayer.Title": "سرور کھلاڑی منسلک کریں",
  "KRIPTA.Dialog.BindPlayer.Header": "{foundryUserName} کے لیے کھلاڑی منتخب کریں",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "Foundry صارف",
  "KRIPTA.Dialog.Player.AddTitle": "کھلاڑی شامل کریں",
  "KRIPTA.Dialog.Player.EditTitle": "کھلاڑی میں ترمیم",
  "KRIPTA.Dialog.Player.DeleteTitle": "کھلاڑی حذف کریں",
  "KRIPTA.Dialog.Player.DeleteWarning": "کھلاڑی \"{playerName}\" کو حذف کرنا واپس نہیں کیا جا سکتا۔ \"{code}\" درج کریں اور حذف کرنے کی تصدیق کریں۔",
  "KRIPTA.Dialog.Count.TotalCards": "اس قسم کے کل کارڈ - {max}",
  "KRIPTA.Error.InvalidCardLevel": "{context} کے لیے غلط سطح: {level}",
  "KRIPTA.Error.InvalidCardNumber": "{context} کے لیے غلط نمبر: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "غلط کارڈ سطح: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "غلط کارڈ نمبر: {number}",
  "KRIPTA.Error.InvalidRequestCard": "درخواست کے لیے غلط کارڈ",
  "KRIPTA.Error.InvalidGiveCard": "دینے کے لیے غلط کارڈ",
  "KRIPTA.Error.MissingRequestPlayerGuid": "کارڈ دینے کے لیے playerGuid کا تعین نہیں ہو سکا۔",
  "KRIPTA.Error.MissingSelectedCard": "منتخب کارڈ کا تعین نہیں ہو سکا۔",
  "KRIPTA.Error.MissingSelectedCardForGive": "دینے کے لیے منتخب کارڈ کا تعین نہیں ہو سکا۔",
  "KRIPTA.Error.MissingGivePlayer": "کارڈ لینے والے کھلاڑی کا تعین نہیں ہو سکا۔",
  "KRIPTA.Error.MissingGiveCard": "دیے جانے والے کارڈ کا تعین نہیں ہو سکا۔",
  "KRIPTA.Error.MissingServerUrl": "سرور پاتھ سیٹنگ موجود نہیں۔",
  "KRIPTA.Error.InvalidReader": "Reader تکنیکی صارف غلط طور پر ترتیب دیا گیا ہے۔",
  "KRIPTA.Error.InvalidWriter": "Writer تکنیکی صارف غلط طور پر ترتیب دیا گیا ہے۔",
  "KRIPTA.Error.MenuUnavailable": "یہ فیچر دستیاب نہیں۔ ماڈیول ترتیبات چیک کریں۔ تفصیلات براؤزر کنسول میں ہیں۔",
  "KRIPTA.Error.Generic": "ایک خرابی پیش آئی",
  "KRIPTA.Error.Unknown": "نامعلوم خرابی",
  "KRIPTA.Error.NameRequired": "Name فیلڈ لازمی ہے۔",
  "KRIPTA.Error.RegistryDeleteReturned": "حذف کرنے کے بعد سرور نے کھلاڑی کو رجسٹری میں واپس کر دیا۔",
  "KRIPTA.Notification.CardGiven": "کارڈ دے دیا گیا۔",
  "KRIPTA.Notification.CardUsed": "کارڈ استعمال اور خرچ ہو گیا۔",
  "KRIPTA.Notification.CardWrittenOff": "کارڈ ہٹا دیا گیا۔",
  "KRIPTA.Notification.CannotUseMissingCard": "یہ کارڈ اب سرور پر رجسٹرڈ نہیں ہے۔ اسے استعمال نہیں کیا جا سکتا۔",
  "KRIPTA.Notification.MissingCard": "یہ کارڈ اب سرور پر رجسٹرڈ نہیں ہے۔",
  "KRIPTA.Notification.PlayerNotSelected": "کارڈ دینے کے لیے کوئی کھلاڑی منتخب نہیں",
  "KRIPTA.Notification.PlayerBindingMissing": "کارڈ دینے کے لیے کھلاڑی کی وابستگی کا تعین نہیں ہو سکا",
  "KRIPTA.Notification.RequestSent": "کارڈ کی درخواست چیٹ میں بھیج دی گئی۔",
  "KRIPTA.Notification.ServerSuccess": "کنکشن کامیاب۔",
  "KRIPTA.Notification.ServerSuccessWithDetails": "کنکشن کامیاب۔ {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "سرور سے کنکشن ناکام۔ پتہ، سرور کی دستیابی، اور CORS/HTTPS ترتیبات چیک کریں۔",
  "KRIPTA.Notification.ServerCheckFailedFallback": "سرور چیک نہیں ہو سکا۔",
  "KRIPTA.Notification.InvalidServerUrl": "غلط سرور پتہ: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "Kripta Cards ترتیبات کا حصہ صرف گیم ماسٹر اور اسسٹنٹ گیم ماسٹر کرداروں کے لیے دستیاب ہے۔",
  "KRIPTA.Notification.ServerCheckFailed": "سرور چیک ناکام",
  "KRIPTA.Notification.TechUserReader": "Reader",
  "KRIPTA.Notification.TechUserWriter": "Writer",
  "KRIPTA.Notification.TechUsersCheckSuccess": "\"Reader\" اور \"Writer\" تکنیکی صارفین چیک میں کامیاب ہیں۔",
  "KRIPTA.Notification.SettingsSaved": "کنکشن ترتیبات محفوظ ہو گئیں۔",
  "KRIPTA.Notification.PlayerAdded": "کھلاڑی شامل ہو گیا۔",
  "KRIPTA.Notification.PlayerUpdated": "کھلاڑی اپ ڈیٹ ہو گیا۔",
  "KRIPTA.Notification.PlayerDeleted": "کھلاڑی حذف ہو گیا۔",
  "KRIPTA.Notification.DeleteCanceledBadCode": "حذف کرنا منسوخ ہو گیا۔ تصدیقی فیلڈ غلط بھری گئی۔",
  "KRIPTA.Notification.BindingSaved": "وابستگی محفوظ ہو گئی۔",
  "KRIPTA.Notification.BindingDeleted": "وابستگی ہٹا دی گئی۔",
  "KRIPTA.Notification.BadCatalogCardNumber": "منتخب کارڈ کا نمبر غلط ہے۔ getCardsList جواب اور normalizeCardsList چیک کریں۔",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "یہ کارڈ دستی طور پر نہیں دیا جا سکتا کیونکہ اس کا نمبر غلط ہے۔ getCardsList جواب اور normalizeCardsList چیک کریں۔",
  "KRIPTA.Notification.CardOutputFailed": "کارڈ کو چیٹ میں پوسٹ کرنے میں ناکامی",
  "KRIPTA.Notification.CardGiveFailed": "کارڈ دینے میں ناکامی",
  "KRIPTA.Notification.CardUseFailed": "کارڈ استعمال کرنے میں ناکامی",
  "KRIPTA.Notification.CardTakeFailed": "کارڈ ہٹانے میں ناکامی",
  "KRIPTA.Notification.CardRequestFailed": "کارڈ درخواست بھیجنے میں ناکامی",
  "KRIPTA.Notification.CardRequestConfirmFailed": "کارڈ دینے کی تصدیق میں ناکامی",
  "KRIPTA.Notification.PlayerAddFailed": "کھلاڑی شامل کرنے میں ناکامی",
  "KRIPTA.Notification.PlayerUpdateFailed": "کھلاڑی اپ ڈیٹ کرنے میں ناکامی",
  "KRIPTA.Notification.PlayerDeleteFailed": "کھلاڑی حذف کرنے میں ناکامی",
  "KRIPTA.Notification.CardRollFailed": "کارڈ وصول کرنے میں ناکامی۔",
  "KRIPTA.Dialog.TakeCard.Title": "کارڈ واپس لیں",
  "KRIPTA.Dialog.TakeCard.Message": "کھلاڑی {playerName} کارڈ {cardName} کھو دے گا۔",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "کارڈ دیں"
}
__END_LOCALE_JSON__
