#!/usr/bin/env sh
set -eu

if [ ! -f "dmicher-kripta-cards/module.json" ]; then
  echo "Run this script from the Foundry module workspace root, next to dmicher-kripta-cards/module.json." >&2
  exit 1
fi

SCRIPT_FILE="$0"
LOCALE_PATH="dmicher-kripta-cards/lang/cs.json"
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
  "lang": "cs",
  "name": "Čeština",
  "path": "lang/cs.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "Váš účastník Foundry není v modulu Karty Krypty propojen s hráčem serveru. Obraťte se na pána hry.",
  "KRIPTA.GMOnly": "Tato akce je dostupná pouze pánovi hry.",
  "KRIPTA.Settings.ServerUrl.Name": "Adresa serveru",
  "KRIPTA.Settings.TechAuthUsers.Name": "Techničtí uživatelé",
  "KRIPTA.Settings.PlayerBindings.Name": "Propojení účastníků s hráči serveru",
  "KRIPTA.Settings.UiPrefs.Name": "Místní nastavení rozhraní",
  "KRIPTA.Settings.Menu.Name": "Karty Krypty",
  "KRIPTA.Settings.Menu.Label": "Nastavení modulu",
  "KRIPTA.Settings.Menu.Hint": "Připojení k API a techničtí uživatelé.",
  "KRIPTA.Settings.Help.BeforeServerLink": "Pokud jste ještě nenainstalovali a nenastavili server obsahu pro modul, přejděte na ",
  "KRIPTA.Settings.Help.ServerLink": "tento odkaz",
  "KRIPTA.Settings.Help.AfterServerLink": ", kde to můžete udělat. Pro rychlé nastavení použijte ",
  "KRIPTA.Settings.Help.DocumentationLink": "dokumentaci",
  "KRIPTA.Settings.Help.AfterDocumentationLink": ".",
  "KRIPTA.Window.Catalog": "Katalog karet",
  "KRIPTA.Window.CardDetails": "Karta katalogu",
  "KRIPTA.Window.GiveCard": "Vydat kartu",
  "KRIPTA.Window.MyCards": "Karty hráče",
  "KRIPTA.Window.Players": "Správa hráčů",
  "KRIPTA.Window.Registry": "Registr hráčů",
  "KRIPTA.Window.RequestCard": "Získat kartu",
  "KRIPTA.Window.Settings": "Karty Krypty - Nastavení",
  "KRIPTA.Window.UseCard": "Použít kartu",
  "KRIPTA.Menu.Title": "Karty Krypty",
  "KRIPTA.Menu.Catalog": "Katalog karet",
  "KRIPTA.Menu.GetCard": "Získat kartu",
  "KRIPTA.Menu.MyCards": "Moje karty",
  "KRIPTA.Menu.Players": "Správa hráčů",
  "KRIPTA.Label.Category": "Kategorie",
  "KRIPTA.Label.Mode": "Režim",
  "KRIPTA.Label.Card": "Karta",
  "KRIPTA.Label.Player": "Hráč",
  "KRIPTA.Label.Name": "Název",
  "KRIPTA.Label.Comment": "Komentář",
  "KRIPTA.Label.CardTypes": "Typy karet",
  "KRIPTA.Label.Count": "Počet",
  "KRIPTA.Label.ConfirmationCode": "Potvrzovací kód",
  "KRIPTA.Label.Id": "Identifikátor",
  "KRIPTA.Label.Key": "Klíč",
  "KRIPTA.Label.ServerUrl": "Cesta k serveru",
  "KRIPTA.Label.Writer": "Zapisovatel (Writer)",
  "KRIPTA.Label.Reader": "Čtenář (Reader)",
  "KRIPTA.Label.Role": "Role",
  "KRIPTA.Label.Binding": "Propojení",
  "KRIPTA.Role.GM": "Pán hry",
  "KRIPTA.Role.Player": "Hráč",
  "KRIPTA.Status.InGame": "ve hře",
  "KRIPTA.Status.Offline": "mimo hru",
  "KRIPTA.Binding.CardsIssued": "vydané karty:",
  "KRIPTA.Binding.NoCards": "žádné karty",
  "KRIPTA.Binding.NotBound": "hráč není propojen, vyberte hráče.",
  "KRIPTA.Binding.CardsCountHint": "Počet vydaných typů karet (bez opakovaných)",
  "KRIPTA.Button.Add": "Přidat",
  "KRIPTA.Button.Bind": "Propojit",
  "KRIPTA.Button.Cancel": "Zrušit",
  "KRIPTA.Button.Close": "Zavřít",
  "KRIPTA.Button.Confirm": "Potvrdit",
  "KRIPTA.Button.Delete": "Smazat",
  "KRIPTA.Button.Edit": "Upravit",
  "KRIPTA.Button.Give": "Vydat",
  "KRIPTA.Button.GiveCard": "Vydat kartu",
  "KRIPTA.Button.Info": "Informace",
  "KRIPTA.Button.No": "Ne",
  "KRIPTA.Button.Output": "Zobrazit",
  "KRIPTA.Button.Refresh": "Obnovit",
  "KRIPTA.Button.Registry": "Registr hráčů",
  "KRIPTA.Button.Request": "Požádat",
  "KRIPTA.Button.RequestCard": "Získat",
  "KRIPTA.Button.SaveChanges": "Uložit změny",
  "KRIPTA.Button.Take": "Odebrat",
  "KRIPTA.Button.TestAuth": "Zkontrolovat technické uživatele",
  "KRIPTA.Button.TestServer": "Zkontrolovat server",
  "KRIPTA.Button.Unbind": "Zrušit propojení",
  "KRIPTA.Button.Use": "Použít",
  "KRIPTA.Button.Yes": "Ano",
  "KRIPTA.Mode.Manual": "Na výběr",
  "KRIPTA.Mode.Random": "Náhodná",
  "KRIPTA.Mode.Show": "Zobrazit",
  "KRIPTA.Mode.Spend": "Utratit",
  "KRIPTA.View.Table": "Tabulka",
  "KRIPTA.View.Tiles": "Dlaždice",
  "KRIPTA.Placeholder.Search": "Hledat",
  "KRIPTA.Select.NotSelected": "-- není vybráno --",
  "KRIPTA.Template.EmptyCatalog": "Na serveru nejsou žádné registrované kategorie ani karty.",
  "KRIPTA.Template.MyCardsTitle": "Karty hráče: {playerName}",
  "KRIPTA.Template.UseCardMissing": "Tato karta již není registrována na serveru.",
  "KRIPTA.Template.UseCardPrompt": "Bude použita karta:",
  "KRIPTA.Card.FallbackName": "Karta {number}",
  "KRIPTA.Card.FallbackAddress": "Karta {level}/{number}",
  "KRIPTA.Card.MissingDescription": "Karta {level}/{number} chybí v aktuálním katalogu serveru.",
  "KRIPTA.Card.NotRegisteredDescription": "Karta {level}/{number} již není registrována na serveru.",
  "KRIPTA.Level.FallbackName": "Úroveň {level}",
  "KRIPTA.Level.MissingDescription": "Úroveň je v inventáři hráče, ale chybí v aktuálním katalogu serveru.",
  "KRIPTA.Chat.BlobReadFailed": "Nepodařilo se přečíst BLOB",
  "KRIPTA.Chat.CardGivenTitle": "Karta vydána",
  "KRIPTA.Chat.CardReceiveSubtitle": "Hráč {playerName} získává kartu {cardSubtitle}",
  "KRIPTA.Chat.CardRequestCanceled": "Žádost o kartu byla zrušena.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "Žádost o kartu potvrzena",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "Nepodařilo se přečíst data žádosti.",
  "KRIPTA.Chat.CardSpentFooter": "KARTA UTRACENA",
  "KRIPTA.Chat.CardSpentTitle": "Karta utracena",
  "KRIPTA.Chat.FallbackPlayer": "hráč",
  "KRIPTA.Chat.ManualChoiceFooter": "RUČNÍ VÝBĚR",
  "KRIPTA.Chat.ReferenceTitle": "Nápověda",
  "KRIPTA.Chat.RequestManualTitle": "Žádost o vybranou kartu",
  "KRIPTA.Chat.RequestRandomTitle": "Žádost o náhodnou kartu",
  "KRIPTA.Chat.ShowCardTitle": "Nápověda ke kartě",
  "KRIPTA.Dialog.BindPlayer.Title": "Propojit hráče serveru",
  "KRIPTA.Dialog.BindPlayer.Header": "Vybrat hráče pro {foundryUserName}",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "uživatele Foundry",
  "KRIPTA.Dialog.Player.AddTitle": "Přidat hráče",
  "KRIPTA.Dialog.Player.EditTitle": "Upravit hráče",
  "KRIPTA.Dialog.Player.DeleteTitle": "Smazat hráče",
  "KRIPTA.Dialog.Player.DeleteWarning": "Smazání hráče \"{playerName}\" je nevratné. Zadejte \"{code}\" a potvrďte smazání.",
  "KRIPTA.Dialog.Count.TotalCards": "celkem karet tohoto typu - {max}",
  "KRIPTA.Error.InvalidCardLevel": "Neplatný level pro {context}: {level}",
  "KRIPTA.Error.InvalidCardNumber": "Neplatný number pro {context}: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "neplatný level karty: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "neplatný number karty: {number}",
  "KRIPTA.Error.InvalidRequestCard": "Neplatná karta pro žádost",
  "KRIPTA.Error.InvalidGiveCard": "Neplatná karta pro vydání",
  "KRIPTA.Error.MissingRequestPlayerGuid": "Nepodařilo se určit playerGuid pro vydání karty.",
  "KRIPTA.Error.MissingSelectedCard": "Nepodařilo se určit vybranou kartu.",
  "KRIPTA.Error.MissingSelectedCardForGive": "Nepodařilo se určit vybranou kartu pro vydání.",
  "KRIPTA.Error.MissingGivePlayer": "Nepodařilo se určit hráče pro vydání karty.",
  "KRIPTA.Error.MissingGiveCard": "Nepodařilo se určit kartu pro vydání.",
  "KRIPTA.Error.MissingServerUrl": "Chybí nastavení cesty k serveru.",
  "KRIPTA.Error.InvalidReader": "Technický uživatel Reader je nastaven nesprávně.",
  "KRIPTA.Error.InvalidWriter": "Technický uživatel Writer je nastaven nesprávně.",
  "KRIPTA.Error.MenuUnavailable": "Funkce nefunguje. Zkontrolujte nastavení modulu. Podrobnosti jsou v konzoli prohlížeče.",
  "KRIPTA.Error.Generic": "Došlo k chybě",
  "KRIPTA.Error.Unknown": "neznámá chyba",
  "KRIPTA.Error.NameRequired": "Pole názvu je povinné.",
  "KRIPTA.Error.RegistryDeleteReturned": "server po smazání vrátil hráče do registru.",
  "KRIPTA.Notification.CardGiven": "Karta vydána.",
  "KRIPTA.Notification.CardUsed": "Karta byla použita a odepsána.",
  "KRIPTA.Notification.CardWrittenOff": "Karta odepsána.",
  "KRIPTA.Notification.CannotUseMissingCard": "Tato karta již není registrována na serveru. Použití není dostupné.",
  "KRIPTA.Notification.MissingCard": "Tato karta již není registrována na serveru.",
  "KRIPTA.Notification.PlayerNotSelected": "Není vybrán hráč pro vydání karty",
  "KRIPTA.Notification.PlayerBindingMissing": "Nepodařilo se určit propojení hráče pro vydání karty",
  "KRIPTA.Notification.RequestSent": "Žádost o kartu byla odeslána do chatu.",
  "KRIPTA.Notification.ServerSuccess": "Připojení úspěšné.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "Připojení úspěšné. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "Nepodařilo se připojit k serveru. Zkontrolujte adresu, dostupnost serveru a nastavení CORS/HTTPS.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "Nepodařilo se zkontrolovat server.",
  "KRIPTA.Notification.InvalidServerUrl": "Neplatná adresa serveru: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "Sekce nastavení „Karty Krypty“ je dostupná pouze rolím „Vedoucí“ a „Asistent vedoucího“.",
  "KRIPTA.Notification.ServerCheckFailed": "Kontrola serveru selhala",
  "KRIPTA.Notification.TechUserReader": "Čtenář",
  "KRIPTA.Notification.TechUserWriter": "Zapisovatel",
  "KRIPTA.Notification.TechUsersCheckSuccess": "Techničtí uživatelé \"Reader\" a \"Writer\" úspěšně procházejí kontrolou.",
  "KRIPTA.Notification.SettingsSaved": "Nastavení připojení uloženo.",
  "KRIPTA.Notification.PlayerAdded": "Hráč přidán.",
  "KRIPTA.Notification.PlayerUpdated": "Hráč aktualizován.",
  "KRIPTA.Notification.PlayerDeleted": "Hráč smazán.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "Smazání zrušeno. Kontrolní pole je vyplněno nesprávně.",
  "KRIPTA.Notification.BindingSaved": "Propojení uloženo.",
  "KRIPTA.Notification.BindingDeleted": "Propojení smazáno.",
  "KRIPTA.Notification.BadCatalogCardNumber": "Vybraná karta má neplatné číslo. Zkontrolujte odpověď getCardsList a normalizeCardsList.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "Tuto kartu nelze vydat ručně: má neplatné číslo. Zkontrolujte odpověď getCardsList a normalizeCardsList.",
  "KRIPTA.Notification.CardOutputFailed": "Nepodařilo se zobrazit kartu v chatu",
  "KRIPTA.Notification.CardGiveFailed": "Nepodařilo se vydat kartu",
  "KRIPTA.Notification.CardUseFailed": "Nepodařilo se použít kartu",
  "KRIPTA.Notification.CardTakeFailed": "Nepodařilo se odepsat kartu",
  "KRIPTA.Notification.CardRequestFailed": "Nepodařilo se odeslat žádost o kartu",
  "KRIPTA.Notification.CardRequestConfirmFailed": "Nepodařilo se potvrdit vydání karty",
  "KRIPTA.Notification.PlayerAddFailed": "Nepodařilo se přidat hráče",
  "KRIPTA.Notification.PlayerUpdateFailed": "Nepodařilo se aktualizovat hráče",
  "KRIPTA.Notification.PlayerDeleteFailed": "Nepodařilo se smazat hráče",
  "KRIPTA.Notification.CardRollFailed": "Nepodařilo se získat kartu.",
  "KRIPTA.Dialog.TakeCard.Title": "Odebrat kartu",
  "KRIPTA.Dialog.TakeCard.Message": "Hráč {playerName} přijde o kartu {cardName}.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Vydat kartu"
}
__END_LOCALE_JSON__
