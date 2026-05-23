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
$localePath = 'dmicher-kripta-cards/lang/kk.json'
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
  "lang": "kk",
  "name": "Қазақша",
  "path": "lang/kk.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "Foundry пайдаланушыңыз Kripta Cards модулінде сервер ойыншысымен байланыстырылмаған. Ойын шеберіне хабарласыңыз.",
  "KRIPTA.GMOnly": "Бұл әрекет тек ойын шеберіне қолжетімді.",
  "KRIPTA.Settings.ServerUrl.Name": "Сервер мекенжайы",
  "KRIPTA.Settings.TechAuthUsers.Name": "Техникалық пайдаланушылар",
  "KRIPTA.Settings.PlayerBindings.Name": "Foundry пайдаланушыларын сервер ойыншыларымен байланыстыру",
  "KRIPTA.Settings.UiPrefs.Name": "Жергілікті интерфейс баптаулары",
  "KRIPTA.Settings.Menu.Name": "Kripta Cards",
  "KRIPTA.Settings.Menu.Label": "Модуль баптаулары",
  "KRIPTA.Settings.Menu.Hint": "API қосылымы және техникалық пайдаланушылар.",
  "KRIPTA.Settings.Help.BeforeServerLink": "Егер модульге арналған контент серверін әлі орнатып, баптамаған болсаңыз, мұны істеу үшін ",
  "KRIPTA.Settings.Help.ServerLink": "осы сілтемеге",
  "KRIPTA.Settings.Help.AfterServerLink": " өтіңіз. Жылдам баптау үшін ",
  "KRIPTA.Settings.Help.DocumentationLink": "құжаттаманы",
  "KRIPTA.Settings.Help.AfterDocumentationLink": " пайдаланыңыз.",
  "KRIPTA.Window.Catalog": "Карталар каталогы",
  "KRIPTA.Window.CardDetails": "Каталог картасы",
  "KRIPTA.Window.GiveCard": "Карта беру",
  "KRIPTA.Window.MyCards": "Ойыншы карталары",
  "KRIPTA.Window.Players": "Ойыншыларды басқару",
  "KRIPTA.Window.Registry": "Ойыншылар тізілімі",
  "KRIPTA.Window.RequestCard": "Карта сұрау",
  "KRIPTA.Window.Settings": "Kripta Cards - Баптаулар",
  "KRIPTA.Window.UseCard": "Картаны пайдалану",
  "KRIPTA.Menu.Title": "Kripta Cards",
  "KRIPTA.Menu.Catalog": "Карталар каталогы",
  "KRIPTA.Menu.GetCard": "Карта сұрау",
  "KRIPTA.Menu.MyCards": "Менің карталарым",
  "KRIPTA.Menu.Players": "Ойыншыларды басқару",
  "KRIPTA.Label.Category": "Санат",
  "KRIPTA.Label.Mode": "Режим",
  "KRIPTA.Label.Card": "Карта",
  "KRIPTA.Label.Player": "Ойыншы",
  "KRIPTA.Label.Name": "Аты",
  "KRIPTA.Label.Comment": "Пікір",
  "KRIPTA.Label.CardTypes": "Карта түрлері",
  "KRIPTA.Label.Count": "Саны",
  "KRIPTA.Label.ConfirmationCode": "Растау коды",
  "KRIPTA.Label.Id": "Id",
  "KRIPTA.Label.Key": "Key",
  "KRIPTA.Label.ServerUrl": "Сервер URL",
  "KRIPTA.Label.Writer": "Writer",
  "KRIPTA.Label.Reader": "Reader",
  "KRIPTA.Label.Role": "Рөл",
  "KRIPTA.Label.Binding": "Байланыс",
  "KRIPTA.Role.GM": "Ойын шебері",
  "KRIPTA.Role.Player": "Ойыншы",
  "KRIPTA.Status.InGame": "онлайн",
  "KRIPTA.Status.Offline": "офлайн",
  "KRIPTA.Binding.CardsIssued": "берілген карталар:",
  "KRIPTA.Binding.NoCards": "карта жоқ",
  "KRIPTA.Binding.NotBound": "ойыншы байланыстырылмаған, ойыншыны байланыстырыңыз.",
  "KRIPTA.Binding.CardsCountHint": "Қайталауларды есептемегендегі берілген карта түрлерінің саны",
  "KRIPTA.Button.Add": "Қосу",
  "KRIPTA.Button.Bind": "Байланыстыру",
  "KRIPTA.Button.Cancel": "Болдырмау",
  "KRIPTA.Button.Close": "Жабу",
  "KRIPTA.Button.Confirm": "Растау",
  "KRIPTA.Button.Delete": "Жою",
  "KRIPTA.Button.Edit": "Өзгерту",
  "KRIPTA.Button.Give": "Беру",
  "KRIPTA.Button.GiveCard": "Карта беру",
  "KRIPTA.Button.Info": "Ақпарат",
  "KRIPTA.Button.No": "Жоқ",
  "KRIPTA.Button.Output": "Жариялау",
  "KRIPTA.Button.Refresh": "Жаңарту",
  "KRIPTA.Button.Registry": "Ойыншылар тізілімі",
  "KRIPTA.Button.Request": "Сұрау",
  "KRIPTA.Button.RequestCard": "Сұрау",
  "KRIPTA.Button.SaveChanges": "Өзгерістерді сақтау",
  "KRIPTA.Button.Take": "Алу",
  "KRIPTA.Button.TestAuth": "Техникалық пайдаланушыларды тексеру",
  "KRIPTA.Button.TestServer": "Серверді тексеру",
  "KRIPTA.Button.Unbind": "Байланысты үзу",
  "KRIPTA.Button.Use": "Пайдалану",
  "KRIPTA.Button.Yes": "Иә",
  "KRIPTA.Mode.Manual": "Қолмен таңдау",
  "KRIPTA.Mode.Random": "Кездейсоқ",
  "KRIPTA.Mode.Show": "Көрсету",
  "KRIPTA.Mode.Spend": "Жұмсау",
  "KRIPTA.View.Table": "Кесте",
  "KRIPTA.View.Tiles": "Плиткалар",
  "KRIPTA.Placeholder.Search": "Іздеу",
  "KRIPTA.Select.NotSelected": "-- таңдалмаған --",
  "KRIPTA.Template.EmptyCatalog": "Серверде тіркелген санаттар немесе карталар жоқ.",
  "KRIPTA.Template.MyCardsTitle": "Ойыншы карталары: {playerName}",
  "KRIPTA.Template.UseCardMissing": "Бұл карта енді серверде тіркелмеген.",
  "KRIPTA.Template.UseCardPrompt": "Бұл карта пайдаланылады:",
  "KRIPTA.Card.FallbackName": "Карта {number}",
  "KRIPTA.Card.FallbackAddress": "Карта {level}/{number}",
  "KRIPTA.Card.MissingDescription": "Карта {level}/{number} ағымдағы сервер каталогында жоқ.",
  "KRIPTA.Card.NotRegisteredDescription": "Карта {level}/{number} енді серверде тіркелмеген.",
  "KRIPTA.Level.FallbackName": "Деңгей {level}",
  "KRIPTA.Level.MissingDescription": "Бұл деңгей ойыншының инвентарында бар, бірақ ағымдағы сервер каталогында жоқ.",
  "KRIPTA.Chat.BlobReadFailed": "blob оқылмады",
  "KRIPTA.Chat.CardGivenTitle": "Карта берілді",
  "KRIPTA.Chat.CardReceiveSubtitle": "Ойыншы {playerName} {cardSubtitle} картасын алады",
  "KRIPTA.Chat.CardRequestCanceled": "Карта сұрауы болдырылмады.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "Карта сұрауы расталды",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "Сұрау деректері оқылмады.",
  "KRIPTA.Chat.CardSpentFooter": "КАРТА ЖҰМСАЛДЫ",
  "KRIPTA.Chat.CardSpentTitle": "Карта жұмсалды",
  "KRIPTA.Chat.FallbackPlayer": "ойыншы",
  "KRIPTA.Chat.ManualChoiceFooter": "ҚОЛМЕН ТАҢДАУ",
  "KRIPTA.Chat.ReferenceTitle": "Анықтама",
  "KRIPTA.Chat.RequestManualTitle": "Таңдалған карта сұрауы",
  "KRIPTA.Chat.RequestRandomTitle": "Кездейсоқ карта сұрауы",
  "KRIPTA.Chat.ShowCardTitle": "Карта анықтамасы",
  "KRIPTA.Dialog.BindPlayer.Title": "Сервер ойыншысын байланыстыру",
  "KRIPTA.Dialog.BindPlayer.Header": "{foundryUserName} үшін ойыншы таңдаңыз",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "Foundry пайдаланушысы",
  "KRIPTA.Dialog.Player.AddTitle": "Ойыншы қосу",
  "KRIPTA.Dialog.Player.EditTitle": "Ойыншыны өзгерту",
  "KRIPTA.Dialog.Player.DeleteTitle": "Ойыншыны жою",
  "KRIPTA.Dialog.Player.DeleteWarning": "\"{playerName}\" ойыншысын жоюды қайтару мүмкін емес. \"{code}\" енгізіп, жоюды растаңыз.",
  "KRIPTA.Dialog.Count.TotalCards": "осы түрдегі жалпы карталар - {max}",
  "KRIPTA.Error.InvalidCardLevel": "{context} үшін қате деңгей: {level}",
  "KRIPTA.Error.InvalidCardNumber": "{context} үшін қате нөмір: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "қате карта деңгейі: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "қате карта нөмірі: {number}",
  "KRIPTA.Error.InvalidRequestCard": "Сұрау үшін қате карта",
  "KRIPTA.Error.InvalidGiveCard": "Беру үшін қате карта",
  "KRIPTA.Error.MissingRequestPlayerGuid": "Карта беру үшін playerGuid анықталмады.",
  "KRIPTA.Error.MissingSelectedCard": "Таңдалған карта анықталмады.",
  "KRIPTA.Error.MissingSelectedCardForGive": "Беру үшін таңдалған карта анықталмады.",
  "KRIPTA.Error.MissingGivePlayer": "Карта берілетін ойыншы анықталмады.",
  "KRIPTA.Error.MissingGiveCard": "Берілетін карта анықталмады.",
  "KRIPTA.Error.MissingServerUrl": "Сервер жолының баптауы жоқ.",
  "KRIPTA.Error.InvalidReader": "Reader техникалық пайдаланушысы қате бапталған.",
  "KRIPTA.Error.InvalidWriter": "Writer техникалық пайдаланушысы қате бапталған.",
  "KRIPTA.Error.MenuUnavailable": "Бұл функция қолжетімді емес. Модуль баптауларын тексеріңіз. Толығырақ браузер консолінде.",
  "KRIPTA.Error.Generic": "Қате орын алды",
  "KRIPTA.Error.Unknown": "белгісіз қате",
  "KRIPTA.Error.NameRequired": "Name өрісі міндетті.",
  "KRIPTA.Error.RegistryDeleteReturned": "жоюдан кейін сервер ойыншыны тізілімде қайтарды.",
  "KRIPTA.Notification.CardGiven": "Карта берілді.",
  "KRIPTA.Notification.CardUsed": "Карта пайдаланылып, жұмсалды.",
  "KRIPTA.Notification.CardWrittenOff": "Карта алынып тасталды.",
  "KRIPTA.Notification.CannotUseMissingCard": "Бұл карта енді серверде тіркелмеген. Оны пайдалану мүмкін емес.",
  "KRIPTA.Notification.MissingCard": "Бұл карта енді серверде тіркелмеген.",
  "KRIPTA.Notification.PlayerNotSelected": "Карта беру үшін ойыншы таңдалмаған",
  "KRIPTA.Notification.PlayerBindingMissing": "Карта беру үшін ойыншы байланысы анықталмады",
  "KRIPTA.Notification.RequestSent": "Карта сұрауы чатқа жіберілді.",
  "KRIPTA.Notification.ServerSuccess": "Қосылым сәтті.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "Қосылым сәтті. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "Серверге қосылу мүмкін болмады. Мекенжайды, сервер қолжетімділігін және CORS/HTTPS баптауларын тексеріңіз.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "Сервер тексерілмеді.",
  "KRIPTA.Notification.InvalidServerUrl": "Қате сервер мекенжайы: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "Kripta Cards баптаулары бөлімі тек Ойын шебері және Ойын шеберінің көмекшісі рөлдері үшін қолжетімді.",
  "KRIPTA.Notification.ServerCheckFailed": "Сервер тексерісі сәтсіз",
  "KRIPTA.Notification.TechUserReader": "Reader",
  "KRIPTA.Notification.TechUserWriter": "Writer",
  "KRIPTA.Notification.TechUsersCheckSuccess": "\"Reader\" және \"Writer\" техникалық пайдаланушылары тексерістен өтті.",
  "KRIPTA.Notification.SettingsSaved": "Қосылым баптаулары сақталды.",
  "KRIPTA.Notification.PlayerAdded": "Ойыншы қосылды.",
  "KRIPTA.Notification.PlayerUpdated": "Ойыншы жаңартылды.",
  "KRIPTA.Notification.PlayerDeleted": "Ойыншы жойылды.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "Жою болдырылмады. Растау өрісі қате толтырылған.",
  "KRIPTA.Notification.BindingSaved": "Байланыс сақталды.",
  "KRIPTA.Notification.BindingDeleted": "Байланыс жойылды.",
  "KRIPTA.Notification.BadCatalogCardNumber": "Таңдалған картаның нөмірі қате. getCardsList жауабын және normalizeCardsList-ті тексеріңіз.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "Бұл картаны қолмен беру мүмкін емес, себебі оның нөмірі қате. getCardsList жауабын және normalizeCardsList-ті тексеріңіз.",
  "KRIPTA.Notification.CardOutputFailed": "Картаны чатқа жариялау мүмкін болмады",
  "KRIPTA.Notification.CardGiveFailed": "Карта беру мүмкін болмады",
  "KRIPTA.Notification.CardUseFailed": "Картаны пайдалану мүмкін болмады",
  "KRIPTA.Notification.CardTakeFailed": "Картаны алып тастау мүмкін болмады",
  "KRIPTA.Notification.CardRequestFailed": "Карта сұрауын жіберу мүмкін болмады",
  "KRIPTA.Notification.CardRequestConfirmFailed": "Карта беруді растау мүмкін болмады",
  "KRIPTA.Notification.PlayerAddFailed": "Ойыншы қосу мүмкін болмады",
  "KRIPTA.Notification.PlayerUpdateFailed": "Ойыншыны жаңарту мүмкін болмады",
  "KRIPTA.Notification.PlayerDeleteFailed": "Ойыншыны жою мүмкін болмады",
  "KRIPTA.Notification.CardRollFailed": "Карта алу мүмкін болмады.",
  "KRIPTA.Dialog.TakeCard.Title": "Картаны алу",
  "KRIPTA.Dialog.TakeCard.Message": "Ойыншы {playerName} {cardName} картасынан айырылады.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Карта беру"
}
__END_LOCALE_JSON__
