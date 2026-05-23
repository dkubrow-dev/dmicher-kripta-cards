#!/usr/bin/env sh
set -eu

if [ ! -f "dmicher-kripta-cards/module.json" ]; then
  echo "Run this script from the Foundry module workspace root, next to dmicher-kripta-cards/module.json." >&2
  exit 1
fi

SCRIPT_FILE="$0"
LOCALE_PATH="dmicher-kripta-cards/lang/uz.json"
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
  "lang": "uz",
  "name": "Oʻzbekcha",
  "path": "lang/uz.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "Foundry foydalanuvchingiz Kripta Cards modulida server o'yinchisiga bog'lanmagan. Iltimos, O'yin Ustasiga murojaat qiling.",
  "KRIPTA.GMOnly": "Bu amal faqat O'yin Ustasi uchun mavjud.",
  "KRIPTA.Settings.ServerUrl.Name": "Server manzili",
  "KRIPTA.Settings.TechAuthUsers.Name": "Texnik foydalanuvchilar",
  "KRIPTA.Settings.PlayerBindings.Name": "Foundry foydalanuvchilarini server o'yinchilariga bog'lash",
  "KRIPTA.Settings.UiPrefs.Name": "Mahalliy interfeys sozlamalari",
  "KRIPTA.Settings.Menu.Name": "Kripta Cards",
  "KRIPTA.Settings.Menu.Label": "Modul sozlamalari",
  "KRIPTA.Settings.Menu.Hint": "API ulanishi va texnik foydalanuvchilar.",
  "KRIPTA.Settings.Help.BeforeServerLink": "Agar modul uchun kontent serverini hali o'rnatmagan va sozlamagan bo'lsangiz, buni qilish uchun ",
  "KRIPTA.Settings.Help.ServerLink": "ushbu havolaga",
  "KRIPTA.Settings.Help.AfterServerLink": " o'ting. Tez sozlash uchun ",
  "KRIPTA.Settings.Help.DocumentationLink": "hujjatlardan",
  "KRIPTA.Settings.Help.AfterDocumentationLink": " foydalaning.",
  "KRIPTA.Window.Catalog": "Kartalar katalogi",
  "KRIPTA.Window.CardDetails": "Katalog kartasi",
  "KRIPTA.Window.GiveCard": "Karta berish",
  "KRIPTA.Window.MyCards": "O'yinchi kartalari",
  "KRIPTA.Window.Players": "O'yinchilarni boshqarish",
  "KRIPTA.Window.Registry": "O'yinchilar reyestri",
  "KRIPTA.Window.RequestCard": "Karta so'rash",
  "KRIPTA.Window.Settings": "Kripta Cards - Sozlamalar",
  "KRIPTA.Window.UseCard": "Kartadan foydalanish",
  "KRIPTA.Menu.Title": "Kripta Cards",
  "KRIPTA.Menu.Catalog": "Kartalar katalogi",
  "KRIPTA.Menu.GetCard": "Karta so'rash",
  "KRIPTA.Menu.MyCards": "Mening kartalarim",
  "KRIPTA.Menu.Players": "O'yinchilarni boshqarish",
  "KRIPTA.Label.Category": "Toifa",
  "KRIPTA.Label.Mode": "Rejim",
  "KRIPTA.Label.Card": "Karta",
  "KRIPTA.Label.Player": "O'yinchi",
  "KRIPTA.Label.Name": "Ism",
  "KRIPTA.Label.Comment": "Izoh",
  "KRIPTA.Label.CardTypes": "Karta turlari",
  "KRIPTA.Label.Count": "Miqdor",
  "KRIPTA.Label.ConfirmationCode": "Tasdiqlash kodi",
  "KRIPTA.Label.Id": "Id",
  "KRIPTA.Label.Key": "Key",
  "KRIPTA.Label.ServerUrl": "Server URL",
  "KRIPTA.Label.Writer": "Writer",
  "KRIPTA.Label.Reader": "Reader",
  "KRIPTA.Label.Role": "Rol",
  "KRIPTA.Label.Binding": "Bog'lanish",
  "KRIPTA.Role.GM": "O'yin Ustasi",
  "KRIPTA.Role.Player": "O'yinchi",
  "KRIPTA.Status.InGame": "onlayn",
  "KRIPTA.Status.Offline": "oflayn",
  "KRIPTA.Binding.CardsIssued": "berilgan kartalar:",
  "KRIPTA.Binding.NoCards": "karta yo'q",
  "KRIPTA.Binding.NotBound": "o'yinchi bog'lanmagan, o'yinchini bog'lang.",
  "KRIPTA.Binding.CardsCountHint": "Takrorlarsiz berilgan karta turlari soni",
  "KRIPTA.Button.Add": "Qo'shish",
  "KRIPTA.Button.Bind": "Bog'lash",
  "KRIPTA.Button.Cancel": "Bekor qilish",
  "KRIPTA.Button.Close": "Yopish",
  "KRIPTA.Button.Confirm": "Tasdiqlash",
  "KRIPTA.Button.Delete": "O'chirish",
  "KRIPTA.Button.Edit": "Tahrirlash",
  "KRIPTA.Button.Give": "Berish",
  "KRIPTA.Button.GiveCard": "Karta berish",
  "KRIPTA.Button.Info": "Ma'lumot",
  "KRIPTA.Button.No": "Yo'q",
  "KRIPTA.Button.Output": "E'lon qilish",
  "KRIPTA.Button.Refresh": "Yangilash",
  "KRIPTA.Button.Registry": "O'yinchilar reyestri",
  "KRIPTA.Button.Request": "So'rash",
  "KRIPTA.Button.RequestCard": "So'rash",
  "KRIPTA.Button.SaveChanges": "O'zgarishlarni saqlash",
  "KRIPTA.Button.Take": "Olib qo'yish",
  "KRIPTA.Button.TestAuth": "Texnik foydalanuvchilarni tekshirish",
  "KRIPTA.Button.TestServer": "Serverni tekshirish",
  "KRIPTA.Button.Unbind": "Bog'lanishni uzish",
  "KRIPTA.Button.Use": "Foydalanish",
  "KRIPTA.Button.Yes": "Ha",
  "KRIPTA.Mode.Manual": "Qo'lda tanlash",
  "KRIPTA.Mode.Random": "Tasodifiy",
  "KRIPTA.Mode.Show": "Ko'rsatish",
  "KRIPTA.Mode.Spend": "Sarflash",
  "KRIPTA.View.Table": "Jadval",
  "KRIPTA.View.Tiles": "Plitkalar",
  "KRIPTA.Placeholder.Search": "Qidirish",
  "KRIPTA.Select.NotSelected": "-- tanlanmagan --",
  "KRIPTA.Template.EmptyCatalog": "Serverda ro'yxatdan o'tgan toifalar yoki kartalar yo'q.",
  "KRIPTA.Template.MyCardsTitle": "O'yinchi kartalari: {playerName}",
  "KRIPTA.Template.UseCardMissing": "Bu karta endi serverda ro'yxatdan o'tmagan.",
  "KRIPTA.Template.UseCardPrompt": "Ushbu karta ishlatiladi:",
  "KRIPTA.Card.FallbackName": "Karta {number}",
  "KRIPTA.Card.FallbackAddress": "Karta {level}/{number}",
  "KRIPTA.Card.MissingDescription": "Karta {level}/{number} joriy server katalogida yo'q.",
  "KRIPTA.Card.NotRegisteredDescription": "Karta {level}/{number} endi serverda ro'yxatdan o'tmagan.",
  "KRIPTA.Level.FallbackName": "Daraja {level}",
  "KRIPTA.Level.MissingDescription": "Bu daraja o'yinchi inventarida mavjud, lekin joriy server katalogida yo'q.",
  "KRIPTA.Chat.BlobReadFailed": "blob o'qib bo'lmadi",
  "KRIPTA.Chat.CardGivenTitle": "Karta berildi",
  "KRIPTA.Chat.CardReceiveSubtitle": "O'yinchi {playerName} {cardSubtitle} kartasini oladi",
  "KRIPTA.Chat.CardRequestCanceled": "Karta so'rovi bekor qilindi.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "Karta so'rovi tasdiqlandi",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "So'rov ma'lumotlarini o'qib bo'lmadi.",
  "KRIPTA.Chat.CardSpentFooter": "KARTA SARFLANDI",
  "KRIPTA.Chat.CardSpentTitle": "Karta sarflandi",
  "KRIPTA.Chat.FallbackPlayer": "o'yinchi",
  "KRIPTA.Chat.ManualChoiceFooter": "QO'LDA TANLASH",
  "KRIPTA.Chat.ReferenceTitle": "Ma'lumotnoma",
  "KRIPTA.Chat.RequestManualTitle": "Tanlangan karta so'rovi",
  "KRIPTA.Chat.RequestRandomTitle": "Tasodifiy karta so'rovi",
  "KRIPTA.Chat.ShowCardTitle": "Karta ma'lumotnomasi",
  "KRIPTA.Dialog.BindPlayer.Title": "Server o'yinchisini bog'lash",
  "KRIPTA.Dialog.BindPlayer.Header": "{foundryUserName} uchun o'yinchi tanlang",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "Foundry foydalanuvchisi",
  "KRIPTA.Dialog.Player.AddTitle": "O'yinchi qo'shish",
  "KRIPTA.Dialog.Player.EditTitle": "O'yinchini tahrirlash",
  "KRIPTA.Dialog.Player.DeleteTitle": "O'yinchini o'chirish",
  "KRIPTA.Dialog.Player.DeleteWarning": "\"{playerName}\" o'yinchisini o'chirishni qaytarib bo'lmaydi. \"{code}\" kiriting va o'chirishni tasdiqlang.",
  "KRIPTA.Dialog.Count.TotalCards": "ushbu turdagi jami kartalar - {max}",
  "KRIPTA.Error.InvalidCardLevel": "{context} uchun noto'g'ri daraja: {level}",
  "KRIPTA.Error.InvalidCardNumber": "{context} uchun noto'g'ri raqam: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "noto'g'ri karta darajasi: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "noto'g'ri karta raqami: {number}",
  "KRIPTA.Error.InvalidRequestCard": "So'rov uchun noto'g'ri karta",
  "KRIPTA.Error.InvalidGiveCard": "Berish uchun noto'g'ri karta",
  "KRIPTA.Error.MissingRequestPlayerGuid": "Karta berish uchun playerGuid aniqlanmadi.",
  "KRIPTA.Error.MissingSelectedCard": "Tanlangan karta aniqlanmadi.",
  "KRIPTA.Error.MissingSelectedCardForGive": "Berish uchun tanlangan karta aniqlanmadi.",
  "KRIPTA.Error.MissingGivePlayer": "Karta beriladigan o'yinchi aniqlanmadi.",
  "KRIPTA.Error.MissingGiveCard": "Beriladigan karta aniqlanmadi.",
  "KRIPTA.Error.MissingServerUrl": "Server yo'li sozlamasi yo'q.",
  "KRIPTA.Error.InvalidReader": "Reader texnik foydalanuvchisi noto'g'ri sozlangan.",
  "KRIPTA.Error.InvalidWriter": "Writer texnik foydalanuvchisi noto'g'ri sozlangan.",
  "KRIPTA.Error.MenuUnavailable": "Bu funksiya mavjud emas. Modul sozlamalarini tekshiring. Tafsilotlar brauzer konsolida.",
  "KRIPTA.Error.Generic": "Xatolik yuz berdi",
  "KRIPTA.Error.Unknown": "noma'lum xatolik",
  "KRIPTA.Error.NameRequired": "Name maydoni majburiy.",
  "KRIPTA.Error.RegistryDeleteReturned": "o'chirishdan keyin server o'yinchini reyestrda qaytardi.",
  "KRIPTA.Notification.CardGiven": "Karta berildi.",
  "KRIPTA.Notification.CardUsed": "Karta ishlatildi va sarflandi.",
  "KRIPTA.Notification.CardWrittenOff": "Karta olib tashlandi.",
  "KRIPTA.Notification.CannotUseMissingCard": "Bu karta endi serverda ro'yxatdan o'tmagan. Uni ishlatib bo'lmaydi.",
  "KRIPTA.Notification.MissingCard": "Bu karta endi serverda ro'yxatdan o'tmagan.",
  "KRIPTA.Notification.PlayerNotSelected": "Karta berish uchun o'yinchi tanlanmagan",
  "KRIPTA.Notification.PlayerBindingMissing": "Karta berish uchun o'yinchi bog'lanishi aniqlanmadi",
  "KRIPTA.Notification.RequestSent": "Karta so'rovi chatga yuborildi.",
  "KRIPTA.Notification.ServerSuccess": "Ulanish muvaffaqiyatli.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "Ulanish muvaffaqiyatli. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "Serverga ulanib bo'lmadi. Manzilni, server mavjudligini va CORS/HTTPS sozlamalarini tekshiring.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "Serverni tekshirib bo'lmadi.",
  "KRIPTA.Notification.InvalidServerUrl": "Noto'g'ri server manzili: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "Kripta Cards sozlamalari bo'limi faqat O'yin Ustasi va Yordamchi O'yin Ustasi rollari uchun mavjud.",
  "KRIPTA.Notification.ServerCheckFailed": "Server tekshiruvi muvaffaqiyatsiz",
  "KRIPTA.Notification.TechUserReader": "Reader",
  "KRIPTA.Notification.TechUserWriter": "Writer",
  "KRIPTA.Notification.TechUsersCheckSuccess": "\"Reader\" va \"Writer\" texnik foydalanuvchilari tekshiruvdan o'tdi.",
  "KRIPTA.Notification.SettingsSaved": "Ulanish sozlamalari saqlandi.",
  "KRIPTA.Notification.PlayerAdded": "O'yinchi qo'shildi.",
  "KRIPTA.Notification.PlayerUpdated": "O'yinchi yangilandi.",
  "KRIPTA.Notification.PlayerDeleted": "O'yinchi o'chirildi.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "O'chirish bekor qilindi. Tasdiqlash maydoni noto'g'ri to'ldirilgan.",
  "KRIPTA.Notification.BindingSaved": "Bog'lanish saqlandi.",
  "KRIPTA.Notification.BindingDeleted": "Bog'lanish olib tashlandi.",
  "KRIPTA.Notification.BadCatalogCardNumber": "Tanlangan kartaning raqami noto'g'ri. getCardsList javobini va normalizeCardsList-ni tekshiring.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "Bu kartani qo'lda berib bo'lmaydi, chunki raqami noto'g'ri. getCardsList javobini va normalizeCardsList-ni tekshiring.",
  "KRIPTA.Notification.CardOutputFailed": "Kartani chatga joylab bo'lmadi",
  "KRIPTA.Notification.CardGiveFailed": "Karta berib bo'lmadi",
  "KRIPTA.Notification.CardUseFailed": "Kartadan foydalanib bo'lmadi",
  "KRIPTA.Notification.CardTakeFailed": "Kartani olib tashlab bo'lmadi",
  "KRIPTA.Notification.CardRequestFailed": "Karta so'rovi yuborilmadi",
  "KRIPTA.Notification.CardRequestConfirmFailed": "Karta berishni tasdiqlab bo'lmadi",
  "KRIPTA.Notification.PlayerAddFailed": "O'yinchi qo'shib bo'lmadi",
  "KRIPTA.Notification.PlayerUpdateFailed": "O'yinchini yangilab bo'lmadi",
  "KRIPTA.Notification.PlayerDeleteFailed": "O'yinchini o'chirib bo'lmadi",
  "KRIPTA.Notification.CardRollFailed": "Karta olib bo'lmadi.",
  "KRIPTA.Dialog.TakeCard.Title": "Kartani olib qo'yish",
  "KRIPTA.Dialog.TakeCard.Message": "O'yinchi {playerName} {cardName} kartasini yo'qotadi.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Karta berish"
}
__END_LOCALE_JSON__
