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
$localePath = 'dmicher-kripta-cards/lang/be.json'
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
  "lang": "be",
  "name": "Беларуская",
  "path": "lang/be.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "Ваш карыстальнік Foundry не прывязаны да гульца сервера ў модулі Kripta Cards. Звярніцеся да майстра гульні.",
  "KRIPTA.GMOnly": "Гэта дзеянне даступнае толькі майстру гульні.",
  "KRIPTA.Settings.ServerUrl.Name": "Адрас сервера",
  "KRIPTA.Settings.TechAuthUsers.Name": "Тэхнічныя карыстальнікі",
  "KRIPTA.Settings.PlayerBindings.Name": "Прывязкі карыстальнікаў Foundry да гульцоў сервера",
  "KRIPTA.Settings.UiPrefs.Name": "Лакальныя налады інтэрфейсу",
  "KRIPTA.Settings.Menu.Name": "Kripta Cards",
  "KRIPTA.Settings.Menu.Label": "Налады модуля",
  "KRIPTA.Settings.Menu.Hint": "Падключэнне да API і тэхнічныя карыстальнікі.",
  "KRIPTA.Settings.Help.BeforeServerLink": "Калі вы яшчэ не ўсталявалі і не наладзілі сервер кантэнту для модуля, перайдзіце ",
  "KRIPTA.Settings.Help.ServerLink": "па спасылцы",
  "KRIPTA.Settings.Help.AfterServerLink": ", каб зрабіць гэта. Для хуткай наладкі скарыстайцеся ",
  "KRIPTA.Settings.Help.DocumentationLink": "дакументацыяй",
  "KRIPTA.Settings.Help.AfterDocumentationLink": ".",
  "KRIPTA.Window.Catalog": "Каталог картак",
  "KRIPTA.Window.CardDetails": "Картка каталога",
  "KRIPTA.Window.GiveCard": "Выдаць картку",
  "KRIPTA.Window.MyCards": "Карткі гульца",
  "KRIPTA.Window.Players": "Кіраванне гульцамі",
  "KRIPTA.Window.Registry": "Рэестр гульцоў",
  "KRIPTA.Window.RequestCard": "Запытаць картку",
  "KRIPTA.Window.Settings": "Kripta Cards - Налады",
  "KRIPTA.Window.UseCard": "Выкарыстаць картку",
  "KRIPTA.Menu.Title": "Kripta Cards",
  "KRIPTA.Menu.Catalog": "Каталог картак",
  "KRIPTA.Menu.GetCard": "Запытаць картку",
  "KRIPTA.Menu.MyCards": "Мае карткі",
  "KRIPTA.Menu.Players": "Кіраванне гульцамі",
  "KRIPTA.Label.Category": "Катэгорыя",
  "KRIPTA.Label.Mode": "Рэжым",
  "KRIPTA.Label.Card": "Картка",
  "KRIPTA.Label.Player": "Гулец",
  "KRIPTA.Label.Name": "Імя",
  "KRIPTA.Label.Comment": "Каментар",
  "KRIPTA.Label.CardTypes": "Тыпы картак",
  "KRIPTA.Label.Count": "Колькасць",
  "KRIPTA.Label.ConfirmationCode": "Код пацвярджэння",
  "KRIPTA.Label.Id": "Id",
  "KRIPTA.Label.Key": "Key",
  "KRIPTA.Label.ServerUrl": "URL сервера",
  "KRIPTA.Label.Writer": "Writer",
  "KRIPTA.Label.Reader": "Reader",
  "KRIPTA.Label.Role": "Роля",
  "KRIPTA.Label.Binding": "Прывязка",
  "KRIPTA.Role.GM": "Майстар гульні",
  "KRIPTA.Role.Player": "Гулец",
  "KRIPTA.Status.InGame": "анлайн",
  "KRIPTA.Status.Offline": "афлайн",
  "KRIPTA.Binding.CardsIssued": "выдадзена картак:",
  "KRIPTA.Binding.NoCards": "няма картак",
  "KRIPTA.Binding.NotBound": "гулец не прывязаны, прывяжыце гульца.",
  "KRIPTA.Binding.CardsCountHint": "Колькасць выдадзеных тыпаў картак без уліку паўтораў",
  "KRIPTA.Button.Add": "Дадаць",
  "KRIPTA.Button.Bind": "Прывязаць",
  "KRIPTA.Button.Cancel": "Скасаваць",
  "KRIPTA.Button.Close": "Закрыць",
  "KRIPTA.Button.Confirm": "Пацвердзіць",
  "KRIPTA.Button.Delete": "Выдаліць",
  "KRIPTA.Button.Edit": "Змяніць",
  "KRIPTA.Button.Give": "Выдаць",
  "KRIPTA.Button.GiveCard": "Выдаць картку",
  "KRIPTA.Button.Info": "Інфармацыя",
  "KRIPTA.Button.No": "Не",
  "KRIPTA.Button.Output": "Апублікаваць",
  "KRIPTA.Button.Refresh": "Абнавіць",
  "KRIPTA.Button.Registry": "Рэестр гульцоў",
  "KRIPTA.Button.Request": "Запытаць",
  "KRIPTA.Button.RequestCard": "Запытаць",
  "KRIPTA.Button.SaveChanges": "Захаваць змены",
  "KRIPTA.Button.Take": "Забраць",
  "KRIPTA.Button.TestAuth": "Праверыць тэхнічных карыстальнікаў",
  "KRIPTA.Button.TestServer": "Праверыць сервер",
  "KRIPTA.Button.Unbind": "Адвязаць",
  "KRIPTA.Button.Use": "Выкарыстаць",
  "KRIPTA.Button.Yes": "Так",
  "KRIPTA.Mode.Manual": "Выбраць уручную",
  "KRIPTA.Mode.Random": "Выпадкова",
  "KRIPTA.Mode.Show": "Паказаць",
  "KRIPTA.Mode.Spend": "Выдаткаваць",
  "KRIPTA.View.Table": "Табліца",
  "KRIPTA.View.Tiles": "Пліткі",
  "KRIPTA.Placeholder.Search": "Пошук",
  "KRIPTA.Select.NotSelected": "-- не выбрана --",
  "KRIPTA.Template.EmptyCatalog": "На серверы няма зарэгістраваных катэгорый або картак.",
  "KRIPTA.Template.MyCardsTitle": "Карткі гульца: {playerName}",
  "KRIPTA.Template.UseCardMissing": "Гэтая картка больш не зарэгістравана на серверы.",
  "KRIPTA.Template.UseCardPrompt": "Будзе выкарыстана гэтая картка:",
  "KRIPTA.Card.FallbackName": "Картка {number}",
  "KRIPTA.Card.FallbackAddress": "Картка {level}/{number}",
  "KRIPTA.Card.MissingDescription": "Картка {level}/{number} адсутнічае ў бягучым каталогу сервера.",
  "KRIPTA.Card.NotRegisteredDescription": "Картка {level}/{number} больш не зарэгістравана на серверы.",
  "KRIPTA.Level.FallbackName": "Узровень {level}",
  "KRIPTA.Level.MissingDescription": "Гэты ўзровень ёсць у інвентары гульца, але адсутнічае ў бягучым каталогу сервера.",
  "KRIPTA.Chat.BlobReadFailed": "Не ўдалося прачытаць blob",
  "KRIPTA.Chat.CardGivenTitle": "Картка выдадзена",
  "KRIPTA.Chat.CardReceiveSubtitle": "Гулец {playerName} атрымлівае картку {cardSubtitle}",
  "KRIPTA.Chat.CardRequestCanceled": "Запыт карткі скасаваны.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "Запыт карткі пацверджаны",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "Не ўдалося прачытаць даныя запыту.",
  "KRIPTA.Chat.CardSpentFooter": "КАРТКА ВЫДАТКАВАНА",
  "KRIPTA.Chat.CardSpentTitle": "Картка выдаткавана",
  "KRIPTA.Chat.FallbackPlayer": "гулец",
  "KRIPTA.Chat.ManualChoiceFooter": "РУЧНЫ ВЫБАР",
  "KRIPTA.Chat.ReferenceTitle": "Даведка",
  "KRIPTA.Chat.RequestManualTitle": "Запыт выбранай карткі",
  "KRIPTA.Chat.RequestRandomTitle": "Запыт выпадковай карткі",
  "KRIPTA.Chat.ShowCardTitle": "Даведка па картцы",
  "KRIPTA.Dialog.BindPlayer.Title": "Прывязаць гульца сервера",
  "KRIPTA.Dialog.BindPlayer.Header": "Выберыце гульца для {foundryUserName}",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "карыстальніка Foundry",
  "KRIPTA.Dialog.Player.AddTitle": "Дадаць гульца",
  "KRIPTA.Dialog.Player.EditTitle": "Змяніць гульца",
  "KRIPTA.Dialog.Player.DeleteTitle": "Выдаліць гульца",
  "KRIPTA.Dialog.Player.DeleteWarning": "Выдаленне гульца \"{playerName}\" немагчыма адмяніць. Увядзіце \"{code}\" і пацвердзіце выдаленне.",
  "KRIPTA.Dialog.Count.TotalCards": "усяго картак гэтага тыпу - {max}",
  "KRIPTA.Error.InvalidCardLevel": "Няправільны ўзровень для {context}: {level}",
  "KRIPTA.Error.InvalidCardNumber": "Няправільны нумар для {context}: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "няправільны ўзровень карткі: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "няправільны нумар карткі: {number}",
  "KRIPTA.Error.InvalidRequestCard": "Няправільная картка для запыту",
  "KRIPTA.Error.InvalidGiveCard": "Няправільная картка для выдачы",
  "KRIPTA.Error.MissingRequestPlayerGuid": "Не ўдалося вызначыць playerGuid для выдачы карткі.",
  "KRIPTA.Error.MissingSelectedCard": "Не ўдалося вызначыць выбраную картку.",
  "KRIPTA.Error.MissingSelectedCardForGive": "Не ўдалося вызначыць выбраную картку для выдачы.",
  "KRIPTA.Error.MissingGivePlayer": "Не ўдалося вызначыць гульца для выдачы карткі.",
  "KRIPTA.Error.MissingGiveCard": "Не ўдалося вызначыць картку для выдачы.",
  "KRIPTA.Error.MissingServerUrl": "Адсутнічае налада шляху да сервера.",
  "KRIPTA.Error.InvalidReader": "Тэхнічны карыстальнік Reader настроены няправільна.",
  "KRIPTA.Error.InvalidWriter": "Тэхнічны карыстальнік Writer настроены няправільна.",
  "KRIPTA.Error.MenuUnavailable": "Гэтая функцыя недаступная. Праверце налады модуля. Падрабязнасці ў кансолі браўзера.",
  "KRIPTA.Error.Generic": "Адбылася памылка",
  "KRIPTA.Error.Unknown": "невядомая памылка",
  "KRIPTA.Error.NameRequired": "Поле Name абавязковае.",
  "KRIPTA.Error.RegistryDeleteReturned": "сервер вярнуў гульца ў рэестры пасля выдалення.",
  "KRIPTA.Notification.CardGiven": "Картка выдадзена.",
  "KRIPTA.Notification.CardUsed": "Картка выкарыстана і спісана.",
  "KRIPTA.Notification.CardWrittenOff": "Картка выдалена.",
  "KRIPTA.Notification.CannotUseMissingCard": "Гэтая картка больш не зарэгістравана на серверы. Яе нельга выкарыстаць.",
  "KRIPTA.Notification.MissingCard": "Гэтая картка больш не зарэгістравана на серверы.",
  "KRIPTA.Notification.PlayerNotSelected": "Не выбраны гулец для выдачы карткі",
  "KRIPTA.Notification.PlayerBindingMissing": "Не ўдалося вызначыць прывязку гульца для выдачы карткі",
  "KRIPTA.Notification.RequestSent": "Запыт карткі адпраўлены ў чат.",
  "KRIPTA.Notification.ServerSuccess": "Падключэнне паспяховае.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "Падключэнне паспяховае. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "Не ўдалося падключыцца да сервера. Праверце адрас, даступнасць сервера і налады CORS/HTTPS.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "Не ўдалося праверыць сервер.",
  "KRIPTA.Notification.InvalidServerUrl": "Няправільны адрас сервера: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "Раздзел налад Kripta Cards даступны толькі ролям Майстар гульні і Памочнік майстра гульні.",
  "KRIPTA.Notification.ServerCheckFailed": "Праверка сервера не ўдалася",
  "KRIPTA.Notification.TechUserReader": "Reader",
  "KRIPTA.Notification.TechUserWriter": "Writer",
  "KRIPTA.Notification.TechUsersCheckSuccess": "Тэхнічныя карыстальнікі \"Reader\" і \"Writer\" паспяхова прайшлі праверку.",
  "KRIPTA.Notification.SettingsSaved": "Налады падключэння захаваныя.",
  "KRIPTA.Notification.PlayerAdded": "Гулец дададзены.",
  "KRIPTA.Notification.PlayerUpdated": "Гулец абноўлены.",
  "KRIPTA.Notification.PlayerDeleted": "Гулец выдалены.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "Выдаленне скасавана. Поле пацвярджэння запоўнена няправільна.",
  "KRIPTA.Notification.BindingSaved": "Прывязка захаваная.",
  "KRIPTA.Notification.BindingDeleted": "Прывязка выдаленая.",
  "KRIPTA.Notification.BadCatalogCardNumber": "Выбраная картка мае няправільны нумар. Праверце адказ getCardsList і normalizeCardsList.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "Гэтую картку нельга выдаць уручную, бо яна мае няправільны нумар. Праверце адказ getCardsList і normalizeCardsList.",
  "KRIPTA.Notification.CardOutputFailed": "Не ўдалося апублікаваць картку ў чаце",
  "KRIPTA.Notification.CardGiveFailed": "Не ўдалося выдаць картку",
  "KRIPTA.Notification.CardUseFailed": "Не ўдалося выкарыстаць картку",
  "KRIPTA.Notification.CardTakeFailed": "Не ўдалося выдаліць картку",
  "KRIPTA.Notification.CardRequestFailed": "Не ўдалося адправіць запыт карткі",
  "KRIPTA.Notification.CardRequestConfirmFailed": "Не ўдалося пацвердзіць выдачу карткі",
  "KRIPTA.Notification.PlayerAddFailed": "Не ўдалося дадаць гульца",
  "KRIPTA.Notification.PlayerUpdateFailed": "Не ўдалося абнавіць гульца",
  "KRIPTA.Notification.PlayerDeleteFailed": "Не ўдалося выдаліць гульца",
  "KRIPTA.Notification.CardRollFailed": "Не ўдалося атрымаць картку.",
  "KRIPTA.Dialog.TakeCard.Title": "Забраць картку",
  "KRIPTA.Dialog.TakeCard.Message": "Гулец {playerName} страціць картку {cardName}.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Выдаць картку"
}
__END_LOCALE_JSON__
