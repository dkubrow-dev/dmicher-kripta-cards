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
$localePath = 'dmicher-kripta-cards/lang/uk.json'
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
  "lang": "uk",
  "name": "Українська",
  "path": "lang/uk.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "Ваш користувач Foundry не прив'язаний до гравця сервера в модулі Kripta Cards. Зверніться до майстра гри.",
  "KRIPTA.GMOnly": "Ця дія доступна лише майстру гри.",
  "KRIPTA.Settings.ServerUrl.Name": "Адреса сервера",
  "KRIPTA.Settings.TechAuthUsers.Name": "Технічні користувачі",
  "KRIPTA.Settings.PlayerBindings.Name": "Прив'язки користувачів Foundry до гравців сервера",
  "KRIPTA.Settings.UiPrefs.Name": "Локальні налаштування інтерфейсу",
  "KRIPTA.Settings.Menu.Name": "Kripta Cards",
  "KRIPTA.Settings.Menu.Label": "Налаштування модуля",
  "KRIPTA.Settings.Menu.Hint": "Підключення до API та технічні користувачі.",
  "KRIPTA.Settings.Help.BeforeServerLink": "Якщо ви ще не встановили й не налаштували сервер контенту для модуля, перейдіть ",
  "KRIPTA.Settings.Help.ServerLink": "за посиланням",
  "KRIPTA.Settings.Help.AfterServerLink": ", щоб зробити це. Для швидкого налаштування скористайтеся ",
  "KRIPTA.Settings.Help.DocumentationLink": "документацією",
  "KRIPTA.Settings.Help.AfterDocumentationLink": ".",
  "KRIPTA.Window.Catalog": "Каталог карток",
  "KRIPTA.Window.CardDetails": "Картка каталогу",
  "KRIPTA.Window.GiveCard": "Видати картку",
  "KRIPTA.Window.MyCards": "Картки гравця",
  "KRIPTA.Window.Players": "Керування гравцями",
  "KRIPTA.Window.Registry": "Реєстр гравців",
  "KRIPTA.Window.RequestCard": "Запросити картку",
  "KRIPTA.Window.Settings": "Kripta Cards - Налаштування",
  "KRIPTA.Window.UseCard": "Використати картку",
  "KRIPTA.Menu.Title": "Kripta Cards",
  "KRIPTA.Menu.Catalog": "Каталог карток",
  "KRIPTA.Menu.GetCard": "Запросити картку",
  "KRIPTA.Menu.MyCards": "Мої картки",
  "KRIPTA.Menu.Players": "Керування гравцями",
  "KRIPTA.Label.Category": "Категорія",
  "KRIPTA.Label.Mode": "Режим",
  "KRIPTA.Label.Card": "Картка",
  "KRIPTA.Label.Player": "Гравець",
  "KRIPTA.Label.Name": "Ім'я",
  "KRIPTA.Label.Comment": "Коментар",
  "KRIPTA.Label.CardTypes": "Типи карток",
  "KRIPTA.Label.Count": "Кількість",
  "KRIPTA.Label.ConfirmationCode": "Код підтвердження",
  "KRIPTA.Label.Id": "Id",
  "KRIPTA.Label.Key": "Key",
  "KRIPTA.Label.ServerUrl": "URL сервера",
  "KRIPTA.Label.Writer": "Writer",
  "KRIPTA.Label.Reader": "Reader",
  "KRIPTA.Label.Role": "Роль",
  "KRIPTA.Label.Binding": "Прив'язка",
  "KRIPTA.Role.GM": "Майстер гри",
  "KRIPTA.Role.Player": "Гравець",
  "KRIPTA.Status.InGame": "онлайн",
  "KRIPTA.Status.Offline": "офлайн",
  "KRIPTA.Binding.CardsIssued": "видано карток:",
  "KRIPTA.Binding.NoCards": "немає карток",
  "KRIPTA.Binding.NotBound": "гравець не прив'язаний, прив'яжіть гравця.",
  "KRIPTA.Binding.CardsCountHint": "Кількість виданих типів карток без урахування повторів",
  "KRIPTA.Button.Add": "Додати",
  "KRIPTA.Button.Bind": "Прив'язати",
  "KRIPTA.Button.Cancel": "Скасувати",
  "KRIPTA.Button.Close": "Закрити",
  "KRIPTA.Button.Confirm": "Підтвердити",
  "KRIPTA.Button.Delete": "Видалити",
  "KRIPTA.Button.Edit": "Змінити",
  "KRIPTA.Button.Give": "Видати",
  "KRIPTA.Button.GiveCard": "Видати картку",
  "KRIPTA.Button.Info": "Інформація",
  "KRIPTA.Button.No": "Ні",
  "KRIPTA.Button.Output": "Опублікувати",
  "KRIPTA.Button.Refresh": "Оновити",
  "KRIPTA.Button.Registry": "Реєстр гравців",
  "KRIPTA.Button.Request": "Запросити",
  "KRIPTA.Button.RequestCard": "Запросити",
  "KRIPTA.Button.SaveChanges": "Зберегти зміни",
  "KRIPTA.Button.Take": "Забрати",
  "KRIPTA.Button.TestAuth": "Перевірити технічних користувачів",
  "KRIPTA.Button.TestServer": "Перевірити сервер",
  "KRIPTA.Button.Unbind": "Відв'язати",
  "KRIPTA.Button.Use": "Використати",
  "KRIPTA.Button.Yes": "Так",
  "KRIPTA.Mode.Manual": "Вибрати вручну",
  "KRIPTA.Mode.Random": "Випадково",
  "KRIPTA.Mode.Show": "Показати",
  "KRIPTA.Mode.Spend": "Витратити",
  "KRIPTA.View.Table": "Таблиця",
  "KRIPTA.View.Tiles": "Плитки",
  "KRIPTA.Placeholder.Search": "Пошук",
  "KRIPTA.Select.NotSelected": "-- не вибрано --",
  "KRIPTA.Template.EmptyCatalog": "На сервері немає зареєстрованих категорій або карток.",
  "KRIPTA.Template.MyCardsTitle": "Картки гравця: {playerName}",
  "KRIPTA.Template.UseCardMissing": "Ця картка більше не зареєстрована на сервері.",
  "KRIPTA.Template.UseCardPrompt": "Буде використано цю картку:",
  "KRIPTA.Card.FallbackName": "Картка {number}",
  "KRIPTA.Card.FallbackAddress": "Картка {level}/{number}",
  "KRIPTA.Card.MissingDescription": "Картка {level}/{number} відсутня в поточному каталозі сервера.",
  "KRIPTA.Card.NotRegisteredDescription": "Картка {level}/{number} більше не зареєстрована на сервері.",
  "KRIPTA.Level.FallbackName": "Рівень {level}",
  "KRIPTA.Level.MissingDescription": "Цей рівень є в інвентарі гравця, але відсутній у поточному каталозі сервера.",
  "KRIPTA.Chat.BlobReadFailed": "Не вдалося прочитати blob",
  "KRIPTA.Chat.CardGivenTitle": "Картку видано",
  "KRIPTA.Chat.CardReceiveSubtitle": "Гравець {playerName} отримує картку {cardSubtitle}",
  "KRIPTA.Chat.CardRequestCanceled": "Запит картки скасовано.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "Запит картки підтверджено",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "Не вдалося прочитати дані запиту.",
  "KRIPTA.Chat.CardSpentFooter": "КАРТКУ ВИТРАЧЕНО",
  "KRIPTA.Chat.CardSpentTitle": "Картку витрачено",
  "KRIPTA.Chat.FallbackPlayer": "гравець",
  "KRIPTA.Chat.ManualChoiceFooter": "РУЧНИЙ ВИБІР",
  "KRIPTA.Chat.ReferenceTitle": "Довідка",
  "KRIPTA.Chat.RequestManualTitle": "Запит вибраної картки",
  "KRIPTA.Chat.RequestRandomTitle": "Запит випадкової картки",
  "KRIPTA.Chat.ShowCardTitle": "Довідка по картці",
  "KRIPTA.Dialog.BindPlayer.Title": "Прив'язати гравця сервера",
  "KRIPTA.Dialog.BindPlayer.Header": "Виберіть гравця для {foundryUserName}",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "користувача Foundry",
  "KRIPTA.Dialog.Player.AddTitle": "Додати гравця",
  "KRIPTA.Dialog.Player.EditTitle": "Змінити гравця",
  "KRIPTA.Dialog.Player.DeleteTitle": "Видалити гравця",
  "KRIPTA.Dialog.Player.DeleteWarning": "Видалення гравця \"{playerName}\" неможливо скасувати. Введіть \"{code}\" і підтвердьте видалення.",
  "KRIPTA.Dialog.Count.TotalCards": "усього карток цього типу - {max}",
  "KRIPTA.Error.InvalidCardLevel": "Некоректний рівень для {context}: {level}",
  "KRIPTA.Error.InvalidCardNumber": "Некоректний номер для {context}: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "некоректний рівень картки: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "некоректний номер картки: {number}",
  "KRIPTA.Error.InvalidRequestCard": "Некоректна картка для запиту",
  "KRIPTA.Error.InvalidGiveCard": "Некоректна картка для видачі",
  "KRIPTA.Error.MissingRequestPlayerGuid": "Не вдалося визначити playerGuid для видачі картки.",
  "KRIPTA.Error.MissingSelectedCard": "Не вдалося визначити вибрану картку.",
  "KRIPTA.Error.MissingSelectedCardForGive": "Не вдалося визначити вибрану картку для видачі.",
  "KRIPTA.Error.MissingGivePlayer": "Не вдалося визначити гравця для видачі картки.",
  "KRIPTA.Error.MissingGiveCard": "Не вдалося визначити картку для видачі.",
  "KRIPTA.Error.MissingServerUrl": "Відсутнє налаштування шляху до сервера.",
  "KRIPTA.Error.InvalidReader": "Технічний користувач Reader налаштований некоректно.",
  "KRIPTA.Error.InvalidWriter": "Технічний користувач Writer налаштований некоректно.",
  "KRIPTA.Error.MenuUnavailable": "Ця функція недоступна. Перевірте налаштування модуля. Деталі в консолі браузера.",
  "KRIPTA.Error.Generic": "Сталася помилка",
  "KRIPTA.Error.Unknown": "невідома помилка",
  "KRIPTA.Error.NameRequired": "Поле Name є обов'язковим.",
  "KRIPTA.Error.RegistryDeleteReturned": "сервер повернув гравця в реєстрі після видалення.",
  "KRIPTA.Notification.CardGiven": "Картку видано.",
  "KRIPTA.Notification.CardUsed": "Картку використано та списано.",
  "KRIPTA.Notification.CardWrittenOff": "Картку вилучено.",
  "KRIPTA.Notification.CannotUseMissingCard": "Ця картка більше не зареєстрована на сервері. Її неможливо використати.",
  "KRIPTA.Notification.MissingCard": "Ця картка більше не зареєстрована на сервері.",
  "KRIPTA.Notification.PlayerNotSelected": "Не вибрано гравця для видачі картки",
  "KRIPTA.Notification.PlayerBindingMissing": "Не вдалося визначити прив'язку гравця для видачі картки",
  "KRIPTA.Notification.RequestSent": "Запит картки надіслано в чат.",
  "KRIPTA.Notification.ServerSuccess": "Підключення успішне.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "Підключення успішне. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "Не вдалося підключитися до сервера. Перевірте адресу, доступність сервера та налаштування CORS/HTTPS.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "Не вдалося перевірити сервер.",
  "KRIPTA.Notification.InvalidServerUrl": "Некоректна адреса сервера: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "Розділ налаштувань Kripta Cards доступний лише ролям Майстер гри та Помічник майстра гри.",
  "KRIPTA.Notification.ServerCheckFailed": "Перевірка сервера не вдалася",
  "KRIPTA.Notification.TechUserReader": "Reader",
  "KRIPTA.Notification.TechUserWriter": "Writer",
  "KRIPTA.Notification.TechUsersCheckSuccess": "Технічні користувачі \"Reader\" і \"Writer\" успішно проходять перевірку.",
  "KRIPTA.Notification.SettingsSaved": "Налаштування підключення збережено.",
  "KRIPTA.Notification.PlayerAdded": "Гравця додано.",
  "KRIPTA.Notification.PlayerUpdated": "Гравця оновлено.",
  "KRIPTA.Notification.PlayerDeleted": "Гравця видалено.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "Видалення скасовано. Поле підтвердження заповнене некоректно.",
  "KRIPTA.Notification.BindingSaved": "Прив'язку збережено.",
  "KRIPTA.Notification.BindingDeleted": "Прив'язку вилучено.",
  "KRIPTA.Notification.BadCatalogCardNumber": "Вибрана картка має некоректний номер. Перевірте відповідь getCardsList і normalizeCardsList.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "Цю картку не можна видати вручну, бо вона має некоректний номер. Перевірте відповідь getCardsList і normalizeCardsList.",
  "KRIPTA.Notification.CardOutputFailed": "Не вдалося опублікувати картку в чаті",
  "KRIPTA.Notification.CardGiveFailed": "Не вдалося видати картку",
  "KRIPTA.Notification.CardUseFailed": "Не вдалося використати картку",
  "KRIPTA.Notification.CardTakeFailed": "Не вдалося вилучити картку",
  "KRIPTA.Notification.CardRequestFailed": "Не вдалося надіслати запит картки",
  "KRIPTA.Notification.CardRequestConfirmFailed": "Не вдалося підтвердити видачу картки",
  "KRIPTA.Notification.PlayerAddFailed": "Не вдалося додати гравця",
  "KRIPTA.Notification.PlayerUpdateFailed": "Не вдалося оновити гравця",
  "KRIPTA.Notification.PlayerDeleteFailed": "Не вдалося видалити гравця",
  "KRIPTA.Notification.CardRollFailed": "Не вдалося отримати картку.",
  "KRIPTA.Dialog.TakeCard.Title": "Забрати картку",
  "KRIPTA.Dialog.TakeCard.Message": "Гравець {playerName} втратить картку {cardName}.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Видати картку"
}
__END_LOCALE_JSON__
