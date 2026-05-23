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
$localePath = 'dmicher-kripta-cards/lang/ha.json'
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
  "lang": "ha",
  "name": "Hausa",
  "path": "lang/ha.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "Mai amfani na Foundry ɗinka ba a haɗa shi da Ɗan Wasan Sabar a cikin modulin Katunan Kripta ba. Tuntuɓi Jagoran Wasa.",
  "KRIPTA.GMOnly": "Wannan aiki yana samuwa ga Jagoran Wasa kawai.",
  "KRIPTA.Settings.ServerUrl.Name": "Adireshin sabar",
  "KRIPTA.Settings.TechAuthUsers.Name": "Masu amfani na fasaha",
  "KRIPTA.Settings.PlayerBindings.Name": "Haɗin masu amfani na Foundry da 'yan wasan sabar",
  "KRIPTA.Settings.UiPrefs.Name": "Saitunan ƙaramar mu'amala",
  "KRIPTA.Settings.Menu.Name": "Katunan Kripta",
  "KRIPTA.Settings.Menu.Label": "Saitunan moduli",
  "KRIPTA.Settings.Menu.Hint": "Haɗin API da masu amfani na fasaha.",
  "KRIPTA.Settings.Help.BeforeServerLink": "Idan ba ku riga kun shigar kuma kun saita uwar garken abun ciki na mod ɗin ba, bi ",
  "KRIPTA.Settings.Help.ServerLink": "wannan hanyar haɗi",
  "KRIPTA.Settings.Help.AfterServerLink": " don yin hakan. Don saitawa cikin sauri, yi amfani da ",
  "KRIPTA.Settings.Help.DocumentationLink": "takardun bayani",
  "KRIPTA.Settings.Help.AfterDocumentationLink": ".",
  "KRIPTA.Window.Catalog": "Katalojin Katuna",
  "KRIPTA.Window.CardDetails": "Katin Kataloji",
  "KRIPTA.Window.GiveCard": "Ba da Kati",
  "KRIPTA.Window.MyCards": "Katunan Ɗan Wasa",
  "KRIPTA.Window.Players": "Sarrafa 'Yan Wasa",
  "KRIPTA.Window.Registry": "Rajistar 'Yan Wasa",
  "KRIPTA.Window.RequestCard": "Nemi Kati",
  "KRIPTA.Window.Settings": "Katunan Kripta - Saituna",
  "KRIPTA.Window.UseCard": "Yi Amfani da Kati",
  "KRIPTA.Menu.Title": "Katunan Kripta",
  "KRIPTA.Menu.Catalog": "Katalojin Katuna",
  "KRIPTA.Menu.GetCard": "Nemi Kati",
  "KRIPTA.Menu.MyCards": "Katuna Na",
  "KRIPTA.Menu.Players": "Sarrafa 'Yan Wasa",
  "KRIPTA.Label.Category": "Rukuni",
  "KRIPTA.Label.Mode": "Yanayi",
  "KRIPTA.Label.Card": "Kati",
  "KRIPTA.Label.Player": "Ɗan Wasa",
  "KRIPTA.Label.Name": "Suna",
  "KRIPTA.Label.Comment": "Sharhi",
  "KRIPTA.Label.CardTypes": "Nau'o'in kati",
  "KRIPTA.Label.Count": "Yawa",
  "KRIPTA.Label.ConfirmationCode": "Lambar tabbatarwa",
  "KRIPTA.Label.Id": "Shaida",
  "KRIPTA.Label.Key": "Maɓalli",
  "KRIPTA.Label.ServerUrl": "URL na sabar",
  "KRIPTA.Label.Writer": "Marubuci",
  "KRIPTA.Label.Reader": "Mai karatu",
  "KRIPTA.Label.Role": "Matsayi",
  "KRIPTA.Label.Binding": "Haɗi",
  "KRIPTA.Role.GM": "Jagoran Wasa",
  "KRIPTA.Role.Player": "Ɗan Wasa",
  "KRIPTA.Status.InGame": "a kan layi",
  "KRIPTA.Status.Offline": "ba a kan layi ba",
  "KRIPTA.Binding.CardsIssued": "katunan da aka bayar:",
  "KRIPTA.Binding.NoCards": "babu katuna",
  "KRIPTA.Binding.NotBound": "ba a haɗa ɗan wasa ba, haɗa ɗan wasa.",
  "KRIPTA.Binding.CardsCountHint": "Yawan nau'o'in katunan da aka bayar, ba tare da maimaitattu ba",
  "KRIPTA.Button.Add": "Ƙara",
  "KRIPTA.Button.Bind": "Haɗa",
  "KRIPTA.Button.Cancel": "Soke",
  "KRIPTA.Button.Close": "Rufe",
  "KRIPTA.Button.Confirm": "Tabbatar",
  "KRIPTA.Button.Delete": "Share",
  "KRIPTA.Button.Edit": "Gyara",
  "KRIPTA.Button.Give": "Ba da",
  "KRIPTA.Button.GiveCard": "Ba da Kati",
  "KRIPTA.Button.Info": "Bayani",
  "KRIPTA.Button.No": "A'a",
  "KRIPTA.Button.Output": "Wallafa",
  "KRIPTA.Button.Refresh": "Sabunta",
  "KRIPTA.Button.Registry": "Rajistar 'Yan Wasa",
  "KRIPTA.Button.Request": "Nema",
  "KRIPTA.Button.RequestCard": "Nema",
  "KRIPTA.Button.SaveChanges": "Ajiye Canje-canje",
  "KRIPTA.Button.Take": "Cire",
  "KRIPTA.Button.TestAuth": "Duba masu amfani na fasaha",
  "KRIPTA.Button.TestServer": "Duba sabar",
  "KRIPTA.Button.Unbind": "Cire haɗi",
  "KRIPTA.Button.Use": "Yi amfani",
  "KRIPTA.Button.Yes": "Eh",
  "KRIPTA.Mode.Manual": "Zaɓa da hannu",
  "KRIPTA.Mode.Random": "Bazuwar",
  "KRIPTA.Mode.Show": "Nuna",
  "KRIPTA.Mode.Spend": "Kashe",
  "KRIPTA.View.Table": "Tebur",
  "KRIPTA.View.Tiles": "Tiles",
  "KRIPTA.Placeholder.Search": "Bincika",
  "KRIPTA.Select.NotSelected": "-- ba a zaɓa ba --",
  "KRIPTA.Template.EmptyCatalog": "Babu rukuni ko katuna da aka yi rajista a kan sabar.",
  "KRIPTA.Template.MyCardsTitle": "Katunan ɗan wasa: {playerName}",
  "KRIPTA.Template.UseCardMissing": "Wannan kati ba ya cikin rajistar sabar kuma.",
  "KRIPTA.Template.UseCardPrompt": "Za a yi amfani da wannan kati:",
  "KRIPTA.Card.FallbackName": "Kati {number}",
  "KRIPTA.Card.FallbackAddress": "Kati {level}/{number}",
  "KRIPTA.Card.MissingDescription": "Kati {level}/{number} ya ɓace daga katalojin sabar na yanzu.",
  "KRIPTA.Card.NotRegisteredDescription": "Kati {level}/{number} ba ya cikin rajistar sabar kuma.",
  "KRIPTA.Level.FallbackName": "Mataki {level}",
  "KRIPTA.Level.MissingDescription": "Wannan mataki yana cikin kayan ɗan wasa amma ya ɓace daga katalojin sabar na yanzu.",
  "KRIPTA.Chat.BlobReadFailed": "An kasa karanta blob",
  "KRIPTA.Chat.CardGivenTitle": "An Ba da Kati",
  "KRIPTA.Chat.CardReceiveSubtitle": "Ɗan wasa {playerName} yana karɓar kati {cardSubtitle}",
  "KRIPTA.Chat.CardRequestCanceled": "An soke neman kati.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "An Tabbatar da Neman Kati",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "An kasa karanta bayanan nema.",
  "KRIPTA.Chat.CardSpentFooter": "AN KASHE KATI",
  "KRIPTA.Chat.CardSpentTitle": "An Kashe Kati",
  "KRIPTA.Chat.FallbackPlayer": "ɗan wasa",
  "KRIPTA.Chat.ManualChoiceFooter": "ZAƁI DA HANNU",
  "KRIPTA.Chat.ReferenceTitle": "Nuni",
  "KRIPTA.Chat.RequestManualTitle": "Neman Katin da Aka Zaɓa",
  "KRIPTA.Chat.RequestRandomTitle": "Neman Katin Bazuwar",
  "KRIPTA.Chat.ShowCardTitle": "Nunin Kati",
  "KRIPTA.Dialog.BindPlayer.Title": "Haɗa Ɗan Wasan Sabar",
  "KRIPTA.Dialog.BindPlayer.Header": "Zaɓi ɗan wasa don {foundryUserName}",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "mai amfani na Foundry",
  "KRIPTA.Dialog.Player.AddTitle": "Ƙara Ɗan Wasa",
  "KRIPTA.Dialog.Player.EditTitle": "Gyara Ɗan Wasa",
  "KRIPTA.Dialog.Player.DeleteTitle": "Share Ɗan Wasa",
  "KRIPTA.Dialog.Player.DeleteWarning": "Share ɗan wasa \"{playerName}\" ba za a iya mayar da shi ba. Shigar da \"{code}\" sannan ka tabbatar da sharewa.",
  "KRIPTA.Dialog.Count.TotalCards": "jimillar katunan wannan nau'i - {max}",
  "KRIPTA.Error.InvalidCardLevel": "Mataki mara inganci ga {context}: {level}",
  "KRIPTA.Error.InvalidCardNumber": "Lamba mara inganci ga {context}: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "matakin kati mara inganci: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "lambar kati mara inganci: {number}",
  "KRIPTA.Error.InvalidRequestCard": "Kati mara inganci don nema",
  "KRIPTA.Error.InvalidGiveCard": "Kati mara inganci don bayarwa",
  "KRIPTA.Error.MissingRequestPlayerGuid": "An kasa gano playerGuid don ba da kati.",
  "KRIPTA.Error.MissingSelectedCard": "An kasa gano katin da aka zaɓa.",
  "KRIPTA.Error.MissingSelectedCardForGive": "An kasa gano katin da aka zaɓa don bayarwa.",
  "KRIPTA.Error.MissingGivePlayer": "An kasa gano ɗan wasan da za a ba kati.",
  "KRIPTA.Error.MissingGiveCard": "An kasa gano katin da za a bayar.",
  "KRIPTA.Error.MissingServerUrl": "Saitin hanyar sabar ya ɓace.",
  "KRIPTA.Error.InvalidReader": "Mai amfani na fasaha Reader an saita shi ba daidai ba.",
  "KRIPTA.Error.InvalidWriter": "Mai amfani na fasaha Writer an saita shi ba daidai ba.",
  "KRIPTA.Error.MenuUnavailable": "Wannan fasali ba ya samuwa. Duba saitunan moduli. Cikakkun bayanai suna cikin console na burauza.",
  "KRIPTA.Error.Generic": "Kuskure ya faru",
  "KRIPTA.Error.Unknown": "kuskure da ba a sani ba",
  "KRIPTA.Error.NameRequired": "Ana buƙatar filin Suna.",
  "KRIPTA.Error.RegistryDeleteReturned": "sabar ta mayar da ɗan wasan cikin rajista bayan sharewa.",
  "KRIPTA.Notification.CardGiven": "An ba da kati.",
  "KRIPTA.Notification.CardUsed": "An yi amfani da kati kuma an kashe shi.",
  "KRIPTA.Notification.CardWrittenOff": "An cire kati.",
  "KRIPTA.Notification.CannotUseMissingCard": "Wannan kati ba ya cikin rajistar sabar kuma. Ba za a iya amfani da shi ba.",
  "KRIPTA.Notification.MissingCard": "Wannan kati ba ya cikin rajistar sabar kuma.",
  "KRIPTA.Notification.PlayerNotSelected": "Ba a zaɓi ɗan wasa don ba da kati ba",
  "KRIPTA.Notification.PlayerBindingMissing": "An kasa gano haɗin ɗan wasa don ba da kati",
  "KRIPTA.Notification.RequestSent": "An aika neman kati zuwa hira.",
  "KRIPTA.Notification.ServerSuccess": "Haɗi ya yi nasara.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "Haɗi ya yi nasara. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "An kasa haɗawa da sabar. Duba adireshi, samuwar sabar, da saitunan CORS/HTTPS.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "An kasa duba sabar.",
  "KRIPTA.Notification.InvalidServerUrl": "Adireshin sabar mara inganci: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "Sashen saitunan Katunan Kripta yana samuwa ne kawai ga matsayin Jagoran Wasa da Mataimakin Jagoran Wasa.",
  "KRIPTA.Notification.ServerCheckFailed": "Duba sabar ya kasa",
  "KRIPTA.Notification.TechUserReader": "Mai karatu",
  "KRIPTA.Notification.TechUserWriter": "Marubuci",
  "KRIPTA.Notification.TechUsersCheckSuccess": "Masu amfani na fasaha \"Reader\" da \"Writer\" sun wuce dubawa.",
  "KRIPTA.Notification.SettingsSaved": "An ajiye saitunan haɗi.",
  "KRIPTA.Notification.PlayerAdded": "An ƙara ɗan wasa.",
  "KRIPTA.Notification.PlayerUpdated": "An sabunta ɗan wasa.",
  "KRIPTA.Notification.PlayerDeleted": "An share ɗan wasa.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "An soke sharewa. An cika filin tabbatarwa ba daidai ba.",
  "KRIPTA.Notification.BindingSaved": "An ajiye haɗi.",
  "KRIPTA.Notification.BindingDeleted": "An cire haɗi.",
  "KRIPTA.Notification.BadCatalogCardNumber": "Katin da aka zaɓa yana da lamba mara inganci. Duba amsar getCardsList da normalizeCardsList.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "Ba za a iya ba da wannan kati da hannu ba saboda yana da lamba mara inganci. Duba amsar getCardsList da normalizeCardsList.",
  "KRIPTA.Notification.CardOutputFailed": "An kasa wallafa kati zuwa hira",
  "KRIPTA.Notification.CardGiveFailed": "An kasa ba da kati",
  "KRIPTA.Notification.CardUseFailed": "An kasa amfani da kati",
  "KRIPTA.Notification.CardTakeFailed": "An kasa cire kati",
  "KRIPTA.Notification.CardRequestFailed": "An kasa aika neman kati",
  "KRIPTA.Notification.CardRequestConfirmFailed": "An kasa tabbatar da bayar da kati",
  "KRIPTA.Notification.PlayerAddFailed": "An kasa ƙara ɗan wasa",
  "KRIPTA.Notification.PlayerUpdateFailed": "An kasa sabunta ɗan wasa",
  "KRIPTA.Notification.PlayerDeleteFailed": "An kasa share ɗan wasa",
  "KRIPTA.Notification.CardRollFailed": "An kasa karɓar kati.",
  "KRIPTA.Dialog.TakeCard.Title": "Cire Kati",
  "KRIPTA.Dialog.TakeCard.Message": "Ɗan wasa {playerName} zai rasa kati {cardName}.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Ba da Kati"
}
__END_LOCALE_JSON__
