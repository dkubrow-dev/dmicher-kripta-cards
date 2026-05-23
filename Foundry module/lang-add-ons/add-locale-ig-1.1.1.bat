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
$localePath = 'dmicher-kripta-cards/lang/ig.json'
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
  "lang": "ig",
  "name": "Igbo",
  "path": "lang/ig.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "Onye ọrụ Foundry gị ejikọtaghị na Onye Egwuregwu Sava n'ime modul Kaadị Kripta. Biko kpọtụrụ Onye Ndu Egwuregwu.",
  "KRIPTA.GMOnly": "Omume a dị naanị maka Onye Ndu Egwuregwu.",
  "KRIPTA.Settings.ServerUrl.Name": "Adreesị sava",
  "KRIPTA.Settings.TechAuthUsers.Name": "Ndị ọrụ teknụzụ",
  "KRIPTA.Settings.PlayerBindings.Name": "Njikọ onye ọrụ Foundry na onye egwuregwu sava",
  "KRIPTA.Settings.UiPrefs.Name": "Ntọala ihu ọrụ mpaghara",
  "KRIPTA.Settings.Menu.Name": "Kaadị Kripta",
  "KRIPTA.Settings.Menu.Label": "Ntọala modul",
  "KRIPTA.Settings.Menu.Hint": "Njikọ API na ndị ọrụ teknụzụ.",
  "KRIPTA.Settings.Help.BeforeServerLink": "Ọ bụrụ na ị wụnyebeghị ma hazie sava ọdịnaya maka modul ahụ, soro ",
  "KRIPTA.Settings.Help.ServerLink": "njikọ a",
  "KRIPTA.Settings.Help.AfterServerLink": " mee nke ahụ. Maka nhazi ngwa ngwa, jiri ",
  "KRIPTA.Settings.Help.DocumentationLink": "akwụkwọ ntuziaka",
  "KRIPTA.Settings.Help.AfterDocumentationLink": ".",
  "KRIPTA.Window.Catalog": "Katalọgụ Kaadị",
  "KRIPTA.Window.CardDetails": "Kaadị Katalọgụ",
  "KRIPTA.Window.GiveCard": "Nye Kaadị",
  "KRIPTA.Window.MyCards": "Kaadị Onye Egwuregwu",
  "KRIPTA.Window.Players": "Jikwaa Ndị Egwuregwu",
  "KRIPTA.Window.Registry": "Ndebanye Ndị Egwuregwu",
  "KRIPTA.Window.RequestCard": "Rịọ Kaadị",
  "KRIPTA.Window.Settings": "Kaadị Kripta - Ntọala",
  "KRIPTA.Window.UseCard": "Jiri Kaadị",
  "KRIPTA.Menu.Title": "Kaadị Kripta",
  "KRIPTA.Menu.Catalog": "Katalọgụ Kaadị",
  "KRIPTA.Menu.GetCard": "Rịọ Kaadị",
  "KRIPTA.Menu.MyCards": "Kaadị M",
  "KRIPTA.Menu.Players": "Jikwaa Ndị Egwuregwu",
  "KRIPTA.Label.Category": "Ngalaba",
  "KRIPTA.Label.Mode": "Ọnọdụ",
  "KRIPTA.Label.Card": "Kaadị",
  "KRIPTA.Label.Player": "Onye Egwuregwu",
  "KRIPTA.Label.Name": "Aha",
  "KRIPTA.Label.Comment": "Nkọwa",
  "KRIPTA.Label.CardTypes": "Ụdị kaadị",
  "KRIPTA.Label.Count": "Ọnụọgụ",
  "KRIPTA.Label.ConfirmationCode": "Koodu nkwenye",
  "KRIPTA.Label.Id": "NJ",
  "KRIPTA.Label.Key": "Igodo",
  "KRIPTA.Label.ServerUrl": "URL sava",
  "KRIPTA.Label.Writer": "Onye ode",
  "KRIPTA.Label.Reader": "Onye ọgụgụ",
  "KRIPTA.Label.Role": "Ọrụ",
  "KRIPTA.Label.Binding": "Njikọ",
  "KRIPTA.Role.GM": "Onye Ndu Egwuregwu",
  "KRIPTA.Role.Player": "Onye Egwuregwu",
  "KRIPTA.Status.InGame": "n'ịntanetị",
  "KRIPTA.Status.Offline": "anọghị n'ịntanetị",
  "KRIPTA.Binding.CardsIssued": "kaadị e nyere:",
  "KRIPTA.Binding.NoCards": "enweghị kaadị",
  "KRIPTA.Binding.NotBound": "ejikọtaghị onye egwuregwu, jikọọ onye egwuregwu.",
  "KRIPTA.Binding.CardsCountHint": "Ọnụọgụ ụdị kaadị e nyere, ewezuga ndị ugboro ugboro",
  "KRIPTA.Button.Add": "Tinye",
  "KRIPTA.Button.Bind": "Jikọọ",
  "KRIPTA.Button.Cancel": "Kagbuo",
  "KRIPTA.Button.Close": "Mechie",
  "KRIPTA.Button.Confirm": "Kwenye",
  "KRIPTA.Button.Delete": "Hichapụ",
  "KRIPTA.Button.Edit": "Dezie",
  "KRIPTA.Button.Give": "Nye",
  "KRIPTA.Button.GiveCard": "Nye Kaadị",
  "KRIPTA.Button.Info": "Ozi",
  "KRIPTA.Button.No": "Mba",
  "KRIPTA.Button.Output": "Zipu",
  "KRIPTA.Button.Refresh": "Melite",
  "KRIPTA.Button.Registry": "Ndebanye Ndị Egwuregwu",
  "KRIPTA.Button.Request": "Rịọ",
  "KRIPTA.Button.RequestCard": "Rịọ",
  "KRIPTA.Button.SaveChanges": "Chekwaa Mgbanwe",
  "KRIPTA.Button.Take": "Wepụ",
  "KRIPTA.Button.TestAuth": "Lelee ndị ọrụ teknụzụ",
  "KRIPTA.Button.TestServer": "Lelee sava",
  "KRIPTA.Button.Unbind": "Wepụ njikọ",
  "KRIPTA.Button.Use": "Jiri",
  "KRIPTA.Button.Yes": "Ee",
  "KRIPTA.Mode.Manual": "Họrọ n'aka",
  "KRIPTA.Mode.Random": "N'amaghị ama",
  "KRIPTA.Mode.Show": "Gosi",
  "KRIPTA.Mode.Spend": "Jiri",
  "KRIPTA.View.Table": "Tebụl",
  "KRIPTA.View.Tiles": "Taịlụ",
  "KRIPTA.Placeholder.Search": "Chọọ",
  "KRIPTA.Select.NotSelected": "-- ahọrọghị --",
  "KRIPTA.Template.EmptyCatalog": "Enweghị ngalaba ma ọ bụ kaadị edebanyere na sava.",
  "KRIPTA.Template.MyCardsTitle": "Kaadị onye egwuregwu: {playerName}",
  "KRIPTA.Template.UseCardMissing": "Kaadị a adịghịzi edebanye na sava.",
  "KRIPTA.Template.UseCardPrompt": "A ga-eji kaadị a:",
  "KRIPTA.Card.FallbackName": "Kaadị {number}",
  "KRIPTA.Card.FallbackAddress": "Kaadị {level}/{number}",
  "KRIPTA.Card.MissingDescription": "Kaadị {level}/{number} adịghị na katalọgụ sava ugbu a.",
  "KRIPTA.Card.NotRegisteredDescription": "Kaadị {level}/{number} adịghịzi edebanye na sava.",
  "KRIPTA.Level.FallbackName": "Ọkwa {level}",
  "KRIPTA.Level.MissingDescription": "Ọkwa a dị na akpa onye egwuregwu, mana adịghị na katalọgụ sava ugbu a.",
  "KRIPTA.Chat.BlobReadFailed": "Ịgụ blob dara",
  "KRIPTA.Chat.CardGivenTitle": "Enyela Kaadị",
  "KRIPTA.Chat.CardReceiveSubtitle": "Onye egwuregwu {playerName} na-anata kaadị {cardSubtitle}",
  "KRIPTA.Chat.CardRequestCanceled": "Akagbuola arịrịọ kaadị.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "Akwadoro Arịrịọ Kaadị",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "Ịgụ data arịrịọ dara.",
  "KRIPTA.Chat.CardSpentFooter": "EJIRILA KAADỊ",
  "KRIPTA.Chat.CardSpentTitle": "Ejirila Kaadị",
  "KRIPTA.Chat.FallbackPlayer": "onye egwuregwu",
  "KRIPTA.Chat.ManualChoiceFooter": "NHỌRỌ AKA",
  "KRIPTA.Chat.ReferenceTitle": "Ntụaka",
  "KRIPTA.Chat.RequestManualTitle": "Arịrịọ Kaadị Ahọpụtara",
  "KRIPTA.Chat.RequestRandomTitle": "Arịrịọ Kaadị N'amaghị Ama",
  "KRIPTA.Chat.ShowCardTitle": "Ntụaka Kaadị",
  "KRIPTA.Dialog.BindPlayer.Title": "Jikọọ Onye Egwuregwu Sava",
  "KRIPTA.Dialog.BindPlayer.Header": "Họrọ onye egwuregwu maka {foundryUserName}",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "onye ọrụ Foundry",
  "KRIPTA.Dialog.Player.AddTitle": "Tinye Onye Egwuregwu",
  "KRIPTA.Dialog.Player.EditTitle": "Dezie Onye Egwuregwu",
  "KRIPTA.Dialog.Player.DeleteTitle": "Hichapụ Onye Egwuregwu",
  "KRIPTA.Dialog.Player.DeleteWarning": "Ihichapụ onye egwuregwu \"{playerName}\" agaghị ekwe omume iweghachi. Tinye \"{code}\" ma kwenye ihichapụ.",
  "KRIPTA.Dialog.Count.TotalCards": "ngụkọta kaadị ụdị a - {max}",
  "KRIPTA.Error.InvalidCardLevel": "Ọkwa na-adịghị mma maka {context}: {level}",
  "KRIPTA.Error.InvalidCardNumber": "Nọmba na-adịghị mma maka {context}: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "ọkwa kaadị na-adịghị mma: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "nọmba kaadị na-adịghị mma: {number}",
  "KRIPTA.Error.InvalidRequestCard": "Kaadị na-adịghị mma maka arịrịọ",
  "KRIPTA.Error.InvalidGiveCard": "Kaadị na-adịghị mma maka inye",
  "KRIPTA.Error.MissingRequestPlayerGuid": "Ịchọpụta playerGuid maka inye kaadị dara.",
  "KRIPTA.Error.MissingSelectedCard": "Ịchọpụta kaadị ahọpụtara dara.",
  "KRIPTA.Error.MissingSelectedCardForGive": "Ịchọpụta kaadị ahọpụtara iji nye dara.",
  "KRIPTA.Error.MissingGivePlayer": "Ịchọpụta onye egwuregwu a ga-enye kaadị dara.",
  "KRIPTA.Error.MissingGiveCard": "Ịchọpụta kaadị a ga-enye dara.",
  "KRIPTA.Error.MissingServerUrl": "Ntọala ụzọ sava adịghị.",
  "KRIPTA.Error.InvalidReader": "A haziri onye ọrụ teknụzụ Reader n'ụzọ na-ezighi ezi.",
  "KRIPTA.Error.InvalidWriter": "A haziri onye ọrụ teknụzụ Writer n'ụzọ na-ezighi ezi.",
  "KRIPTA.Error.MenuUnavailable": "Njirimara a adịghị. Lelee ntọala modul. Nkọwa dị na console ihe nchọgharị.",
  "KRIPTA.Error.Generic": "Mperi mere",
  "KRIPTA.Error.Unknown": "mperi amaghị ama",
  "KRIPTA.Error.NameRequired": "A chọrọ mpaghara Aha.",
  "KRIPTA.Error.RegistryDeleteReturned": "sava weghachiri onye egwuregwu na ndebanye mgbe ihichapụ gasịrị.",
  "KRIPTA.Notification.CardGiven": "Enyela kaadị.",
  "KRIPTA.Notification.CardUsed": "Ejirila kaadị ma wepụ ya.",
  "KRIPTA.Notification.CardWrittenOff": "Ewepụla kaadị.",
  "KRIPTA.Notification.CannotUseMissingCard": "Kaadị a adịghịzi edebanye na sava. Enweghị ike iji ya.",
  "KRIPTA.Notification.MissingCard": "Kaadị a adịghịzi edebanye na sava.",
  "KRIPTA.Notification.PlayerNotSelected": "Ahọrọghị onye egwuregwu maka inye kaadị",
  "KRIPTA.Notification.PlayerBindingMissing": "Ịchọpụta njikọ onye egwuregwu maka inye kaadị dara",
  "KRIPTA.Notification.RequestSent": "Ezigala arịrịọ kaadị na nkata.",
  "KRIPTA.Notification.ServerSuccess": "Njikọ gara nke ọma.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "Njikọ gara nke ọma. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "Ijikọ na sava dara. Lelee adreesị, ịdị adị sava, na ntọala CORS/HTTPS.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "Ilelee sava dara.",
  "KRIPTA.Notification.InvalidServerUrl": "Adreesị sava na-adịghị mma: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "Akụkụ ntọala Kaadị Kripta dị naanị maka ọrụ Onye Ndu Egwuregwu na Onye Enyemaka Onye Ndu Egwuregwu.",
  "KRIPTA.Notification.ServerCheckFailed": "Nlele sava dara",
  "KRIPTA.Notification.TechUserReader": "Onye ọgụgụ",
  "KRIPTA.Notification.TechUserWriter": "Onye ode",
  "KRIPTA.Notification.TechUsersCheckSuccess": "Ndị ọrụ teknụzụ \"Reader\" na \"Writer\" gafere nlele.",
  "KRIPTA.Notification.SettingsSaved": "Echekwara ntọala njikọ.",
  "KRIPTA.Notification.PlayerAdded": "Etinyela onye egwuregwu.",
  "KRIPTA.Notification.PlayerUpdated": "Emelitere onye egwuregwu.",
  "KRIPTA.Notification.PlayerDeleted": "Ehichapụla onye egwuregwu.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "Akagbuola ihichapụ. Edejupụtara mpaghara nkwenye n'ụzọ na-ezighi ezi.",
  "KRIPTA.Notification.BindingSaved": "Echekwara njikọ.",
  "KRIPTA.Notification.BindingDeleted": "Ewepụla njikọ.",
  "KRIPTA.Notification.BadCatalogCardNumber": "Kaadị ahọpụtara nwere nọmba na-adịghị mma. Lelee nzaghachi getCardsList na normalizeCardsList.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "Enweghị ike inye kaadị a n'aka n'ihi na ọ nwere nọmba na-adịghị mma. Lelee nzaghachi getCardsList na normalizeCardsList.",
  "KRIPTA.Notification.CardOutputFailed": "Izipu kaadị na nkata dara",
  "KRIPTA.Notification.CardGiveFailed": "Inye kaadị dara",
  "KRIPTA.Notification.CardUseFailed": "Iji kaadị dara",
  "KRIPTA.Notification.CardTakeFailed": "Iwepụ kaadị dara",
  "KRIPTA.Notification.CardRequestFailed": "Izipu arịrịọ kaadị dara",
  "KRIPTA.Notification.CardRequestConfirmFailed": "Ịkwado inye kaadị dara",
  "KRIPTA.Notification.PlayerAddFailed": "Ịtinye onye egwuregwu dara",
  "KRIPTA.Notification.PlayerUpdateFailed": "Imelite onye egwuregwu dara",
  "KRIPTA.Notification.PlayerDeleteFailed": "Ihichapụ onye egwuregwu dara",
  "KRIPTA.Notification.CardRollFailed": "Ịnata kaadị dara.",
  "KRIPTA.Dialog.TakeCard.Title": "Wepụ Kaadị",
  "KRIPTA.Dialog.TakeCard.Message": "Onye egwuregwu {playerName} ga-atụfu kaadị {cardName}.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Nye Kaadị"
}
__END_LOCALE_JSON__
