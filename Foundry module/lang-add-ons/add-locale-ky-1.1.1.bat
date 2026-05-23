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
$localePath = 'dmicher-kripta-cards/lang/ky.json'
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
  "lang": "ky",
  "name": "Кыргызча",
  "path": "lang/ky.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "Foundry колдонуучуңуз Kripta Cards модулунда сервер оюнчусу менен байланыштырылган эмес. Оюн устасына кайрылыңыз.",
  "KRIPTA.GMOnly": "Бул аракет оюн устасына гана жеткиликтүү.",
  "KRIPTA.Settings.ServerUrl.Name": "Сервер дареги",
  "KRIPTA.Settings.TechAuthUsers.Name": "Техникалык колдонуучулар",
  "KRIPTA.Settings.PlayerBindings.Name": "Foundry колдонуучуларын сервер оюнчуларына байланыштыруу",
  "KRIPTA.Settings.UiPrefs.Name": "Жергиликтүү интерфейс жөндөөлөрү",
  "KRIPTA.Settings.Menu.Name": "Kripta Cards",
  "KRIPTA.Settings.Menu.Label": "Модуль жөндөөлөрү",
  "KRIPTA.Settings.Menu.Hint": "API байланышы жана техникалык колдонуучулар.",
  "KRIPTA.Settings.Help.BeforeServerLink": "Эгер модуль үчүн контент серверин али орнотуп жана жөндөп бүтө элек болсоңуз, муну жасоо үчүн ",
  "KRIPTA.Settings.Help.ServerLink": "бул шилтемеге",
  "KRIPTA.Settings.Help.AfterServerLink": " өтүңүз. Ыкчам жөндөө үчүн ",
  "KRIPTA.Settings.Help.DocumentationLink": "документацияны",
  "KRIPTA.Settings.Help.AfterDocumentationLink": " колдонуңуз.",
  "KRIPTA.Window.Catalog": "Карталар каталогу",
  "KRIPTA.Window.CardDetails": "Каталог картасы",
  "KRIPTA.Window.GiveCard": "Карта берүү",
  "KRIPTA.Window.MyCards": "Оюнчунун карталары",
  "KRIPTA.Window.Players": "Оюнчуларды башкаруу",
  "KRIPTA.Window.Registry": "Оюнчулар реестри",
  "KRIPTA.Window.RequestCard": "Карта суроо",
  "KRIPTA.Window.Settings": "Kripta Cards - Жөндөөлөр",
  "KRIPTA.Window.UseCard": "Картаны колдонуу",
  "KRIPTA.Menu.Title": "Kripta Cards",
  "KRIPTA.Menu.Catalog": "Карталар каталогу",
  "KRIPTA.Menu.GetCard": "Карта суроо",
  "KRIPTA.Menu.MyCards": "Менин карталарым",
  "KRIPTA.Menu.Players": "Оюнчуларды башкаруу",
  "KRIPTA.Label.Category": "Категория",
  "KRIPTA.Label.Mode": "Режим",
  "KRIPTA.Label.Card": "Карта",
  "KRIPTA.Label.Player": "Оюнчу",
  "KRIPTA.Label.Name": "Аты",
  "KRIPTA.Label.Comment": "Комментарий",
  "KRIPTA.Label.CardTypes": "Карта түрлөрү",
  "KRIPTA.Label.Count": "Саны",
  "KRIPTA.Label.ConfirmationCode": "Ырастоо коду",
  "KRIPTA.Label.Id": "Id",
  "KRIPTA.Label.Key": "Key",
  "KRIPTA.Label.ServerUrl": "Сервер URL",
  "KRIPTA.Label.Writer": "Writer",
  "KRIPTA.Label.Reader": "Reader",
  "KRIPTA.Label.Role": "Рол",
  "KRIPTA.Label.Binding": "Байланыш",
  "KRIPTA.Role.GM": "Оюн устасы",
  "KRIPTA.Role.Player": "Оюнчу",
  "KRIPTA.Status.InGame": "онлайн",
  "KRIPTA.Status.Offline": "офлайн",
  "KRIPTA.Binding.CardsIssued": "берилген карталар:",
  "KRIPTA.Binding.NoCards": "карта жок",
  "KRIPTA.Binding.NotBound": "оюнчу байланыштырылган эмес, оюнчуну байланыштырыңыз.",
  "KRIPTA.Binding.CardsCountHint": "Кайталоолорду эсептебегенде берилген карта түрлөрүнүн саны",
  "KRIPTA.Button.Add": "Кошуу",
  "KRIPTA.Button.Bind": "Байлоо",
  "KRIPTA.Button.Cancel": "Жокко чыгаруу",
  "KRIPTA.Button.Close": "Жабуу",
  "KRIPTA.Button.Confirm": "Ырастоо",
  "KRIPTA.Button.Delete": "Өчүрүү",
  "KRIPTA.Button.Edit": "Өзгөртүү",
  "KRIPTA.Button.Give": "Берүү",
  "KRIPTA.Button.GiveCard": "Карта берүү",
  "KRIPTA.Button.Info": "Маалымат",
  "KRIPTA.Button.No": "Жок",
  "KRIPTA.Button.Output": "Жарыялоо",
  "KRIPTA.Button.Refresh": "Жаңыртуу",
  "KRIPTA.Button.Registry": "Оюнчулар реестри",
  "KRIPTA.Button.Request": "Суроо",
  "KRIPTA.Button.RequestCard": "Суроо",
  "KRIPTA.Button.SaveChanges": "Өзгөртүүлөрдү сактоо",
  "KRIPTA.Button.Take": "Алуу",
  "KRIPTA.Button.TestAuth": "Техникалык колдонуучуларды текшерүү",
  "KRIPTA.Button.TestServer": "Серверди текшерүү",
  "KRIPTA.Button.Unbind": "Байланышты үзүү",
  "KRIPTA.Button.Use": "Колдонуу",
  "KRIPTA.Button.Yes": "Ооба",
  "KRIPTA.Mode.Manual": "Кол менен тандоо",
  "KRIPTA.Mode.Random": "Кокус",
  "KRIPTA.Mode.Show": "Көрсөтүү",
  "KRIPTA.Mode.Spend": "Сарптоо",
  "KRIPTA.View.Table": "Таблица",
  "KRIPTA.View.Tiles": "Плиткалар",
  "KRIPTA.Placeholder.Search": "Издөө",
  "KRIPTA.Select.NotSelected": "-- тандалган эмес --",
  "KRIPTA.Template.EmptyCatalog": "Серверде катталган категориялар же карталар жок.",
  "KRIPTA.Template.MyCardsTitle": "Оюнчунун карталары: {playerName}",
  "KRIPTA.Template.UseCardMissing": "Бул карта мындан ары серверде катталган эмес.",
  "KRIPTA.Template.UseCardPrompt": "Бул карта колдонулат:",
  "KRIPTA.Card.FallbackName": "Карта {number}",
  "KRIPTA.Card.FallbackAddress": "Карта {level}/{number}",
  "KRIPTA.Card.MissingDescription": "Карта {level}/{number} учурдагы сервер каталогунда жок.",
  "KRIPTA.Card.NotRegisteredDescription": "Карта {level}/{number} мындан ары серверде катталган эмес.",
  "KRIPTA.Level.FallbackName": "Деңгээл {level}",
  "KRIPTA.Level.MissingDescription": "Бул деңгээл оюнчунун инвентарында бар, бирок учурдагы сервер каталогунда жок.",
  "KRIPTA.Chat.BlobReadFailed": "blob окулбады",
  "KRIPTA.Chat.CardGivenTitle": "Карта берилди",
  "KRIPTA.Chat.CardReceiveSubtitle": "Оюнчу {playerName} {cardSubtitle} картасын алат",
  "KRIPTA.Chat.CardRequestCanceled": "Карта суроосу жокко чыгарылды.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "Карта суроосу ырасталды",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "Суроо маалыматтары окулбады.",
  "KRIPTA.Chat.CardSpentFooter": "КАРТА САРПТАЛДЫ",
  "KRIPTA.Chat.CardSpentTitle": "Карта сарпталды",
  "KRIPTA.Chat.FallbackPlayer": "оюнчу",
  "KRIPTA.Chat.ManualChoiceFooter": "КОЛ МЕНЕН ТАНДОО",
  "KRIPTA.Chat.ReferenceTitle": "Маалымдама",
  "KRIPTA.Chat.RequestManualTitle": "Тандалган карта суроосу",
  "KRIPTA.Chat.RequestRandomTitle": "Кокус карта суроосу",
  "KRIPTA.Chat.ShowCardTitle": "Карта маалымдамасы",
  "KRIPTA.Dialog.BindPlayer.Title": "Сервер оюнчусун байлоо",
  "KRIPTA.Dialog.BindPlayer.Header": "{foundryUserName} үчүн оюнчу тандаңыз",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "Foundry колдонуучусу",
  "KRIPTA.Dialog.Player.AddTitle": "Оюнчу кошуу",
  "KRIPTA.Dialog.Player.EditTitle": "Оюнчуну өзгөртүү",
  "KRIPTA.Dialog.Player.DeleteTitle": "Оюнчуну өчүрүү",
  "KRIPTA.Dialog.Player.DeleteWarning": "\"{playerName}\" оюнчусун өчүрүү артка кайтарылбайт. \"{code}\" киргизип, өчүрүүнү ырастаңыз.",
  "KRIPTA.Dialog.Count.TotalCards": "бул түрдөгү жалпы карталар - {max}",
  "KRIPTA.Error.InvalidCardLevel": "{context} үчүн туура эмес деңгээл: {level}",
  "KRIPTA.Error.InvalidCardNumber": "{context} үчүн туура эмес номер: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "туура эмес карта деңгээли: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "туура эмес карта номери: {number}",
  "KRIPTA.Error.InvalidRequestCard": "Суроо үчүн туура эмес карта",
  "KRIPTA.Error.InvalidGiveCard": "Берүү үчүн туура эмес карта",
  "KRIPTA.Error.MissingRequestPlayerGuid": "Карта берүү үчүн playerGuid аныкталган жок.",
  "KRIPTA.Error.MissingSelectedCard": "Тандалган карта аныкталган жок.",
  "KRIPTA.Error.MissingSelectedCardForGive": "Берүү үчүн тандалган карта аныкталган жок.",
  "KRIPTA.Error.MissingGivePlayer": "Карта берилүүчү оюнчу аныкталган жок.",
  "KRIPTA.Error.MissingGiveCard": "Берилүүчү карта аныкталган жок.",
  "KRIPTA.Error.MissingServerUrl": "Сервер жолунун жөндөөсү жок.",
  "KRIPTA.Error.InvalidReader": "Reader техникалык колдонуучусу туура эмес жөндөлгөн.",
  "KRIPTA.Error.InvalidWriter": "Writer техникалык колдонуучусу туура эмес жөндөлгөн.",
  "KRIPTA.Error.MenuUnavailable": "Бул функция жеткиликсиз. Модуль жөндөөлөрүн текшериңиз. Толук маалымат браузер консолунда.",
  "KRIPTA.Error.Generic": "Ката кетти",
  "KRIPTA.Error.Unknown": "белгисиз ката",
  "KRIPTA.Error.NameRequired": "Name талаасы милдеттүү.",
  "KRIPTA.Error.RegistryDeleteReturned": "өчүрүлгөндөн кийин сервер оюнчуну реестрде кайтарды.",
  "KRIPTA.Notification.CardGiven": "Карта берилди.",
  "KRIPTA.Notification.CardUsed": "Карта колдонулду жана сарпталды.",
  "KRIPTA.Notification.CardWrittenOff": "Карта алынып салынды.",
  "KRIPTA.Notification.CannotUseMissingCard": "Бул карта мындан ары серверде катталган эмес. Аны колдонууга болбойт.",
  "KRIPTA.Notification.MissingCard": "Бул карта мындан ары серверде катталган эмес.",
  "KRIPTA.Notification.PlayerNotSelected": "Карта берүү үчүн оюнчу тандалган жок",
  "KRIPTA.Notification.PlayerBindingMissing": "Карта берүү үчүн оюнчу байланышы аныкталган жок",
  "KRIPTA.Notification.RequestSent": "Карта суроосу чатка жөнөтүлдү.",
  "KRIPTA.Notification.ServerSuccess": "Туташуу ийгиликтүү.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "Туташуу ийгиликтүү. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "Серверге туташуу мүмкүн болгон жок. Даректи, сервер жеткиликтүүлүгүн жана CORS/HTTPS жөндөөлөрүн текшериңиз.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "Сервер текшерилген жок.",
  "KRIPTA.Notification.InvalidServerUrl": "Туура эмес сервер дареги: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "Kripta Cards жөндөөлөрү бөлүмү Оюн устасы жана Оюн устасынын жардамчысы ролдору үчүн гана жеткиликтүү.",
  "KRIPTA.Notification.ServerCheckFailed": "Сервер текшерүүсү ишке ашкан жок",
  "KRIPTA.Notification.TechUserReader": "Reader",
  "KRIPTA.Notification.TechUserWriter": "Writer",
  "KRIPTA.Notification.TechUsersCheckSuccess": "\"Reader\" жана \"Writer\" техникалык колдонуучулары текшерүүдөн өттү.",
  "KRIPTA.Notification.SettingsSaved": "Туташуу жөндөөлөрү сакталды.",
  "KRIPTA.Notification.PlayerAdded": "Оюнчу кошулду.",
  "KRIPTA.Notification.PlayerUpdated": "Оюнчу жаңыртылды.",
  "KRIPTA.Notification.PlayerDeleted": "Оюнчу өчүрүлдү.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "Өчүрүү жокко чыгарылды. Ырастоо талаасы туура эмес толтурулган.",
  "KRIPTA.Notification.BindingSaved": "Байланыш сакталды.",
  "KRIPTA.Notification.BindingDeleted": "Байланыш өчүрүлдү.",
  "KRIPTA.Notification.BadCatalogCardNumber": "Тандалган картанын номери туура эмес. getCardsList жообун жана normalizeCardsList текшериңиз.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "Бул картаны кол менен берүүгө болбойт, анткени номери туура эмес. getCardsList жообун жана normalizeCardsList текшериңиз.",
  "KRIPTA.Notification.CardOutputFailed": "Картаны чатка жарыялоо мүмкүн болгон жок",
  "KRIPTA.Notification.CardGiveFailed": "Карта берүү мүмкүн болгон жок",
  "KRIPTA.Notification.CardUseFailed": "Картаны колдонуу мүмкүн болгон жок",
  "KRIPTA.Notification.CardTakeFailed": "Картаны алып салуу мүмкүн болгон жок",
  "KRIPTA.Notification.CardRequestFailed": "Карта суроосун жөнөтүү мүмкүн болгон жок",
  "KRIPTA.Notification.CardRequestConfirmFailed": "Карта берүүнү ырастоо мүмкүн болгон жок",
  "KRIPTA.Notification.PlayerAddFailed": "Оюнчу кошуу мүмкүн болгон жок",
  "KRIPTA.Notification.PlayerUpdateFailed": "Оюнчуну жаңыртуу мүмкүн болгон жок",
  "KRIPTA.Notification.PlayerDeleteFailed": "Оюнчуну өчүрүү мүмкүн болгон жок",
  "KRIPTA.Notification.CardRollFailed": "Карта алуу мүмкүн болгон жок.",
  "KRIPTA.Dialog.TakeCard.Title": "Картаны алуу",
  "KRIPTA.Dialog.TakeCard.Message": "Оюнчу {playerName} {cardName} картасын жоготот.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Карта берүү"
}
__END_LOCALE_JSON__
