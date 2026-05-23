@echo off
setlocal
set "SCRIPT_FILE=%~f0"
if not exist "dmicher-kripta-cards\module.json" (
  echo Run this script from the Foundry module workspace root, next to dmicher-kripta-cards\module.json.
  exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -EncodedCommand JABFAHIAcgBvAHIAQQBjAHQAaQBvAG4AUAByAGUAZgBlAHIAZQBuAGMAZQA9ACcAUwB0AG8AcAAnADsAIAAkAHMAPQBbAEkATwAuAEYAaQBsAGUAXQA6ADoAUgBlAGEAZABBAGwAbABUAGUAeAB0ACgAJABlAG4AdgA6AFMAQwBSAEkAUABUAF8ARgBJAEwARQAsAFsAVABlAHgAdAAuAEUAbgBjAG8AZABpAG4AZwBdADoAOgBVAFQARgA4ACkAOwAgACQAbQA9AFsAcgBlAGcAZQB4AF0AOgA6AE0AYQB0AGMAaAAoACQAcwAsACcAKAA/AHMAKQBfAF8AUABPAFcARQBSAFMASABFAEwATABfAF8AXAByAD8AXABuACgALgAqAD8AKQBcAHIAPwBcAG4AXwBfAEUATgBEAF8AUABPAFcARQBSAFMASABFAEwATABfAF8AJwApADsAIABpAGYAKAAtAG4AbwB0ACAAJABtAC4AUwB1AGMAYwBlAHMAcwApAHsAdABoAHIAbwB3ACAAJwBNAGkAcwBzAGkAbgBnACAAUABvAHcAZQByAFMAaABlAGwAbAAgAGIAbABvAGMAawAnAH0AOwAgAEkAbgB2AG8AawBlAC0ARQB4AHAAcgBlAHMAcwBpAG8AbgAgACQAbQAuAEcAcgBvAHUAcABzAFsAMQBdAC4AVgBhAGwAdQBlAA==
if errorlevel 1 exit /b %ERRORLEVEL%
exit /b 0
__POWERSHELL__
$ErrorActionPreference = 'Stop'
$script = [IO.File]::ReadAllText($env:SCRIPT_FILE, [Text.Encoding]::UTF8)

function Get-EmbeddedBlock([string]$Name) {
  $pattern = '(?s)__' + [regex]::Escape($Name) + '__\r?\n(.*?)\r?\n__END_' + [regex]::Escape($Name) + '__'
  $match = [regex]::Match($script, $pattern)
  if (-not $match.Success) {
    throw 'Missing block ' + $Name
  }
  return $match.Groups[1].Value.Trim([char]13, [char]10)
}

$encoding = New-Object System.Text.UTF8Encoding -ArgumentList $false
$localeJson = Get-EmbeddedBlock 'LOCALE_JSON'
$manifestEntryJson = Get-EmbeddedBlock 'MANIFEST_JSON'
$localePath = 'dmicher-kripta-cards/lang/pl.json'
$manifestPath = 'dmicher-kripta-cards/module.json'

New-Item -ItemType Directory -Force -Path 'dmicher-kripta-cards/lang' | Out-Null
[IO.File]::WriteAllText($localePath, $localeJson + [Environment]::NewLine, $encoding)

$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$entry = $manifestEntryJson | ConvertFrom-Json
if (-not @($manifest.languages | Where-Object { $_.lang -eq $entry.lang }).Count) {
  $manifest.languages = @($manifest.languages) + $entry
}

[IO.File]::WriteAllText($manifestPath, ($manifest | ConvertTo-Json -Depth 20) + [Environment]::NewLine, $encoding)
Write-Host ('Locale ' + $entry.lang + ' installed.')
__END_POWERSHELL__
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
