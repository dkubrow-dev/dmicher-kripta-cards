#!/usr/bin/env sh
set -eu

if [ ! -f "dmicher-kripta-cards/module.json" ]; then
  echo "Run this script from the Foundry module workspace root, next to dmicher-kripta-cards/module.json." >&2
  exit 1
fi

SCRIPT_FILE="$0"
LOCALE_PATH="dmicher-kripta-cards/lang/ro-MD.json"
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
  "lang": "ro-MD",
  "name": "Română (Moldova)",
  "path": "lang/ro-MD.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "Utilizatorul Foundry nu este legat de un jucător de pe server în modulul Kripta Cards. Contactează Maestrul de Joc.",
  "KRIPTA.GMOnly": "Această acțiune este disponibilă doar pentru Maestrul de Joc.",
  "KRIPTA.Settings.ServerUrl.Name": "Adresa serverului",
  "KRIPTA.Settings.TechAuthUsers.Name": "Utilizatori tehnici",
  "KRIPTA.Settings.PlayerBindings.Name": "Legături între utilizatorii Foundry și jucătorii serverului",
  "KRIPTA.Settings.UiPrefs.Name": "Setări locale ale interfeței",
  "KRIPTA.Settings.Menu.Name": "Kripta Cards",
  "KRIPTA.Settings.Menu.Label": "Setările modulului",
  "KRIPTA.Settings.Menu.Hint": "Conexiune API și utilizatori tehnici.",
  "KRIPTA.Settings.Help.BeforeServerLink": "Dacă încă nu ați instalat și configurat serverul de conținut pentru modul, urmați ",
  "KRIPTA.Settings.Help.ServerLink": "acest link",
  "KRIPTA.Settings.Help.AfterServerLink": " pentru a face acest lucru. Pentru configurare rapidă, folosiți ",
  "KRIPTA.Settings.Help.DocumentationLink": "documentația",
  "KRIPTA.Settings.Help.AfterDocumentationLink": ".",
  "KRIPTA.Window.Catalog": "Catalog de cărți",
  "KRIPTA.Window.CardDetails": "Carte din catalog",
  "KRIPTA.Window.GiveCard": "Oferă carte",
  "KRIPTA.Window.MyCards": "Cărțile jucătorului",
  "KRIPTA.Window.Players": "Gestionare jucători",
  "KRIPTA.Window.Registry": "Registrul jucătorilor",
  "KRIPTA.Window.RequestCard": "Solicită carte",
  "KRIPTA.Window.Settings": "Kripta Cards - Setări",
  "KRIPTA.Window.UseCard": "Folosește cartea",
  "KRIPTA.Menu.Title": "Kripta Cards",
  "KRIPTA.Menu.Catalog": "Catalog de cărți",
  "KRIPTA.Menu.GetCard": "Solicită carte",
  "KRIPTA.Menu.MyCards": "Cărțile mele",
  "KRIPTA.Menu.Players": "Gestionare jucători",
  "KRIPTA.Label.Category": "Categorie",
  "KRIPTA.Label.Mode": "Mod",
  "KRIPTA.Label.Card": "Carte",
  "KRIPTA.Label.Player": "Jucător",
  "KRIPTA.Label.Name": "Nume",
  "KRIPTA.Label.Comment": "Comentariu",
  "KRIPTA.Label.CardTypes": "Tipuri de cărți",
  "KRIPTA.Label.Count": "Cantitate",
  "KRIPTA.Label.ConfirmationCode": "Cod de confirmare",
  "KRIPTA.Label.Id": "Id",
  "KRIPTA.Label.Key": "Key",
  "KRIPTA.Label.ServerUrl": "URL server",
  "KRIPTA.Label.Writer": "Writer",
  "KRIPTA.Label.Reader": "Reader",
  "KRIPTA.Label.Role": "Rol",
  "KRIPTA.Label.Binding": "Legătură",
  "KRIPTA.Role.GM": "Maestru de Joc",
  "KRIPTA.Role.Player": "Jucător",
  "KRIPTA.Status.InGame": "online",
  "KRIPTA.Status.Offline": "offline",
  "KRIPTA.Binding.CardsIssued": "cărți oferite:",
  "KRIPTA.Binding.NoCards": "fără cărți",
  "KRIPTA.Binding.NotBound": "jucătorul nu este legat, leagă un jucător.",
  "KRIPTA.Binding.CardsCountHint": "Numărul tipurilor de cărți oferite, fără duplicate",
  "KRIPTA.Button.Add": "Adaugă",
  "KRIPTA.Button.Bind": "Leagă",
  "KRIPTA.Button.Cancel": "Anulează",
  "KRIPTA.Button.Close": "Închide",
  "KRIPTA.Button.Confirm": "Confirmă",
  "KRIPTA.Button.Delete": "Șterge",
  "KRIPTA.Button.Edit": "Modifică",
  "KRIPTA.Button.Give": "Oferă",
  "KRIPTA.Button.GiveCard": "Oferă carte",
  "KRIPTA.Button.Info": "Info",
  "KRIPTA.Button.No": "Nu",
  "KRIPTA.Button.Output": "Publică",
  "KRIPTA.Button.Refresh": "Reîmprospătează",
  "KRIPTA.Button.Registry": "Registrul jucătorilor",
  "KRIPTA.Button.Request": "Solicită",
  "KRIPTA.Button.RequestCard": "Solicită",
  "KRIPTA.Button.SaveChanges": "Salvează modificările",
  "KRIPTA.Button.Take": "Ia",
  "KRIPTA.Button.TestAuth": "Verifică utilizatorii tehnici",
  "KRIPTA.Button.TestServer": "Verifică serverul",
  "KRIPTA.Button.Unbind": "Dezleagă",
  "KRIPTA.Button.Use": "Folosește",
  "KRIPTA.Button.Yes": "Da",
  "KRIPTA.Mode.Manual": "Alege manual",
  "KRIPTA.Mode.Random": "Aleator",
  "KRIPTA.Mode.Show": "Arată",
  "KRIPTA.Mode.Spend": "Consumă",
  "KRIPTA.View.Table": "Tabel",
  "KRIPTA.View.Tiles": "Dale",
  "KRIPTA.Placeholder.Search": "Caută",
  "KRIPTA.Select.NotSelected": "-- neselectat --",
  "KRIPTA.Template.EmptyCatalog": "Nu există categorii sau cărți înregistrate pe server.",
  "KRIPTA.Template.MyCardsTitle": "Cărțile jucătorului: {playerName}",
  "KRIPTA.Template.UseCardMissing": "Această carte nu mai este înregistrată pe server.",
  "KRIPTA.Template.UseCardPrompt": "Această carte va fi folosită:",
  "KRIPTA.Card.FallbackName": "Carte {number}",
  "KRIPTA.Card.FallbackAddress": "Carte {level}/{number}",
  "KRIPTA.Card.MissingDescription": "Cartea {level}/{number} lipsește din catalogul curent al serverului.",
  "KRIPTA.Card.NotRegisteredDescription": "Cartea {level}/{number} nu mai este înregistrată pe server.",
  "KRIPTA.Level.FallbackName": "Nivel {level}",
  "KRIPTA.Level.MissingDescription": "Acest nivel există în inventarul jucătorului, dar lipsește din catalogul curent al serverului.",
  "KRIPTA.Chat.BlobReadFailed": "Nu s-a putut citi blob",
  "KRIPTA.Chat.CardGivenTitle": "Carte oferită",
  "KRIPTA.Chat.CardReceiveSubtitle": "Jucătorul {playerName} primește cartea {cardSubtitle}",
  "KRIPTA.Chat.CardRequestCanceled": "Solicitarea de carte a fost anulată.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "Solicitare de carte confirmată",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "Nu s-au putut citi datele solicitării.",
  "KRIPTA.Chat.CardSpentFooter": "CARTE CONSUMATĂ",
  "KRIPTA.Chat.CardSpentTitle": "Carte consumată",
  "KRIPTA.Chat.FallbackPlayer": "jucător",
  "KRIPTA.Chat.ManualChoiceFooter": "ALEGERE MANUALĂ",
  "KRIPTA.Chat.ReferenceTitle": "Referință",
  "KRIPTA.Chat.RequestManualTitle": "Solicitare de carte aleasă",
  "KRIPTA.Chat.RequestRandomTitle": "Solicitare de carte aleatorie",
  "KRIPTA.Chat.ShowCardTitle": "Referință carte",
  "KRIPTA.Dialog.BindPlayer.Title": "Leagă jucătorul serverului",
  "KRIPTA.Dialog.BindPlayer.Header": "Alege un jucător pentru {foundryUserName}",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "utilizator Foundry",
  "KRIPTA.Dialog.Player.AddTitle": "Adaugă jucător",
  "KRIPTA.Dialog.Player.EditTitle": "Modifică jucător",
  "KRIPTA.Dialog.Player.DeleteTitle": "Șterge jucător",
  "KRIPTA.Dialog.Player.DeleteWarning": "Ștergerea jucătorului \"{playerName}\" nu poate fi anulată. Introdu \"{code}\" și confirmă ștergerea.",
  "KRIPTA.Dialog.Count.TotalCards": "număr total de cărți de acest tip - {max}",
  "KRIPTA.Error.InvalidCardLevel": "Nivel nevalid pentru {context}: {level}",
  "KRIPTA.Error.InvalidCardNumber": "Număr nevalid pentru {context}: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "nivel de carte nevalid: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "număr de carte nevalid: {number}",
  "KRIPTA.Error.InvalidRequestCard": "Carte nevalidă pentru solicitare",
  "KRIPTA.Error.InvalidGiveCard": "Carte nevalidă pentru oferire",
  "KRIPTA.Error.MissingRequestPlayerGuid": "Nu s-a putut determina playerGuid pentru oferirea cărții.",
  "KRIPTA.Error.MissingSelectedCard": "Nu s-a putut determina cartea selectată.",
  "KRIPTA.Error.MissingSelectedCardForGive": "Nu s-a putut determina cartea selectată pentru oferire.",
  "KRIPTA.Error.MissingGivePlayer": "Nu s-a putut determina jucătorul care primește cartea.",
  "KRIPTA.Error.MissingGiveCard": "Nu s-a putut determina cartea care trebuie oferită.",
  "KRIPTA.Error.MissingServerUrl": "Setarea căii serverului lipsește.",
  "KRIPTA.Error.InvalidReader": "Utilizatorul tehnic Reader este configurat incorect.",
  "KRIPTA.Error.InvalidWriter": "Utilizatorul tehnic Writer este configurat incorect.",
  "KRIPTA.Error.MenuUnavailable": "Această funcție nu este disponibilă. Verifică setările modulului. Detaliile sunt în consola browserului.",
  "KRIPTA.Error.Generic": "A apărut o eroare",
  "KRIPTA.Error.Unknown": "eroare necunoscută",
  "KRIPTA.Error.NameRequired": "Câmpul Name este obligatoriu.",
  "KRIPTA.Error.RegistryDeleteReturned": "serverul a returnat jucătorul în registru după ștergere.",
  "KRIPTA.Notification.CardGiven": "Carte oferită.",
  "KRIPTA.Notification.CardUsed": "Carte folosită și consumată.",
  "KRIPTA.Notification.CardWrittenOff": "Carte eliminată.",
  "KRIPTA.Notification.CannotUseMissingCard": "Această carte nu mai este înregistrată pe server. Nu poate fi folosită.",
  "KRIPTA.Notification.MissingCard": "Această carte nu mai este înregistrată pe server.",
  "KRIPTA.Notification.PlayerNotSelected": "Nu a fost selectat niciun jucător pentru oferirea cărții",
  "KRIPTA.Notification.PlayerBindingMissing": "Nu s-a putut determina legătura jucătorului pentru oferirea cărții",
  "KRIPTA.Notification.RequestSent": "Solicitarea de carte a fost trimisă în chat.",
  "KRIPTA.Notification.ServerSuccess": "Conexiune reușită.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "Conexiune reușită. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "Conectarea la server a eșuat. Verifică adresa, disponibilitatea serverului și setările CORS/HTTPS.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "Nu s-a putut verifica serverul.",
  "KRIPTA.Notification.InvalidServerUrl": "Adresă de server nevalidă: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "Secțiunea de setări Kripta Cards este disponibilă doar rolurilor Maestru de Joc și Asistent Maestru de Joc.",
  "KRIPTA.Notification.ServerCheckFailed": "Verificarea serverului a eșuat",
  "KRIPTA.Notification.TechUserReader": "Reader",
  "KRIPTA.Notification.TechUserWriter": "Writer",
  "KRIPTA.Notification.TechUsersCheckSuccess": "Utilizatorii tehnici \"Reader\" și \"Writer\" trec verificarea.",
  "KRIPTA.Notification.SettingsSaved": "Setările conexiunii au fost salvate.",
  "KRIPTA.Notification.PlayerAdded": "Jucător adăugat.",
  "KRIPTA.Notification.PlayerUpdated": "Jucător actualizat.",
  "KRIPTA.Notification.PlayerDeleted": "Jucător șters.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "Ștergere anulată. Câmpul de confirmare a fost completat incorect.",
  "KRIPTA.Notification.BindingSaved": "Legătură salvată.",
  "KRIPTA.Notification.BindingDeleted": "Legătură eliminată.",
  "KRIPTA.Notification.BadCatalogCardNumber": "Cartea selectată are un număr nevalid. Verifică răspunsul getCardsList și normalizeCardsList.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "Această carte nu poate fi oferită manual deoarece are un număr nevalid. Verifică răspunsul getCardsList și normalizeCardsList.",
  "KRIPTA.Notification.CardOutputFailed": "Nu s-a putut publica cartea în chat",
  "KRIPTA.Notification.CardGiveFailed": "Nu s-a putut oferi cartea",
  "KRIPTA.Notification.CardUseFailed": "Nu s-a putut folosi cartea",
  "KRIPTA.Notification.CardTakeFailed": "Nu s-a putut elimina cartea",
  "KRIPTA.Notification.CardRequestFailed": "Nu s-a putut trimite solicitarea de carte",
  "KRIPTA.Notification.CardRequestConfirmFailed": "Nu s-a putut confirma oferirea cărții",
  "KRIPTA.Notification.PlayerAddFailed": "Nu s-a putut adăuga jucătorul",
  "KRIPTA.Notification.PlayerUpdateFailed": "Nu s-a putut actualiza jucătorul",
  "KRIPTA.Notification.PlayerDeleteFailed": "Nu s-a putut șterge jucătorul",
  "KRIPTA.Notification.CardRollFailed": "Nu s-a putut primi cartea.",
  "KRIPTA.Dialog.TakeCard.Title": "Ia cartea",
  "KRIPTA.Dialog.TakeCard.Message": "Jucătorul {playerName} va pierde cartea {cardName}.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Oferă carte"
}
__END_LOCALE_JSON__
