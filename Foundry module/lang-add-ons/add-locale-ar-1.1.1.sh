#!/usr/bin/env sh
set -eu

if [ ! -f "dmicher-kripta-cards/module.json" ]; then
  echo "Run this script from the Foundry module workspace root, next to dmicher-kripta-cards/module.json." >&2
  exit 1
fi

SCRIPT_FILE="$0"
LOCALE_PATH="dmicher-kripta-cards/lang/ar.json"
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
  "lang": "ar",
  "name": "العربية",
  "path": "lang/ar.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "مستخدم Foundry الخاص بك غير مرتبط بلاعب على الخادم في وحدة Kripta Cards. يرجى التواصل مع مدير اللعبة.",
  "KRIPTA.GMOnly": "هذا الإجراء متاح لمدير اللعبة فقط.",
  "KRIPTA.Settings.ServerUrl.Name": "عنوان الخادم",
  "KRIPTA.Settings.TechAuthUsers.Name": "المستخدمون التقنيون",
  "KRIPTA.Settings.PlayerBindings.Name": "ربط مستخدمي Foundry بلاعبي الخادم",
  "KRIPTA.Settings.UiPrefs.Name": "إعدادات الواجهة المحلية",
  "KRIPTA.Settings.Menu.Name": "Kripta Cards",
  "KRIPTA.Settings.Menu.Label": "إعدادات الوحدة",
  "KRIPTA.Settings.Menu.Hint": "اتصال API والمستخدمون التقنيون.",
  "KRIPTA.Settings.Help.BeforeServerLink": "إذا لم تكن قد ثبّتّ وأعددت خادم المحتوى للوحدة بعد، فاتبع ",
  "KRIPTA.Settings.Help.ServerLink": "هذا الرابط",
  "KRIPTA.Settings.Help.AfterServerLink": " للقيام بذلك. للإعداد السريع، استخدم ",
  "KRIPTA.Settings.Help.DocumentationLink": "الوثائق",
  "KRIPTA.Settings.Help.AfterDocumentationLink": ".",
  "KRIPTA.Window.Catalog": "فهرس البطاقات",
  "KRIPTA.Window.CardDetails": "بطاقة الفهرس",
  "KRIPTA.Window.GiveCard": "منح بطاقة",
  "KRIPTA.Window.MyCards": "بطاقات اللاعب",
  "KRIPTA.Window.Players": "إدارة اللاعبين",
  "KRIPTA.Window.Registry": "سجل اللاعبين",
  "KRIPTA.Window.RequestCard": "طلب بطاقة",
  "KRIPTA.Window.Settings": "Kripta Cards - الإعدادات",
  "KRIPTA.Window.UseCard": "استخدام بطاقة",
  "KRIPTA.Menu.Title": "Kripta Cards",
  "KRIPTA.Menu.Catalog": "فهرس البطاقات",
  "KRIPTA.Menu.GetCard": "طلب بطاقة",
  "KRIPTA.Menu.MyCards": "بطاقاتي",
  "KRIPTA.Menu.Players": "إدارة اللاعبين",
  "KRIPTA.Label.Category": "الفئة",
  "KRIPTA.Label.Mode": "الوضع",
  "KRIPTA.Label.Card": "البطاقة",
  "KRIPTA.Label.Player": "اللاعب",
  "KRIPTA.Label.Name": "الاسم",
  "KRIPTA.Label.Comment": "تعليق",
  "KRIPTA.Label.CardTypes": "أنواع البطاقات",
  "KRIPTA.Label.Count": "الكمية",
  "KRIPTA.Label.ConfirmationCode": "رمز التأكيد",
  "KRIPTA.Label.Id": "Id",
  "KRIPTA.Label.Key": "Key",
  "KRIPTA.Label.ServerUrl": "رابط الخادم",
  "KRIPTA.Label.Writer": "Writer",
  "KRIPTA.Label.Reader": "Reader",
  "KRIPTA.Label.Role": "الدور",
  "KRIPTA.Label.Binding": "الربط",
  "KRIPTA.Role.GM": "مدير اللعبة",
  "KRIPTA.Role.Player": "لاعب",
  "KRIPTA.Status.InGame": "داخل اللعبة",
  "KRIPTA.Status.Offline": "غير متصل",
  "KRIPTA.Binding.CardsIssued": "البطاقات الممنوحة:",
  "KRIPTA.Binding.NoCards": "لا توجد بطاقات",
  "KRIPTA.Binding.NotBound": "اللاعب غير مرتبط، اختر لاعبًا.",
  "KRIPTA.Binding.CardsCountHint": "عدد أنواع البطاقات الممنوحة، من دون احتساب التكرارات",
  "KRIPTA.Button.Add": "إضافة",
  "KRIPTA.Button.Bind": "ربط",
  "KRIPTA.Button.Cancel": "إلغاء",
  "KRIPTA.Button.Close": "إغلاق",
  "KRIPTA.Button.Confirm": "تأكيد",
  "KRIPTA.Button.Delete": "حذف",
  "KRIPTA.Button.Edit": "تعديل",
  "KRIPTA.Button.Give": "منح",
  "KRIPTA.Button.GiveCard": "منح بطاقة",
  "KRIPTA.Button.Info": "معلومات",
  "KRIPTA.Button.No": "لا",
  "KRIPTA.Button.Output": "نشر",
  "KRIPTA.Button.Refresh": "تحديث",
  "KRIPTA.Button.Registry": "سجل اللاعبين",
  "KRIPTA.Button.Request": "طلب",
  "KRIPTA.Button.RequestCard": "طلب",
  "KRIPTA.Button.SaveChanges": "حفظ التغييرات",
  "KRIPTA.Button.Take": "سحب",
  "KRIPTA.Button.TestAuth": "فحص المستخدمين التقنيين",
  "KRIPTA.Button.TestServer": "فحص الخادم",
  "KRIPTA.Button.Unbind": "إلغاء الربط",
  "KRIPTA.Button.Use": "استخدام",
  "KRIPTA.Button.Yes": "نعم",
  "KRIPTA.Mode.Manual": "اختيار يدوي",
  "KRIPTA.Mode.Random": "عشوائي",
  "KRIPTA.Mode.Show": "إظهار",
  "KRIPTA.Mode.Spend": "استهلاك",
  "KRIPTA.View.Table": "جدول",
  "KRIPTA.View.Tiles": "بلاطات",
  "KRIPTA.Placeholder.Search": "بحث",
  "KRIPTA.Select.NotSelected": "-- غير محدد --",
  "KRIPTA.Template.EmptyCatalog": "لا توجد فئات أو بطاقات مسجلة على الخادم.",
  "KRIPTA.Template.MyCardsTitle": "بطاقات اللاعب: {playerName}",
  "KRIPTA.Template.UseCardMissing": "هذه البطاقة لم تعد مسجلة على الخادم.",
  "KRIPTA.Template.UseCardPrompt": "سيتم استخدام هذه البطاقة:",
  "KRIPTA.Card.FallbackName": "بطاقة {number}",
  "KRIPTA.Card.FallbackAddress": "بطاقة {level}/{number}",
  "KRIPTA.Card.MissingDescription": "البطاقة {level}/{number} غير موجودة في فهرس الخادم الحالي.",
  "KRIPTA.Card.NotRegisteredDescription": "البطاقة {level}/{number} لم تعد مسجلة على الخادم.",
  "KRIPTA.Level.FallbackName": "المستوى {level}",
  "KRIPTA.Level.MissingDescription": "هذا المستوى موجود في مخزون اللاعب لكنه غير موجود في فهرس الخادم الحالي.",
  "KRIPTA.Chat.BlobReadFailed": "تعذرت قراءة blob",
  "KRIPTA.Chat.CardGivenTitle": "تم منح البطاقة",
  "KRIPTA.Chat.CardReceiveSubtitle": "اللاعب {playerName} يحصل على البطاقة {cardSubtitle}",
  "KRIPTA.Chat.CardRequestCanceled": "تم إلغاء طلب البطاقة.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "تم تأكيد طلب البطاقة",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "تعذرت قراءة بيانات الطلب.",
  "KRIPTA.Chat.CardSpentFooter": "تم استهلاك البطاقة",
  "KRIPTA.Chat.CardSpentTitle": "تم استهلاك البطاقة",
  "KRIPTA.Chat.FallbackPlayer": "لاعب",
  "KRIPTA.Chat.ManualChoiceFooter": "اختيار يدوي",
  "KRIPTA.Chat.ReferenceTitle": "مرجع",
  "KRIPTA.Chat.RequestManualTitle": "طلب بطاقة محددة",
  "KRIPTA.Chat.RequestRandomTitle": "طلب بطاقة عشوائية",
  "KRIPTA.Chat.ShowCardTitle": "مرجع البطاقة",
  "KRIPTA.Dialog.BindPlayer.Title": "ربط لاعب الخادم",
  "KRIPTA.Dialog.BindPlayer.Header": "اختر لاعبًا لـ {foundryUserName}",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "مستخدم Foundry",
  "KRIPTA.Dialog.Player.AddTitle": "إضافة لاعب",
  "KRIPTA.Dialog.Player.EditTitle": "تعديل اللاعب",
  "KRIPTA.Dialog.Player.DeleteTitle": "حذف اللاعب",
  "KRIPTA.Dialog.Player.DeleteWarning": "لا يمكن التراجع عن حذف اللاعب \"{playerName}\". أدخل {code} وأكد الحذف.",
  "KRIPTA.Dialog.Count.TotalCards": "إجمالي البطاقات من هذا النوع - {max}",
  "KRIPTA.Error.InvalidCardLevel": "مستوى غير صالح لـ {context}: {level}",
  "KRIPTA.Error.InvalidCardNumber": "رقم غير صالح لـ {context}: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "مستوى البطاقة غير صالح: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "رقم البطاقة غير صالح: {number}",
  "KRIPTA.Error.InvalidRequestCard": "بطاقة غير صالحة للطلب",
  "KRIPTA.Error.InvalidGiveCard": "بطاقة غير صالحة للمنح",
  "KRIPTA.Error.MissingRequestPlayerGuid": "تعذر تحديد playerGuid لمنح البطاقة.",
  "KRIPTA.Error.MissingSelectedCard": "تعذر تحديد البطاقة المختارة.",
  "KRIPTA.Error.MissingSelectedCardForGive": "تعذر تحديد البطاقة المختارة للمنح.",
  "KRIPTA.Error.MissingGivePlayer": "تعذر تحديد اللاعب الذي سيحصل على البطاقة.",
  "KRIPTA.Error.MissingGiveCard": "تعذر تحديد البطاقة التي سيتم منحها.",
  "KRIPTA.Error.MissingServerUrl": "إعداد مسار الخادم مفقود.",
  "KRIPTA.Error.InvalidReader": "المستخدم التقني Reader مكوّن بشكل غير صحيح.",
  "KRIPTA.Error.InvalidWriter": "المستخدم التقني Writer مكوّن بشكل غير صحيح.",
  "KRIPTA.Error.MenuUnavailable": "هذه الميزة غير متاحة. تحقق من إعدادات الوحدة. التفاصيل في وحدة تحكم المتصفح.",
  "KRIPTA.Error.Generic": "حدث خطأ",
  "KRIPTA.Error.Unknown": "خطأ غير معروف",
  "KRIPTA.Error.NameRequired": "api 400: حقل Name مطلوب.",
  "KRIPTA.Error.RegistryDeleteReturned": "أعاد الخادم اللاعب في السجل بعد الحذف.",
  "KRIPTA.Notification.CardGiven": "تم منح البطاقة.",
  "KRIPTA.Notification.CardUsed": "تم استخدام البطاقة واستهلاكها.",
  "KRIPTA.Notification.CardWrittenOff": "تمت إزالة البطاقة.",
  "KRIPTA.Notification.CannotUseMissingCard": "هذه البطاقة لم تعد مسجلة على الخادم. لا يمكن استخدامها.",
  "KRIPTA.Notification.MissingCard": "هذه البطاقة لم تعد مسجلة على الخادم.",
  "KRIPTA.Notification.PlayerNotSelected": "لم يتم اختيار لاعب لمنح البطاقة",
  "KRIPTA.Notification.PlayerBindingMissing": "تعذر تحديد ربط اللاعب لمنح البطاقة",
  "KRIPTA.Notification.RequestSent": "تم إرسال طلب البطاقة إلى الدردشة.",
  "KRIPTA.Notification.ServerSuccess": "تم الاتصال بنجاح.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "تم الاتصال بنجاح. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "تعذر الاتصال بالخادم. تحقق من العنوان وتوفر الخادم وإعدادات CORS/HTTPS.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "تعذر فحص الخادم.",
  "KRIPTA.Notification.InvalidServerUrl": "عنوان الخادم غير صالح: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "قسم إعدادات Kripta Cards متاح فقط لأدوار مدير اللعبة ومساعد مدير اللعبة.",
  "KRIPTA.Notification.ServerCheckFailed": "فشل فحص الخادم",
  "KRIPTA.Notification.TechUserReader": "Reader",
  "KRIPTA.Notification.TechUserWriter": "Writer",
  "KRIPTA.Notification.TechUsersCheckSuccess": "نجح فحص Reader و Writer.",
  "KRIPTA.Notification.SettingsSaved": "تم حفظ إعدادات الاتصال.",
  "KRIPTA.Notification.PlayerAdded": "تمت إضافة اللاعب.",
  "KRIPTA.Notification.PlayerUpdated": "تم تحديث اللاعب.",
  "KRIPTA.Notification.PlayerDeleted": "تم حذف اللاعب.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "تم إلغاء الحذف. تم ملء حقل التأكيد بشكل غير صحيح.",
  "KRIPTA.Notification.BindingSaved": "تم حفظ الربط.",
  "KRIPTA.Notification.BindingDeleted": "تمت إزالة الربط.",
  "KRIPTA.Notification.BadCatalogCardNumber": "البطاقة المختارة تحمل رقمًا غير صالح. تحقق من استجابة getCardsList و normalizeCardsList.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "لا يمكن منح هذه البطاقة يدويًا لأن رقمها غير صالح. تحقق من استجابة getCardsList و normalizeCardsList.",
  "KRIPTA.Notification.CardOutputFailed": "تعذر نشر البطاقة في الدردشة",
  "KRIPTA.Notification.CardGiveFailed": "تعذر منح البطاقة",
  "KRIPTA.Notification.CardUseFailed": "تعذر استخدام البطاقة",
  "KRIPTA.Notification.CardTakeFailed": "تعذرت إزالة البطاقة",
  "KRIPTA.Notification.CardRequestFailed": "تعذر إرسال طلب البطاقة",
  "KRIPTA.Notification.CardRequestConfirmFailed": "تعذر تأكيد منح البطاقة",
  "KRIPTA.Notification.PlayerAddFailed": "تعذرت إضافة اللاعب",
  "KRIPTA.Notification.PlayerUpdateFailed": "تعذر تحديث اللاعب",
  "KRIPTA.Notification.PlayerDeleteFailed": "تعذر حذف اللاعب",
  "KRIPTA.Notification.CardRollFailed": "تعذر الحصول على البطاقة.",
  "KRIPTA.Dialog.TakeCard.Title": "سحب بطاقة",
  "KRIPTA.Dialog.TakeCard.Message": "سيفقد اللاعب {playerName} البطاقة {cardName}.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "منح بطاقة"
}
__END_LOCALE_JSON__
