#!/usr/bin/env sh
set -eu

if [ ! -f "dmicher-kripta-cards/module.json" ]; then
  echo "Run this script from the Foundry module workspace root, next to dmicher-kripta-cards/module.json." >&2
  exit 1
fi

SCRIPT_FILE="$0"
LOCALE_PATH="dmicher-kripta-cards/lang/pl.json"
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
  "lang": "pl",
  "name": "Polski",
  "path": "lang/pl.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "Twój uczestnik Foundry nie jest powiązany z graczem serwera w module Karty Krypty. Skontaktuj się z mistrzem gry.",
  "KRIPTA.GMOnly": "Ta akcja jest dostępna tylko dla mistrza gry.",
  "KRIPTA.Settings.ServerUrl.Name": "Adres serwera",
  "KRIPTA.Settings.TechAuthUsers.Name": "Użytkownicy techniczni",
  "KRIPTA.Settings.PlayerBindings.Name": "Powiązania uczestników z graczami serwera",
  "KRIPTA.Settings.UiPrefs.Name": "Lokalne ustawienia interfejsu",
  "KRIPTA.Settings.Menu.Name": "Karty Krypty",
  "KRIPTA.Settings.Menu.Label": "Konfiguracja modułu",
  "KRIPTA.Settings.Menu.Hint": "Połączenie z API i użytkownicy techniczni.",
  "KRIPTA.Settings.Help.BeforeServerLink": "Jeśli serwer treści modułu nie został jeszcze zainstalowany i skonfigurowany, przejdź pod ",
  "KRIPTA.Settings.Help.ServerLink": "ten link",
  "KRIPTA.Settings.Help.AfterServerLink": ", aby to zrobić. Do szybkiej konfiguracji użyj ",
  "KRIPTA.Settings.Help.DocumentationLink": "dokumentacji",
  "KRIPTA.Settings.Help.AfterDocumentationLink": ".",
  "KRIPTA.Window.Catalog": "Katalog kart",
  "KRIPTA.Window.CardDetails": "Karta katalogu",
  "KRIPTA.Window.GiveCard": "Wydaj kartę",
  "KRIPTA.Window.MyCards": "Karty gracza",
  "KRIPTA.Window.Players": "Zarządzanie graczami",
  "KRIPTA.Window.Registry": "Rejestr graczy",
  "KRIPTA.Window.RequestCard": "Otrzymaj kartę",
  "KRIPTA.Window.Settings": "Karty Krypty - Ustawienia",
  "KRIPTA.Window.UseCard": "Użyj karty",
  "KRIPTA.Menu.Title": "Karty Krypty",
  "KRIPTA.Menu.Catalog": "Katalog kart",
  "KRIPTA.Menu.GetCard": "Otrzymaj kartę",
  "KRIPTA.Menu.MyCards": "Moje karty",
  "KRIPTA.Menu.Players": "Zarządzanie graczami",
  "KRIPTA.Label.Category": "Kategoria",
  "KRIPTA.Label.Mode": "Tryb",
  "KRIPTA.Label.Card": "Karta",
  "KRIPTA.Label.Player": "Gracz",
  "KRIPTA.Label.Name": "Nazwa",
  "KRIPTA.Label.Comment": "Komentarz",
  "KRIPTA.Label.CardTypes": "Typy kart",
  "KRIPTA.Label.Count": "Liczba",
  "KRIPTA.Label.ConfirmationCode": "Kod potwierdzenia",
  "KRIPTA.Label.Id": "Identyfikator",
  "KRIPTA.Label.Key": "Klucz",
  "KRIPTA.Label.ServerUrl": "Ścieżka do serwera",
  "KRIPTA.Label.Writer": "Pisarz (Writer)",
  "KRIPTA.Label.Reader": "Czytelnik (Reader)",
  "KRIPTA.Label.Role": "Rola",
  "KRIPTA.Label.Binding": "Powiązanie",
  "KRIPTA.Role.GM": "Mistrz gry",
  "KRIPTA.Role.Player": "Gracz",
  "KRIPTA.Status.InGame": "w grze",
  "KRIPTA.Status.Offline": "poza grą",
  "KRIPTA.Binding.CardsIssued": "wydane karty:",
  "KRIPTA.Binding.NoCards": "brak kart",
  "KRIPTA.Binding.NotBound": "gracz nie jest powiązany, wybierz gracza.",
  "KRIPTA.Binding.CardsCountHint": "Liczba wydanych typów kart (bez duplikatów)",
  "KRIPTA.Button.Add": "Dodaj",
  "KRIPTA.Button.Bind": "Powiąż",
  "KRIPTA.Button.Cancel": "Anuluj",
  "KRIPTA.Button.Close": "Zamknij",
  "KRIPTA.Button.Confirm": "Potwierdź",
  "KRIPTA.Button.Delete": "Usuń",
  "KRIPTA.Button.Edit": "Zmień",
  "KRIPTA.Button.Give": "Wydaj",
  "KRIPTA.Button.GiveCard": "Wydaj kartę",
  "KRIPTA.Button.Info": "Informacje",
  "KRIPTA.Button.No": "Nie",
  "KRIPTA.Button.Output": "Pokaż",
  "KRIPTA.Button.Refresh": "Odśwież",
  "KRIPTA.Button.Registry": "Rejestr graczy",
  "KRIPTA.Button.Request": "Poproś",
  "KRIPTA.Button.RequestCard": "Otrzymaj",
  "KRIPTA.Button.SaveChanges": "Zapisz zmiany",
  "KRIPTA.Button.Take": "Zabierz",
  "KRIPTA.Button.TestAuth": "Sprawdź użytkowników technicznych",
  "KRIPTA.Button.TestServer": "Sprawdź serwer",
  "KRIPTA.Button.Unbind": "Usuń powiązanie",
  "KRIPTA.Button.Use": "Użyj",
  "KRIPTA.Button.Yes": "Tak",
  "KRIPTA.Mode.Manual": "Do wyboru",
  "KRIPTA.Mode.Random": "Losowa",
  "KRIPTA.Mode.Show": "Pokaż",
  "KRIPTA.Mode.Spend": "Wydaj",
  "KRIPTA.View.Table": "Tabela",
  "KRIPTA.View.Tiles": "Kafelki",
  "KRIPTA.Placeholder.Search": "Szukaj",
  "KRIPTA.Select.NotSelected": "-- nie wybrano --",
  "KRIPTA.Template.EmptyCatalog": "Na serwerze nie ma zarejestrowanych kategorii ani kart.",
  "KRIPTA.Template.MyCardsTitle": "Karty gracza: {playerName}",
  "KRIPTA.Template.UseCardMissing": "Ta karta nie jest już zarejestrowana na serwerze.",
  "KRIPTA.Template.UseCardPrompt": "Zostanie użyta karta:",
  "KRIPTA.Card.FallbackName": "Karta {number}",
  "KRIPTA.Card.FallbackAddress": "Karta {level}/{number}",
  "KRIPTA.Card.MissingDescription": "Karty {level}/{number} nie ma w bieżącym katalogu serwera.",
  "KRIPTA.Card.NotRegisteredDescription": "Karta {level}/{number} nie jest już zarejestrowana na serwerze.",
  "KRIPTA.Level.FallbackName": "Poziom {level}",
  "KRIPTA.Level.MissingDescription": "Poziom znajduje się w ekwipunku gracza, ale nie ma go w bieżącym katalogu serwera.",
  "KRIPTA.Chat.BlobReadFailed": "Nie udało się odczytać BLOB",
  "KRIPTA.Chat.CardGivenTitle": "Karta została wydana",
  "KRIPTA.Chat.CardReceiveSubtitle": "Gracz {playerName} otrzymuje kartę {cardSubtitle}",
  "KRIPTA.Chat.CardRequestCanceled": "Prośba o kartę została anulowana.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "Prośba o kartę została potwierdzona",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "Nie udało się odczytać danych prośby.",
  "KRIPTA.Chat.CardSpentFooter": "KARTA WYDANA",
  "KRIPTA.Chat.CardSpentTitle": "Karta wydana",
  "KRIPTA.Chat.FallbackPlayer": "gracz",
  "KRIPTA.Chat.ManualChoiceFooter": "WYBÓR RĘCZNY",
  "KRIPTA.Chat.ReferenceTitle": "Pomoc",
  "KRIPTA.Chat.RequestManualTitle": "Prośba o wybraną kartę",
  "KRIPTA.Chat.RequestRandomTitle": "Prośba o losową kartę",
  "KRIPTA.Chat.ShowCardTitle": "Informacje o karcie",
  "KRIPTA.Dialog.BindPlayer.Title": "Powiąż gracza serwera",
  "KRIPTA.Dialog.BindPlayer.Header": "Wybierz gracza dla {foundryUserName}",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "użytkownika Foundry",
  "KRIPTA.Dialog.Player.AddTitle": "Dodaj gracza",
  "KRIPTA.Dialog.Player.EditTitle": "Zmień gracza",
  "KRIPTA.Dialog.Player.DeleteTitle": "Usuń gracza",
  "KRIPTA.Dialog.Player.DeleteWarning": "Usunięcie gracza \"{playerName}\" jest nieodwracalne. Wpisz \"{code}\" i potwierdź usunięcie.",
  "KRIPTA.Dialog.Count.TotalCards": "łącznie kart tego typu - {max}",
  "KRIPTA.Error.InvalidCardLevel": "Nieprawidłowy level dla {context}: {level}",
  "KRIPTA.Error.InvalidCardNumber": "Nieprawidłowy number dla {context}: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "nieprawidłowy level karty: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "nieprawidłowy number karty: {number}",
  "KRIPTA.Error.InvalidRequestCard": "Nieprawidłowa karta do prośby",
  "KRIPTA.Error.InvalidGiveCard": "Nieprawidłowa karta do wydania",
  "KRIPTA.Error.MissingRequestPlayerGuid": "Nie udało się określić playerGuid do wydania karty.",
  "KRIPTA.Error.MissingSelectedCard": "Nie udało się określić wybranej karty.",
  "KRIPTA.Error.MissingSelectedCardForGive": "Nie udało się określić wybranej karty do wydania.",
  "KRIPTA.Error.MissingGivePlayer": "Nie udało się określić gracza do wydania karty.",
  "KRIPTA.Error.MissingGiveCard": "Nie udało się określić karty do wydania.",
  "KRIPTA.Error.MissingServerUrl": "Brak ustawienia ścieżki do serwera.",
  "KRIPTA.Error.InvalidReader": "Użytkownik techniczny Reader jest skonfigurowany nieprawidłowo.",
  "KRIPTA.Error.InvalidWriter": "Użytkownik techniczny Writer jest skonfigurowany nieprawidłowo.",
  "KRIPTA.Error.MenuUnavailable": "Funkcja nie działa. Sprawdź ustawienia modułu. Szczegóły w konsoli przeglądarki.",
  "KRIPTA.Error.Generic": "Wystąpił błąd",
  "KRIPTA.Error.Unknown": "nieznany błąd",
  "KRIPTA.Error.NameRequired": "Pole nazwy jest wymagane.",
  "KRIPTA.Error.RegistryDeleteReturned": "serwer zwrócił gracza do rejestru po usunięciu.",
  "KRIPTA.Notification.CardGiven": "Karta została wydana.",
  "KRIPTA.Notification.CardUsed": "Karta została użyta i odpisana.",
  "KRIPTA.Notification.CardWrittenOff": "Karta została odpisana.",
  "KRIPTA.Notification.CannotUseMissingCard": "Ta karta nie jest już zarejestrowana na serwerze. Użycie jest niedostępne.",
  "KRIPTA.Notification.MissingCard": "Ta karta nie jest już zarejestrowana na serwerze.",
  "KRIPTA.Notification.PlayerNotSelected": "Nie wybrano gracza do wydania karty",
  "KRIPTA.Notification.PlayerBindingMissing": "Nie udało się określić powiązania gracza do wydania karty",
  "KRIPTA.Notification.RequestSent": "Prośba o kartę została wysłana na czat.",
  "KRIPTA.Notification.ServerSuccess": "Połączenie udane.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "Połączenie udane. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "Nie udało się połączyć z serwerem. Sprawdź adres, dostępność serwera i ustawienia CORS/HTTPS.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "Nie udało się sprawdzić serwera.",
  "KRIPTA.Notification.InvalidServerUrl": "Nieprawidłowy adres serwera: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "Sekcja ustawień „Karty Krypty” jest dostępna tylko dla ról „Prowadzący” i „Asystent prowadzącego”.",
  "KRIPTA.Notification.ServerCheckFailed": "Sprawdzenie serwera nie powiodło się",
  "KRIPTA.Notification.TechUserReader": "Czytelnik",
  "KRIPTA.Notification.TechUserWriter": "Pisarz",
  "KRIPTA.Notification.TechUsersCheckSuccess": "Użytkownicy techniczni \"Reader\" i \"Writer\" pomyślnie przechodzą sprawdzenie.",
  "KRIPTA.Notification.SettingsSaved": "Ustawienia połączenia zapisane.",
  "KRIPTA.Notification.PlayerAdded": "Gracz dodany.",
  "KRIPTA.Notification.PlayerUpdated": "Gracz zaktualizowany.",
  "KRIPTA.Notification.PlayerDeleted": "Gracz usunięty.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "Usunięcie anulowane. Pole kontrolne wypełniono nieprawidłowo.",
  "KRIPTA.Notification.BindingSaved": "Powiązanie zapisane.",
  "KRIPTA.Notification.BindingDeleted": "Powiązanie usunięte.",
  "KRIPTA.Notification.BadCatalogCardNumber": "Wybrana karta ma nieprawidłowy numer. Sprawdź odpowiedź getCardsList i normalizeCardsList.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "Tej karty nie można wydać ręcznie: ma nieprawidłowy numer. Sprawdź odpowiedź getCardsList i normalizeCardsList.",
  "KRIPTA.Notification.CardOutputFailed": "Nie udało się wyświetlić karty na czacie",
  "KRIPTA.Notification.CardGiveFailed": "Nie udało się wydać karty",
  "KRIPTA.Notification.CardUseFailed": "Nie udało się użyć karty",
  "KRIPTA.Notification.CardTakeFailed": "Nie udało się odpisać karty",
  "KRIPTA.Notification.CardRequestFailed": "Nie udało się wysłać prośby o kartę",
  "KRIPTA.Notification.CardRequestConfirmFailed": "Nie udało się potwierdzić wydania karty",
  "KRIPTA.Notification.PlayerAddFailed": "Nie udało się dodać gracza",
  "KRIPTA.Notification.PlayerUpdateFailed": "Nie udało się zaktualizować gracza",
  "KRIPTA.Notification.PlayerDeleteFailed": "Nie udało się usunąć gracza",
  "KRIPTA.Notification.CardRollFailed": "Nie udało się otrzymać karty.",
  "KRIPTA.Dialog.TakeCard.Title": "Zabierz kartę",
  "KRIPTA.Dialog.TakeCard.Message": "Gracz {playerName} zostanie pozbawiony karty {cardName}.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Wydaj kartę"
}
__END_LOCALE_JSON__
