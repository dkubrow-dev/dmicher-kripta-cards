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
$localePath = 'dmicher-kripta-cards/lang/av.json'
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
  "lang": "av",
  "name": "МагӀарул мацӀ",
  "path": "lang/av.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "Дуда Foundry участник Криптая карталъул модулалда сервериялъул игрокасде цӀунизе гьечӀо. ХӀалмагъалъул мастерде гьари.",
  "KRIPTA.GMOnly": "Гьаб хӀалтӀи хӀалмагъалъул мастердасанго ккола.",
  "KRIPTA.Settings.ServerUrl.Name": "Сервериялъул адрес",
  "KRIPTA.Settings.TechAuthUsers.Name": "Техникиялъул пайдаланавиял",
  "KRIPTA.Settings.PlayerBindings.Name": "Foundry участникал сервериялъул игрокалде цӀуни",
  "KRIPTA.Settings.UiPrefs.Name": "Интерфейсалъул махӀалиялъул настройкаял",
  "KRIPTA.Settings.Menu.Name": "Криптая картал",
  "KRIPTA.Settings.Menu.Label": "Модулалъул настройка",
  "KRIPTA.Settings.Menu.Hint": "API-де цӀуни ва техникиялъул пайдаланавиял.",
  "KRIPTA.Settings.Help.BeforeServerLink": "Модулалъул контенталъул сервер гьанже биччачӀого ва гӀуцӀичӀого бугони, гьеб гьабизе ",
  "KRIPTA.Settings.Help.ServerLink": "гьаб ссылка",
  "KRIPTA.Settings.Help.AfterServerLink": " бихьизабе. Хадуб кӀвараб гӀуцӀизе ",
  "KRIPTA.Settings.Help.DocumentationLink": "документация",
  "KRIPTA.Settings.Help.AfterDocumentationLink": " пайда босе.",
  "KRIPTA.Window.Catalog": "Карталъул каталог",
  "KRIPTA.Window.CardDetails": "Каталогалъул карта",
  "KRIPTA.Window.GiveCard": "Карта кьезе",
  "KRIPTA.Window.MyCards": "Игрокасул картал",
  "KRIPTA.Window.Players": "Игрокалгун хӀалтӀи",
  "KRIPTA.Window.Registry": "Игрокалъул реестр",
  "KRIPTA.Window.RequestCard": "Карта босизе",
  "KRIPTA.Window.Settings": "Криптая картал - Настройкаял",
  "KRIPTA.Window.UseCard": "Карта пайда босизе",
  "KRIPTA.Menu.Title": "Криптая картал",
  "KRIPTA.Menu.Catalog": "Карталъул каталог",
  "KRIPTA.Menu.GetCard": "Карта босизе",
  "KRIPTA.Menu.MyCards": "Дир картал",
  "KRIPTA.Menu.Players": "Игрокалгун хӀалтӀи",
  "KRIPTA.Label.Category": "Категория",
  "KRIPTA.Label.Mode": "Режим",
  "KRIPTA.Label.Card": "Карта",
  "KRIPTA.Label.Player": "Игрок",
  "KRIPTA.Label.Name": "ЦӀар",
  "KRIPTA.Label.Comment": "Комментарий",
  "KRIPTA.Label.CardTypes": "Карталъул тайпаби",
  "KRIPTA.Label.Count": "Къадар",
  "KRIPTA.Label.ConfirmationCode": "Тасдикъалъул код",
  "KRIPTA.Label.Id": "Идентификатор",
  "KRIPTA.Label.Key": "Ключ",
  "KRIPTA.Label.ServerUrl": "Сервериялъухъе нух",
  "KRIPTA.Label.Writer": "Хъвадарухъан (Writer)",
  "KRIPTA.Label.Reader": "ЦӀалдарухъан (Reader)",
  "KRIPTA.Label.Role": "Роль",
  "KRIPTA.Label.Binding": "ЦӀуни",
  "KRIPTA.Role.GM": "Мастер",
  "KRIPTA.Role.Player": "Игрок",
  "KRIPTA.Status.InGame": "хӀалмагъалъулъ",
  "KRIPTA.Status.Offline": "хӀалмагъалъулъ гьечӀо",
  "KRIPTA.Binding.CardsIssued": "кьурал картал:",
  "KRIPTA.Binding.NoCards": "картал гьечӀо",
  "KRIPTA.Binding.NotBound": "игрок цӀунизе гьечӀо, игрок вищ.",
  "KRIPTA.Binding.CardsCountHint": "Кьурал карталъул тайпабазул къадар (такрарлъи хӀисабизе гьечӀо)",
  "KRIPTA.Button.Add": "ТӀаде жубазе",
  "KRIPTA.Button.Bind": "ЦӀунизе",
  "KRIPTA.Button.Cancel": "Бекаризе",
  "KRIPTA.Button.Close": "Къанлъизе",
  "KRIPTA.Button.Confirm": "Тасдикъизе",
  "KRIPTA.Button.Delete": "Батизе",
  "KRIPTA.Button.Edit": "Хисизе",
  "KRIPTA.Button.Give": "Кьезе",
  "KRIPTA.Button.GiveCard": "Карта кьезе",
  "KRIPTA.Button.Info": "Маълумат",
  "KRIPTA.Button.No": "ГьечӀо",
  "KRIPTA.Button.Output": "Бихьизабизе",
  "KRIPTA.Button.Refresh": "ЦӀиябизе",
  "KRIPTA.Button.Registry": "Игрокалъул реестр",
  "KRIPTA.Button.Request": "Талаб гьабизе",
  "KRIPTA.Button.RequestCard": "Босизе",
  "KRIPTA.Button.SaveChanges": "Хисиял цӀунизе",
  "KRIPTA.Button.Take": "Босизе",
  "KRIPTA.Button.TestAuth": "Техникиялъул пайдаланавиял хал гьаризе",
  "KRIPTA.Button.TestServer": "Сервер хал гьабизе",
  "KRIPTA.Button.Unbind": "ЦӀуни хъвахъизе",
  "KRIPTA.Button.Use": "Пайда босизе",
  "KRIPTA.Button.Yes": "Гьай",
  "KRIPTA.Mode.Manual": "Вищизе",
  "KRIPTA.Mode.Random": "Случайнияб",
  "KRIPTA.Mode.Show": "Бихьизабизе",
  "KRIPTA.Mode.Spend": "Сарф гьабизе",
  "KRIPTA.View.Table": "Таблица",
  "KRIPTA.View.Tiles": "Плиткаял",
  "KRIPTA.Placeholder.Search": "Лахъи",
  "KRIPTA.Select.NotSelected": "-- вищун гьечӀо --",
  "KRIPTA.Template.EmptyCatalog": "Сервериялда регистрация гьабура категориял я картал гьечӀо.",
  "KRIPTA.Template.MyCardsTitle": "Игрокасул картал: {playerName}",
  "KRIPTA.Template.UseCardMissing": "Гьаб карта сервериялда къваридал регистрация гьабура гьечӀо.",
  "KRIPTA.Template.UseCardPrompt": "Пайда босила карта:",
  "KRIPTA.Card.FallbackName": "Карта {number}",
  "KRIPTA.Card.FallbackAddress": "Карта {level}/{number}",
  "KRIPTA.Card.MissingDescription": "Карта {level}/{number} сервериялъул гьанжесеб каталогалда гьечӀо.",
  "KRIPTA.Card.NotRegisteredDescription": "Карта {level}/{number} сервериялда къваридал регистрация гьабура гьечӀо.",
  "KRIPTA.Level.FallbackName": "Даража {level}",
  "KRIPTA.Level.MissingDescription": "Даража игрокасул инвентаралда буго, амма сервериялъул гьанжесеб каталогалда гьечӀо.",
  "KRIPTA.Chat.BlobReadFailed": "BLOB цӀализе кколаро",
  "KRIPTA.Chat.CardGivenTitle": "Карта кьуна",
  "KRIPTA.Chat.CardReceiveSubtitle": "Игрок {playerName} {cardSubtitle} карта босула",
  "KRIPTA.Chat.CardRequestCanceled": "Карта талаб бекаризе гьабуна.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "Карта талаб тасдикъ гьабуна",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "Талабалъул маълумат цӀализе кколаро.",
  "KRIPTA.Chat.CardSpentFooter": "КАРТА САРФ ГЬАБУНА",
  "KRIPTA.Chat.CardSpentTitle": "Карта сарф гьабуна",
  "KRIPTA.Chat.FallbackPlayer": "игрок",
  "KRIPTA.Chat.ManualChoiceFooter": "КЪОБОН ВИЩИ",
  "KRIPTA.Chat.ReferenceTitle": "Кумек",
  "KRIPTA.Chat.RequestManualTitle": "Вищара карталъул талаб",
  "KRIPTA.Chat.RequestRandomTitle": "Случайнияб карталъул талаб",
  "KRIPTA.Chat.ShowCardTitle": "Картаялъул кумек",
  "KRIPTA.Dialog.BindPlayer.Title": "Сервериялъул игрок цӀунизе",
  "KRIPTA.Dialog.BindPlayer.Header": "{foundryUserName} учун игрок вищизе",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "Foundry пайдаланав",
  "KRIPTA.Dialog.Player.AddTitle": "Игрок тӀаде жубазе",
  "KRIPTA.Dialog.Player.EditTitle": "Игрок хисизе",
  "KRIPTA.Dialog.Player.DeleteTitle": "Игрок батизе",
  "KRIPTA.Dialog.Player.DeleteWarning": "\"{playerName}\" игрок батизе юха ккун гьечӀо. \"{code}\" хъвай ва батизе тасдикъ гьабе.",
  "KRIPTA.Dialog.Count.TotalCards": "гьаб тайпа картал жамагӀат - {max}",
  "KRIPTA.Error.InvalidCardLevel": "{context} учун level дурус гьечӀо: {level}",
  "KRIPTA.Error.InvalidCardNumber": "{context} учун number дурус гьечӀо: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "картаялъул level дурус гьечӀо: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "картаялъул number дурус гьечӀо: {number}",
  "KRIPTA.Error.InvalidRequestCard": "Талаб учун карта дурус гьечӀо",
  "KRIPTA.Error.InvalidGiveCard": "Кьезе карта дурус гьечӀо",
  "KRIPTA.Error.MissingRequestPlayerGuid": "Карта кьезе playerGuid бихьизабизе кколаро.",
  "KRIPTA.Error.MissingSelectedCard": "Вищара карта бихьизабизе кколаро.",
  "KRIPTA.Error.MissingSelectedCardForGive": "Кьезе вищара карта бихьизабизе кколаро.",
  "KRIPTA.Error.MissingGivePlayer": "Карта кьезе игрок бихьизабизе кколаро.",
  "KRIPTA.Error.MissingGiveCard": "Кьезе карта бихьизабизе кколаро.",
  "KRIPTA.Error.MissingServerUrl": "Сервериялъухъе нухалъул настройка гьечӀо.",
  "KRIPTA.Error.InvalidReader": "Reader техникиялъул пайдаланав дурус гьабун гьечӀо.",
  "KRIPTA.Error.InvalidWriter": "Writer техникиялъул пайдаланав дурус гьабун гьечӀо.",
  "KRIPTA.Error.MenuUnavailable": "Функция хӀалтӀулеб гьечӀо. Модулалъул настройкаял хал гьаре. Тафсилот браузериялъул консолалда.",
  "KRIPTA.Error.Generic": "ХатӀа ккана",
  "KRIPTA.Error.Unknown": "лъалареб хатӀа",
  "KRIPTA.Error.NameRequired": "ЦӀаралъул майдан тӀаде тӀамуна.",
  "KRIPTA.Error.RegistryDeleteReturned": "сервер батизе гьабулебалдаса хадуб игрок реестрде юха кьуна.",
  "KRIPTA.Notification.CardGiven": "Карта кьуна.",
  "KRIPTA.Notification.CardUsed": "Карта пайда босана ва учеталдаса батана.",
  "KRIPTA.Notification.CardWrittenOff": "Карта учеталдаса батана.",
  "KRIPTA.Notification.CannotUseMissingCard": "Гьаб карта сервериялда къваридал регистрация гьабура гьечӀо. Пайда босизе кколаро.",
  "KRIPTA.Notification.MissingCard": "Гьаб карта сервериялда къваридал регистрация гьабура гьечӀо.",
  "KRIPTA.Notification.PlayerNotSelected": "Карта кьезе игрок вищун гьечӀо",
  "KRIPTA.Notification.PlayerBindingMissing": "Карта кьезе игрокасул цӀуни бихьизабизе кколаро",
  "KRIPTA.Notification.RequestSent": "Карта талаб чатде рехун буго.",
  "KRIPTA.Notification.ServerSuccess": "ЦӀуни кколеб буго.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "ЦӀуни кколеб буго. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "Серверде цӀуни кколаро. Адрес, сервериялъул хӀалтӀи ва CORS/HTTPS настройкаял хал гьаре.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "Сервер хал гьабизе кколаро.",
  "KRIPTA.Notification.InvalidServerUrl": "Сервер адрес дурус гьечӀо: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "«Криптая картал» настройкаялъул раздел «Ведущий» ва «Ведущий помощник» ролалъулъего ккола.",
  "KRIPTA.Notification.ServerCheckFailed": "Сервер хал гьаби кколаро",
  "KRIPTA.Notification.TechUserReader": "ЦӀалдарухъан",
  "KRIPTA.Notification.TechUserWriter": "Хъвадарухъан",
  "KRIPTA.Notification.TechUsersCheckSuccess": "\"Reader\" ва \"Writer\" техникиялъул пайдаланавиял хал гьабиялдаса къваридал тӀолеб буго.",
  "KRIPTA.Notification.SettingsSaved": "ЦӀуниялъул настройкаял цӀунана.",
  "KRIPTA.Notification.PlayerAdded": "Игрок тӀаде жубана.",
  "KRIPTA.Notification.PlayerUpdated": "Игрок цӀиябана.",
  "KRIPTA.Notification.PlayerDeleted": "Игрок батана.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "Бати бекар гьабуна. Контроль майдан дурус цӀун гьечӀо.",
  "KRIPTA.Notification.BindingSaved": "ЦӀуни цӀунана.",
  "KRIPTA.Notification.BindingDeleted": "ЦӀуни батана.",
  "KRIPTA.Notification.BadCatalogCardNumber": "Вищара картаялъул номер дурус гьечӀо. getCardsList жаваб ва normalizeCardsList хал гьаре.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "Гьаб карта къоялда кьезе кколаро: цебесеб номер дурус гьечӀо. getCardsList жаваб ва normalizeCardsList хал гьаре.",
  "KRIPTA.Notification.CardOutputFailed": "Карта чаталда бихьизабизе кколаро",
  "KRIPTA.Notification.CardGiveFailed": "Карта кьезе кколаро",
  "KRIPTA.Notification.CardUseFailed": "Карта пайда босизе кколаро",
  "KRIPTA.Notification.CardTakeFailed": "Карта учеталдаса батизе кколаро",
  "KRIPTA.Notification.CardRequestFailed": "Карта талаб рехизе кколаро",
  "KRIPTA.Notification.CardRequestConfirmFailed": "Карта кьезе тасдикъ гьабизе кколаро",
  "KRIPTA.Notification.PlayerAddFailed": "Игрок тӀаде жубазе кколаро",
  "KRIPTA.Notification.PlayerUpdateFailed": "Игрок цӀиябизе кколаро",
  "KRIPTA.Notification.PlayerDeleteFailed": "Игрок батизе кколаро",
  "KRIPTA.Notification.CardRollFailed": "Карта босизе кколаро.",
  "KRIPTA.Dialog.TakeCard.Title": "Карта босизе",
  "KRIPTA.Dialog.TakeCard.Message": "Игрок {playerName} {cardName} картаялдаса махрум гьавила.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Карта кьезе"
}
__END_LOCALE_JSON__
