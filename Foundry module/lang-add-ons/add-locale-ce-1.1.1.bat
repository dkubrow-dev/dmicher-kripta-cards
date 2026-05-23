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
$localePath = 'dmicher-kripta-cards/lang/ce.json'
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
  "lang": "ce",
  "name": "Нохчийн",
  "path": "lang/ce.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "Хьан Foundry декъашхо Криптан карташ модулехь серверехь ловзархочунца дӀахӀоттина дац. Ловзар хьехархочунга хьажа.",
  "KRIPTA.GMOnly": "ХӀара гӀуллакх ловзар хьехархочунна мара дӀахьош дац.",
  "KRIPTA.Settings.ServerUrl.Name": "Сервер адрес",
  "KRIPTA.Settings.TechAuthUsers.Name": "Технически лелархой",
  "KRIPTA.Settings.PlayerBindings.Name": "Foundry декъашхойн серверехь ловзархошца дӀахӀоттамаш",
  "KRIPTA.Settings.UiPrefs.Name": "Интерфейсах лаьрххӀа нисдарш",
  "KRIPTA.Settings.Menu.Name": "Криптан карташ",
  "KRIPTA.Settings.Menu.Label": "Модуль нисдар",
  "KRIPTA.Settings.Menu.Hint": "API-ца зӀе латтор а, технически лелархой а.",
  "KRIPTA.Settings.Help.BeforeServerLink": "Нагахь шу модулан контент-сервер хӀинца а дӀаяздина а, гӀирсина а дацахь, иза дан ",
  "KRIPTA.Settings.Help.ServerLink": "хӀокху ссылкехь",
  "KRIPTA.Settings.Help.AfterServerLink": " дӀагӀо. Сиха гӀирсинарна ",
  "KRIPTA.Settings.Help.DocumentationLink": "документаци",
  "KRIPTA.Settings.Help.AfterDocumentationLink": " пайда эца.",
  "KRIPTA.Window.Catalog": "Картийн каталог",
  "KRIPTA.Window.CardDetails": "Каталоган карта",
  "KRIPTA.Window.GiveCard": "Карта ло",
  "KRIPTA.Window.MyCards": "Ловзархочун карташ",
  "KRIPTA.Window.Players": "Ловзархойн урхалла",
  "KRIPTA.Window.Registry": "Ловзархойн реестр",
  "KRIPTA.Window.RequestCard": "Карта эца",
  "KRIPTA.Window.Settings": "Криптан карташ - Нисдарш",
  "KRIPTA.Window.UseCard": "Карта лело",
  "KRIPTA.Menu.Title": "Криптан карташ",
  "KRIPTA.Menu.Catalog": "Картийн каталог",
  "KRIPTA.Menu.GetCard": "Карта эца",
  "KRIPTA.Menu.MyCards": "Сан карташ",
  "KRIPTA.Menu.Players": "Ловзархойн урхалла",
  "KRIPTA.Label.Category": "Категори",
  "KRIPTA.Label.Mode": "Режим",
  "KRIPTA.Label.Card": "Карта",
  "KRIPTA.Label.Player": "Ловзархо",
  "KRIPTA.Label.Name": "ЦӀе",
  "KRIPTA.Label.Comment": "Комментари",
  "KRIPTA.Label.CardTypes": "Картийн тайпанаш",
  "KRIPTA.Label.Count": "Дуькъал",
  "KRIPTA.Label.ConfirmationCode": "ТӀечӀагӀдар код",
  "KRIPTA.Label.Id": "Идентификатор",
  "KRIPTA.Label.Key": "Ключ",
  "KRIPTA.Label.ServerUrl": "Сервере некъ",
  "KRIPTA.Label.Writer": "Яздархо (Writer)",
  "KRIPTA.Label.Reader": "Дешархо (Reader)",
  "KRIPTA.Label.Role": "Роль",
  "KRIPTA.Label.Binding": "ДӀахӀоттам",
  "KRIPTA.Role.GM": "Ловзар хьехархо",
  "KRIPTA.Role.Player": "Ловзархо",
  "KRIPTA.Status.InGame": "ловзарехь",
  "KRIPTA.Status.Offline": "ловзарехь дац",
  "KRIPTA.Binding.CardsIssued": "елла карташ:",
  "KRIPTA.Binding.NoCards": "карташ яц",
  "KRIPTA.Binding.NotBound": "ловзархо дӀахӀоттина вац, ловзархо харжа.",
  "KRIPTA.Binding.CardsCountHint": "Елла картийн тайпанийн дуькъал (цхьана хилараш лоруш дац)",
  "KRIPTA.Button.Add": "ТӀетоха",
  "KRIPTA.Button.Bind": "ДӀахӀотта",
  "KRIPTA.Button.Cancel": "Юхадаккха",
  "KRIPTA.Button.Close": "ДӀакъайла",
  "KRIPTA.Button.Confirm": "ТӀечӀагӀдан",
  "KRIPTA.Button.Delete": "ДӀадаккха",
  "KRIPTA.Button.Edit": "Хийца",
  "KRIPTA.Button.Give": "Ло",
  "KRIPTA.Button.GiveCard": "Карта ло",
  "KRIPTA.Button.Info": "Хаам",
  "KRIPTA.Button.No": "ХӀан-хӀа",
  "KRIPTA.Button.Output": "Гайта",
  "KRIPTA.Button.Refresh": "Керлаяккха",
  "KRIPTA.Button.Registry": "Ловзархойн реестр",
  "KRIPTA.Button.Request": "Деха",
  "KRIPTA.Button.RequestCard": "Эца",
  "KRIPTA.Button.SaveChanges": "Хийцамаш дӀаязде",
  "KRIPTA.Button.Take": "Эца",
  "KRIPTA.Button.TestAuth": "Технически лелархой талла",
  "KRIPTA.Button.TestServer": "Сервер талла",
  "KRIPTA.Button.Unbind": "ДӀахӀоттам дӀабаккха",
  "KRIPTA.Button.Use": "Лело",
  "KRIPTA.Button.Yes": "ХӀаъ",
  "KRIPTA.Mode.Manual": "Харжамца",
  "KRIPTA.Mode.Random": "Гучудаьлла",
  "KRIPTA.Mode.Show": "Гайта",
  "KRIPTA.Mode.Spend": "Сарфдан",
  "KRIPTA.View.Table": "Таблица",
  "KRIPTA.View.Tiles": "Плиткаш",
  "KRIPTA.Placeholder.Search": "Лаха",
  "KRIPTA.Select.NotSelected": "-- харжина дац --",
  "KRIPTA.Template.EmptyCatalog": "Серверехь регистраци йина категореш я карташ яц.",
  "KRIPTA.Template.MyCardsTitle": "Ловзархочун карташ: {playerName}",
  "KRIPTA.Template.UseCardMissing": "ХӀара карта серверехь кхин регистраци йина яц.",
  "KRIPTA.Template.UseCardPrompt": "Лело йина хир ю карта:",
  "KRIPTA.Card.FallbackName": "Карта {number}",
  "KRIPTA.Card.FallbackAddress": "Карта {level}/{number}",
  "KRIPTA.Card.MissingDescription": "Карта {level}/{number} серверийн карарчу каталогехь яц.",
  "KRIPTA.Card.NotRegisteredDescription": "Карта {level}/{number} серверехь кхин регистраци йина яц.",
  "KRIPTA.Level.FallbackName": "Барам {level}",
  "KRIPTA.Level.MissingDescription": "Барам ловзархочун инвентарехь бу, амма серверийн карарчу каталогехь бац.",
  "KRIPTA.Chat.BlobReadFailed": "BLOB деша ца хилла",
  "KRIPTA.Chat.CardGivenTitle": "Карта елла",
  "KRIPTA.Chat.CardReceiveSubtitle": "Ловзархо {playerName} {cardSubtitle} карта оьцу",
  "KRIPTA.Chat.CardRequestCanceled": "Картийн дехар юхадаьккхина.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "Картийн дехар тӀечӀагӀдина",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "Дехаран хаамаш деша ца хилла.",
  "KRIPTA.Chat.CardSpentFooter": "КАРТА САРФЙИНА",
  "KRIPTA.Chat.CardSpentTitle": "Карта сарфйина",
  "KRIPTA.Chat.FallbackPlayer": "ловзархо",
  "KRIPTA.Chat.ManualChoiceFooter": "КАРАХЬ ХАРЖАМ",
  "KRIPTA.Chat.ReferenceTitle": "ГӀо",
  "KRIPTA.Chat.RequestManualTitle": "Харжина карта дехар",
  "KRIPTA.Chat.RequestRandomTitle": "Гучудаьлла карта дехар",
  "KRIPTA.Chat.ShowCardTitle": "Картийн гӀо",
  "KRIPTA.Dialog.BindPlayer.Title": "Серверехь ловзархо дӀахӀотта",
  "KRIPTA.Dialog.BindPlayer.Header": "{foundryUserName} учун ловзархо харжа",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "Foundry лелархо",
  "KRIPTA.Dialog.Player.AddTitle": "Ловзархо тӀетоха",
  "KRIPTA.Dialog.Player.EditTitle": "Ловзархо хийца",
  "KRIPTA.Dialog.Player.DeleteTitle": "Ловзархо дӀаваккха",
  "KRIPTA.Dialog.Player.DeleteWarning": "\"{playerName}\" ловзархо дӀаваккхар юха хийца ца лору. \"{code}\" язде а, дӀаваккхар тӀечӀагӀде.",
  "KRIPTA.Dialog.Count.TotalCards": "хӀокху тайпанан карташ дерриг - {max}",
  "KRIPTA.Error.InvalidCardLevel": "{context} учун level нийса дац: {level}",
  "KRIPTA.Error.InvalidCardNumber": "{context} учун number нийса дац: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "картийн level нийса дац: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "картийн number нийса дац: {number}",
  "KRIPTA.Error.InvalidRequestCard": "Дехар учун карта нийса яц",
  "KRIPTA.Error.InvalidGiveCard": "Лоран карта нийса яц",
  "KRIPTA.Error.MissingRequestPlayerGuid": "Карта лоран playerGuid билгал ца хилла.",
  "KRIPTA.Error.MissingSelectedCard": "Харжина карта билгал ца хилла.",
  "KRIPTA.Error.MissingSelectedCardForGive": "Лоран харжина карта билгал ца хилла.",
  "KRIPTA.Error.MissingGivePlayer": "Карта лоран ловзархо билгал ца хилла.",
  "KRIPTA.Error.MissingGiveCard": "Лоран карта билгал ца хилла.",
  "KRIPTA.Error.MissingServerUrl": "Сервере некъ нисдар дац.",
  "KRIPTA.Error.InvalidReader": "Reader технически лелархо нийса нисдина вац.",
  "KRIPTA.Error.InvalidWriter": "Writer технически лелархо нийса нисдина вац.",
  "KRIPTA.Error.MenuUnavailable": "Функци болх беш яц. Модулан нисдарш талла. ТӀетохарш браузеран консолехь.",
  "KRIPTA.Error.Generic": "ГӀалат хилира",
  "KRIPTA.Error.Unknown": "девзаш доцу гӀалат",
  "KRIPTA.Error.NameRequired": "ЦӀеран майда тӀедожийна ду.",
  "KRIPTA.Error.RegistryDeleteReturned": "серверо дӀаваккхарна тӀаьхьа ловзархо реестре юха гайтина.",
  "KRIPTA.Notification.CardGiven": "Карта елла.",
  "KRIPTA.Notification.CardUsed": "Карта лелийна а, учетан дӀаяккхина а.",
  "KRIPTA.Notification.CardWrittenOff": "Карта учетан дӀаяккхина.",
  "KRIPTA.Notification.CannotUseMissingCard": "ХӀара карта серверехь кхин регистраци йина яц. Лело мега дац.",
  "KRIPTA.Notification.MissingCard": "ХӀара карта серверехь кхин регистраци йина яц.",
  "KRIPTA.Notification.PlayerNotSelected": "Карта лоран ловзархо харжина вац",
  "KRIPTA.Notification.PlayerBindingMissing": "Карта лоран ловзархочун дӀахӀоттам билгал ца хилла",
  "KRIPTA.Notification.RequestSent": "Картийн дехар чат чу дӀадахьийтина.",
  "KRIPTA.Notification.ServerSuccess": "ЗӀе латтор кхиамца.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "ЗӀе латтор кхиамца. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "Серверца зӀе латто ца хилла. Адрес, сервер болх а, CORS/HTTPS нисдарш а талла.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "Сервер талла ца хилла.",
  "KRIPTA.Notification.InvalidServerUrl": "Сервер адрес нийса дац: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "«Криптан карташ» нисдарш дакъа «Ведущий» а, «Ведущин гӀоьнча» а ролашна мара дац.",
  "KRIPTA.Notification.ServerCheckFailed": "Сервер таллар кхиам боцуш хилира",
  "KRIPTA.Notification.TechUserReader": "Дешархо",
  "KRIPTA.Notification.TechUserWriter": "Яздархо",
  "KRIPTA.Notification.TechUsersCheckSuccess": "\"Reader\" а, \"Writer\" а технически лелархой таллар кхиамца дӀакхоьду.",
  "KRIPTA.Notification.SettingsSaved": "ЗӀе латторан нисдарш дӀаяздина.",
  "KRIPTA.Notification.PlayerAdded": "Ловзархо тӀетохийна.",
  "KRIPTA.Notification.PlayerUpdated": "Ловзархо керла вуккхина.",
  "KRIPTA.Notification.PlayerDeleted": "Ловзархо дӀаваккхина.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "ДӀаваккхар юхадаьккхина. Контроль майда нийса язйина яц.",
  "KRIPTA.Notification.BindingSaved": "ДӀахӀоттам дӀаяздина.",
  "KRIPTA.Notification.BindingDeleted": "ДӀахӀоттам дӀабаккхина.",
  "KRIPTA.Notification.BadCatalogCardNumber": "Харжина картийн номер нийса дац. getCardsList жоп а, normalizeCardsList а талла.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "ХӀара карта карахь ло мегаш яц: цуьнан номер нийса дац. getCardsList жоп а, normalizeCardsList а талла.",
  "KRIPTA.Notification.CardOutputFailed": "Карта чатехь гайта ца хилла",
  "KRIPTA.Notification.CardGiveFailed": "Карта ло ца хилла",
  "KRIPTA.Notification.CardUseFailed": "Карта лело ца хилла",
  "KRIPTA.Notification.CardTakeFailed": "Карта учетан дӀаяккха ца хилла",
  "KRIPTA.Notification.CardRequestFailed": "Картийн дехар дӀадахьийта ца хилла",
  "KRIPTA.Notification.CardRequestConfirmFailed": "Карта лор тӀечӀагӀдан ца хилла",
  "KRIPTA.Notification.PlayerAddFailed": "Ловзархо тӀетоха ца хилла",
  "KRIPTA.Notification.PlayerUpdateFailed": "Ловзархо керла вуьккхина ца хилла",
  "KRIPTA.Notification.PlayerDeleteFailed": "Ловзархо дӀаваккха ца хилла",
  "KRIPTA.Notification.CardRollFailed": "Карта эца ца хилла.",
  "KRIPTA.Dialog.TakeCard.Title": "Карта эца",
  "KRIPTA.Dialog.TakeCard.Message": "Ловзархо {playerName} {cardName} картаца дӀакъовлур ву.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Карта ло"
}
__END_LOCALE_JSON__
