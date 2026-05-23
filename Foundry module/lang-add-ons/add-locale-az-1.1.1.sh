#!/usr/bin/env sh
set -eu

if [ ! -f "dmicher-kripta-cards/module.json" ]; then
  echo "Run this script from the Foundry module workspace root, next to dmicher-kripta-cards/module.json." >&2
  exit 1
fi

SCRIPT_FILE="$0"
LOCALE_PATH="dmicher-kripta-cards/lang/az.json"
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
  "lang": "az",
  "name": "Azərbaycanca",
  "path": "lang/az.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "Foundry istifadəçiniz Kripta Cards modulunda server oyunçusu ilə əlaqələndirilməyib. Zəhmət olmasa Oyun Ustası ilə əlaqə saxlayın.",
  "KRIPTA.GMOnly": "Bu əməliyyat yalnız Oyun Ustası üçün əlçatandır.",
  "KRIPTA.Settings.ServerUrl.Name": "Server ünvanı",
  "KRIPTA.Settings.TechAuthUsers.Name": "Texniki istifadəçilər",
  "KRIPTA.Settings.PlayerBindings.Name": "Foundry istifadəçilərinin server oyunçularına bağlanması",
  "KRIPTA.Settings.UiPrefs.Name": "Lokal interfeys parametrləri",
  "KRIPTA.Settings.Menu.Name": "Kripta Cards",
  "KRIPTA.Settings.Menu.Label": "Modul parametrləri",
  "KRIPTA.Settings.Menu.Hint": "API bağlantısı və texniki istifadəçilər.",
  "KRIPTA.Settings.Help.BeforeServerLink": "Əgər modul üçün məzmun serverini hələ quraşdırmamısınız və sazlamamısınızsa, bunu etmək üçün ",
  "KRIPTA.Settings.Help.ServerLink": "bu keçidə",
  "KRIPTA.Settings.Help.AfterServerLink": " keçin. Tez sazlama üçün ",
  "KRIPTA.Settings.Help.DocumentationLink": "sənədlərdən",
  "KRIPTA.Settings.Help.AfterDocumentationLink": " istifadə edin.",
  "KRIPTA.Window.Catalog": "Kart kataloqu",
  "KRIPTA.Window.CardDetails": "Kataloq kartı",
  "KRIPTA.Window.GiveCard": "Kart ver",
  "KRIPTA.Window.MyCards": "Oyunçunun kartları",
  "KRIPTA.Window.Players": "Oyunçuları idarə et",
  "KRIPTA.Window.Registry": "Oyunçu reyestri",
  "KRIPTA.Window.RequestCard": "Kart istə",
  "KRIPTA.Window.Settings": "Kripta Cards - Parametrlər",
  "KRIPTA.Window.UseCard": "Kartdan istifadə et",
  "KRIPTA.Menu.Title": "Kripta Cards",
  "KRIPTA.Menu.Catalog": "Kart kataloqu",
  "KRIPTA.Menu.GetCard": "Kart istə",
  "KRIPTA.Menu.MyCards": "Mənim kartlarım",
  "KRIPTA.Menu.Players": "Oyunçuları idarə et",
  "KRIPTA.Label.Category": "Kateqoriya",
  "KRIPTA.Label.Mode": "Rejim",
  "KRIPTA.Label.Card": "Kart",
  "KRIPTA.Label.Player": "Oyunçu",
  "KRIPTA.Label.Name": "Ad",
  "KRIPTA.Label.Comment": "Şərh",
  "KRIPTA.Label.CardTypes": "Kart növləri",
  "KRIPTA.Label.Count": "Say",
  "KRIPTA.Label.ConfirmationCode": "Təsdiq kodu",
  "KRIPTA.Label.Id": "Id",
  "KRIPTA.Label.Key": "Key",
  "KRIPTA.Label.ServerUrl": "Server URL",
  "KRIPTA.Label.Writer": "Writer",
  "KRIPTA.Label.Reader": "Reader",
  "KRIPTA.Label.Role": "Rol",
  "KRIPTA.Label.Binding": "Bağlantı",
  "KRIPTA.Role.GM": "Oyun Ustası",
  "KRIPTA.Role.Player": "Oyunçu",
  "KRIPTA.Status.InGame": "onlayn",
  "KRIPTA.Status.Offline": "oflayn",
  "KRIPTA.Binding.CardsIssued": "verilmiş kartlar:",
  "KRIPTA.Binding.NoCards": "kart yoxdur",
  "KRIPTA.Binding.NotBound": "oyunçu bağlı deyil, oyunçunu bağlayın.",
  "KRIPTA.Binding.CardsCountHint": "Təkrarlar nəzərə alınmadan verilmiş kart növlərinin sayı",
  "KRIPTA.Button.Add": "Əlavə et",
  "KRIPTA.Button.Bind": "Bağla",
  "KRIPTA.Button.Cancel": "Ləğv et",
  "KRIPTA.Button.Close": "Bağla",
  "KRIPTA.Button.Confirm": "Təsdiqlə",
  "KRIPTA.Button.Delete": "Sil",
  "KRIPTA.Button.Edit": "Dəyiş",
  "KRIPTA.Button.Give": "Ver",
  "KRIPTA.Button.GiveCard": "Kart ver",
  "KRIPTA.Button.Info": "Məlumat",
  "KRIPTA.Button.No": "Xeyr",
  "KRIPTA.Button.Output": "Paylaş",
  "KRIPTA.Button.Refresh": "Yenilə",
  "KRIPTA.Button.Registry": "Oyunçu reyestri",
  "KRIPTA.Button.Request": "İstə",
  "KRIPTA.Button.RequestCard": "İstə",
  "KRIPTA.Button.SaveChanges": "Dəyişiklikləri saxla",
  "KRIPTA.Button.Take": "Geri al",
  "KRIPTA.Button.TestAuth": "Texniki istifadəçiləri yoxla",
  "KRIPTA.Button.TestServer": "Serveri yoxla",
  "KRIPTA.Button.Unbind": "Bağlantını ləğv et",
  "KRIPTA.Button.Use": "İstifadə et",
  "KRIPTA.Button.Yes": "Bəli",
  "KRIPTA.Mode.Manual": "Əl ilə seç",
  "KRIPTA.Mode.Random": "Təsadüfi",
  "KRIPTA.Mode.Show": "Göstər",
  "KRIPTA.Mode.Spend": "Xərclə",
  "KRIPTA.View.Table": "Cədvəl",
  "KRIPTA.View.Tiles": "Plitələr",
  "KRIPTA.Placeholder.Search": "Axtar",
  "KRIPTA.Select.NotSelected": "-- seçilməyib --",
  "KRIPTA.Template.EmptyCatalog": "Serverdə qeydiyyatdan keçmiş kateqoriya və ya kart yoxdur.",
  "KRIPTA.Template.MyCardsTitle": "Oyunçunun kartları: {playerName}",
  "KRIPTA.Template.UseCardMissing": "Bu kart artıq serverdə qeydiyyatda deyil.",
  "KRIPTA.Template.UseCardPrompt": "Bu kart istifadə olunacaq:",
  "KRIPTA.Card.FallbackName": "Kart {number}",
  "KRIPTA.Card.FallbackAddress": "Kart {level}/{number}",
  "KRIPTA.Card.MissingDescription": "Kart {level}/{number} cari server kataloqunda yoxdur.",
  "KRIPTA.Card.NotRegisteredDescription": "Kart {level}/{number} artıq serverdə qeydiyyatda deyil.",
  "KRIPTA.Level.FallbackName": "Səviyyə {level}",
  "KRIPTA.Level.MissingDescription": "Bu səviyyə oyunçunun inventarında var, lakin cari server kataloqunda yoxdur.",
  "KRIPTA.Chat.BlobReadFailed": "blob oxunmadı",
  "KRIPTA.Chat.CardGivenTitle": "Kart verildi",
  "KRIPTA.Chat.CardReceiveSubtitle": "Oyunçu {playerName} {cardSubtitle} kartını alır",
  "KRIPTA.Chat.CardRequestCanceled": "Kart sorğusu ləğv edildi.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "Kart sorğusu təsdiqləndi",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "Sorğu məlumatları oxunmadı.",
  "KRIPTA.Chat.CardSpentFooter": "KART XƏRCLƏNDİ",
  "KRIPTA.Chat.CardSpentTitle": "Kart xərcləndi",
  "KRIPTA.Chat.FallbackPlayer": "oyunçu",
  "KRIPTA.Chat.ManualChoiceFooter": "ƏL İLƏ SEÇİM",
  "KRIPTA.Chat.ReferenceTitle": "Arayış",
  "KRIPTA.Chat.RequestManualTitle": "Seçilmiş kart sorğusu",
  "KRIPTA.Chat.RequestRandomTitle": "Təsadüfi kart sorğusu",
  "KRIPTA.Chat.ShowCardTitle": "Kart arayışı",
  "KRIPTA.Dialog.BindPlayer.Title": "Server oyunçusunu bağla",
  "KRIPTA.Dialog.BindPlayer.Header": "{foundryUserName} üçün oyunçu seç",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "Foundry istifadəçisi",
  "KRIPTA.Dialog.Player.AddTitle": "Oyunçu əlavə et",
  "KRIPTA.Dialog.Player.EditTitle": "Oyunçunu dəyiş",
  "KRIPTA.Dialog.Player.DeleteTitle": "Oyunçunu sil",
  "KRIPTA.Dialog.Player.DeleteWarning": "\"{playerName}\" oyunçusunun silinməsi geri qaytarıla bilməz. \"{code}\" daxil edin və silməni təsdiqləyin.",
  "KRIPTA.Dialog.Count.TotalCards": "bu növdən ümumi kart sayı - {max}",
  "KRIPTA.Error.InvalidCardLevel": "{context} üçün səhv səviyyə: {level}",
  "KRIPTA.Error.InvalidCardNumber": "{context} üçün səhv nömrə: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "səhv kart səviyyəsi: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "səhv kart nömrəsi: {number}",
  "KRIPTA.Error.InvalidRequestCard": "Sorğu üçün səhv kart",
  "KRIPTA.Error.InvalidGiveCard": "Vermək üçün səhv kart",
  "KRIPTA.Error.MissingRequestPlayerGuid": "Kart vermək üçün playerGuid müəyyən edilmədi.",
  "KRIPTA.Error.MissingSelectedCard": "Seçilmiş kart müəyyən edilmədi.",
  "KRIPTA.Error.MissingSelectedCardForGive": "Vermək üçün seçilmiş kart müəyyən edilmədi.",
  "KRIPTA.Error.MissingGivePlayer": "Kart veriləcək oyunçu müəyyən edilmədi.",
  "KRIPTA.Error.MissingGiveCard": "Veriləcək kart müəyyən edilmədi.",
  "KRIPTA.Error.MissingServerUrl": "Server yolu parametri yoxdur.",
  "KRIPTA.Error.InvalidReader": "Reader texniki istifadəçisi səhv konfiqurasiya olunub.",
  "KRIPTA.Error.InvalidWriter": "Writer texniki istifadəçisi səhv konfiqurasiya olunub.",
  "KRIPTA.Error.MenuUnavailable": "Bu funksiya əlçatan deyil. Modul parametrlərini yoxlayın. Təfərrüatlar brauzer konsolundadır.",
  "KRIPTA.Error.Generic": "Xəta baş verdi",
  "KRIPTA.Error.Unknown": "naməlum xəta",
  "KRIPTA.Error.NameRequired": "Name sahəsi mütləqdir.",
  "KRIPTA.Error.RegistryDeleteReturned": "silinmədən sonra server oyunçunu reyestrdə qaytardı.",
  "KRIPTA.Notification.CardGiven": "Kart verildi.",
  "KRIPTA.Notification.CardUsed": "Kart istifadə edildi və xərcləndi.",
  "KRIPTA.Notification.CardWrittenOff": "Kart silindi.",
  "KRIPTA.Notification.CannotUseMissingCard": "Bu kart artıq serverdə qeydiyyatda deyil. Ondan istifadə etmək olmaz.",
  "KRIPTA.Notification.MissingCard": "Bu kart artıq serverdə qeydiyyatda deyil.",
  "KRIPTA.Notification.PlayerNotSelected": "Kart vermək üçün oyunçu seçilməyib",
  "KRIPTA.Notification.PlayerBindingMissing": "Kart vermək üçün oyunçu bağlantısı müəyyən edilmədi",
  "KRIPTA.Notification.RequestSent": "Kart sorğusu çata göndərildi.",
  "KRIPTA.Notification.ServerSuccess": "Bağlantı uğurludur.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "Bağlantı uğurludur. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "Serverə qoşulmaq alınmadı. Ünvanı, serverin əlçatanlığını və CORS/HTTPS parametrlərini yoxlayın.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "Server yoxlanmadı.",
  "KRIPTA.Notification.InvalidServerUrl": "Səhv server ünvanı: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "Kripta Cards parametrləri yalnız Oyun Ustası və Oyun Ustasının Köməkçisi rolları üçün əlçatandır.",
  "KRIPTA.Notification.ServerCheckFailed": "Server yoxlaması uğursuz oldu",
  "KRIPTA.Notification.TechUserReader": "Reader",
  "KRIPTA.Notification.TechUserWriter": "Writer",
  "KRIPTA.Notification.TechUsersCheckSuccess": "\"Reader\" və \"Writer\" texniki istifadəçiləri yoxlamadan keçdi.",
  "KRIPTA.Notification.SettingsSaved": "Bağlantı parametrləri saxlandı.",
  "KRIPTA.Notification.PlayerAdded": "Oyunçu əlavə edildi.",
  "KRIPTA.Notification.PlayerUpdated": "Oyunçu yeniləndi.",
  "KRIPTA.Notification.PlayerDeleted": "Oyunçu silindi.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "Silmə ləğv edildi. Təsdiq sahəsi səhv doldurulub.",
  "KRIPTA.Notification.BindingSaved": "Bağlantı saxlandı.",
  "KRIPTA.Notification.BindingDeleted": "Bağlantı silindi.",
  "KRIPTA.Notification.BadCatalogCardNumber": "Seçilmiş kartın nömrəsi səhvdir. getCardsList cavabını və normalizeCardsList-i yoxlayın.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "Bu kartı əl ilə vermək olmaz, çünki nömrəsi səhvdir. getCardsList cavabını və normalizeCardsList-i yoxlayın.",
  "KRIPTA.Notification.CardOutputFailed": "Kartı çata paylaşmaq alınmadı",
  "KRIPTA.Notification.CardGiveFailed": "Kart vermək alınmadı",
  "KRIPTA.Notification.CardUseFailed": "Kartdan istifadə etmək alınmadı",
  "KRIPTA.Notification.CardTakeFailed": "Kartı silmək alınmadı",
  "KRIPTA.Notification.CardRequestFailed": "Kart sorğusu göndərilmədi",
  "KRIPTA.Notification.CardRequestConfirmFailed": "Kart verilməsini təsdiqləmək alınmadı",
  "KRIPTA.Notification.PlayerAddFailed": "Oyunçu əlavə etmək alınmadı",
  "KRIPTA.Notification.PlayerUpdateFailed": "Oyunçunu yeniləmək alınmadı",
  "KRIPTA.Notification.PlayerDeleteFailed": "Oyunçunu silmək alınmadı",
  "KRIPTA.Notification.CardRollFailed": "Kart almaq alınmadı.",
  "KRIPTA.Dialog.TakeCard.Title": "Kartı geri al",
  "KRIPTA.Dialog.TakeCard.Message": "Oyunçu {playerName} {cardName} kartını itirəcək.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Kart ver"
}
__END_LOCALE_JSON__
