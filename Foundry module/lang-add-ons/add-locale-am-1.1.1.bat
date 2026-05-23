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
$localePath = 'dmicher-kripta-cards/lang/am.json'
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
  "lang": "am",
  "name": "አማርኛ",
  "path": "lang/am.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "የFoundry ተጠቃሚዎ በKripta Cards ሞጁል ውስጥ ከሰርቨር ተጫዋች ጋር አልተገናኘም። እባክዎ የጨዋታ መሪውን ያነጋግሩ።",
  "KRIPTA.GMOnly": "ይህ እርምጃ ለጨዋታ መሪው ብቻ ይገኛል።",
  "KRIPTA.Settings.ServerUrl.Name": "የሰርቨር አድራሻ",
  "KRIPTA.Settings.TechAuthUsers.Name": "ቴክኒካዊ ተጠቃሚዎች",
  "KRIPTA.Settings.PlayerBindings.Name": "የFoundry ተጠቃሚዎችን ከሰርቨር ተጫዋቾች ጋር ማገናኘት",
  "KRIPTA.Settings.UiPrefs.Name": "የአካባቢ በይነገጽ ቅንብሮች",
  "KRIPTA.Settings.Menu.Name": "የKripta ካርዶች",
  "KRIPTA.Settings.Menu.Label": "የሞጁል ቅንብሮች",
  "KRIPTA.Settings.Menu.Hint": "የAPI ግንኙነት እና ቴክኒካዊ ተጠቃሚዎች።",
  "KRIPTA.Settings.Help.BeforeServerLink": "ለሞጁሉ የይዘት አገልጋይ ገና ካልጫኑ እና ካላዋቀሩ፣ ",
  "KRIPTA.Settings.Help.ServerLink": "ይህን አገናኝ",
  "KRIPTA.Settings.Help.AfterServerLink": " ይከተሉ። ለፈጣን ማዋቀር ",
  "KRIPTA.Settings.Help.DocumentationLink": "ሰነዱን",
  "KRIPTA.Settings.Help.AfterDocumentationLink": " ይጠቀሙ።",
  "KRIPTA.Window.Catalog": "የካርድ ካታሎግ",
  "KRIPTA.Window.CardDetails": "የካታሎግ ካርድ",
  "KRIPTA.Window.GiveCard": "ካርድ ስጥ",
  "KRIPTA.Window.MyCards": "የተጫዋች ካርዶች",
  "KRIPTA.Window.Players": "ተጫዋቾችን አስተዳድር",
  "KRIPTA.Window.Registry": "የተጫዋቾች መዝገብ",
  "KRIPTA.Window.RequestCard": "ካርድ ጠይቅ",
  "KRIPTA.Window.Settings": "የKripta ካርዶች - ቅንብሮች",
  "KRIPTA.Window.UseCard": "ካርድ ተጠቀም",
  "KRIPTA.Menu.Title": "የKripta ካርዶች",
  "KRIPTA.Menu.Catalog": "የካርድ ካታሎግ",
  "KRIPTA.Menu.GetCard": "ካርድ ጠይቅ",
  "KRIPTA.Menu.MyCards": "የእኔ ካርዶች",
  "KRIPTA.Menu.Players": "ተጫዋቾችን አስተዳድር",
  "KRIPTA.Label.Category": "ምድብ",
  "KRIPTA.Label.Mode": "ሁነታ",
  "KRIPTA.Label.Card": "ካርድ",
  "KRIPTA.Label.Player": "ተጫዋች",
  "KRIPTA.Label.Name": "ስም",
  "KRIPTA.Label.Comment": "አስተያየት",
  "KRIPTA.Label.CardTypes": "የካርድ አይነቶች",
  "KRIPTA.Label.Count": "ብዛት",
  "KRIPTA.Label.ConfirmationCode": "የማረጋገጫ ኮድ",
  "KRIPTA.Label.Id": "መለያ",
  "KRIPTA.Label.Key": "ቁልፍ",
  "KRIPTA.Label.ServerUrl": "የሰርቨር URL",
  "KRIPTA.Label.Writer": "ጸሐፊ",
  "KRIPTA.Label.Reader": "አንባቢ",
  "KRIPTA.Label.Role": "ሚና",
  "KRIPTA.Label.Binding": "ግንኙነት",
  "KRIPTA.Role.GM": "የጨዋታ መሪ",
  "KRIPTA.Role.Player": "ተጫዋች",
  "KRIPTA.Status.InGame": "በመስመር ላይ",
  "KRIPTA.Status.Offline": "ከመስመር ውጭ",
  "KRIPTA.Binding.CardsIssued": "የተሰጡ ካርዶች:",
  "KRIPTA.Binding.NoCards": "ካርዶች የሉም",
  "KRIPTA.Binding.NotBound": "ተጫዋች አልተገናኘም፣ ተጫዋች ያገናኙ።",
  "KRIPTA.Binding.CardsCountHint": "የተሰጡ የካርድ አይነቶች ብዛት፣ የተደጋገሙትን ሳይጨምር",
  "KRIPTA.Button.Add": "ጨምር",
  "KRIPTA.Button.Bind": "አገናኝ",
  "KRIPTA.Button.Cancel": "ሰርዝ",
  "KRIPTA.Button.Close": "ዝጋ",
  "KRIPTA.Button.Confirm": "አረጋግጥ",
  "KRIPTA.Button.Delete": "ሰርዝ",
  "KRIPTA.Button.Edit": "አርትዕ",
  "KRIPTA.Button.Give": "ስጥ",
  "KRIPTA.Button.GiveCard": "ካርድ ስጥ",
  "KRIPTA.Button.Info": "መረጃ",
  "KRIPTA.Button.No": "አይ",
  "KRIPTA.Button.Output": "አትም",
  "KRIPTA.Button.Refresh": "አድስ",
  "KRIPTA.Button.Registry": "የተጫዋቾች መዝገብ",
  "KRIPTA.Button.Request": "ጠይቅ",
  "KRIPTA.Button.RequestCard": "ጠይቅ",
  "KRIPTA.Button.SaveChanges": "ለውጦችን አስቀምጥ",
  "KRIPTA.Button.Take": "አስወግድ",
  "KRIPTA.Button.TestAuth": "ቴክኒካዊ ተጠቃሚዎችን ፈትሽ",
  "KRIPTA.Button.TestServer": "ሰርቨርን ፈትሽ",
  "KRIPTA.Button.Unbind": "ግንኙነት አቋርጥ",
  "KRIPTA.Button.Use": "ተጠቀም",
  "KRIPTA.Button.Yes": "አዎ",
  "KRIPTA.Mode.Manual": "በእጅ ምረጥ",
  "KRIPTA.Mode.Random": "በዘፈቀደ",
  "KRIPTA.Mode.Show": "አሳይ",
  "KRIPTA.Mode.Spend": "አውጣ",
  "KRIPTA.View.Table": "ሰንጠረዥ",
  "KRIPTA.View.Tiles": "ሰቆች",
  "KRIPTA.Placeholder.Search": "ፈልግ",
  "KRIPTA.Select.NotSelected": "-- አልተመረጠም --",
  "KRIPTA.Template.EmptyCatalog": "በሰርቨሩ ላይ የተመዘገቡ ምድቦች ወይም ካርዶች የሉም።",
  "KRIPTA.Template.MyCardsTitle": "የተጫዋች ካርዶች: {playerName}",
  "KRIPTA.Template.UseCardMissing": "ይህ ካርድ ከእንግዲህ በሰርቨሩ ላይ አልተመዘገበም።",
  "KRIPTA.Template.UseCardPrompt": "ይህ ካርድ ይጠቀማል:",
  "KRIPTA.Card.FallbackName": "ካርድ {number}",
  "KRIPTA.Card.FallbackAddress": "ካርድ {level}/{number}",
  "KRIPTA.Card.MissingDescription": "ካርድ {level}/{number} በአሁኑ የሰርቨር ካታሎግ ውስጥ የለም።",
  "KRIPTA.Card.NotRegisteredDescription": "ካርድ {level}/{number} ከእንግዲህ በሰርቨሩ ላይ አልተመዘገበም።",
  "KRIPTA.Level.FallbackName": "ደረጃ {level}",
  "KRIPTA.Level.MissingDescription": "ይህ ደረጃ በተጫዋቹ ንብረት ውስጥ አለ፣ ግን በአሁኑ የሰርቨር ካታሎግ ውስጥ የለም።",
  "KRIPTA.Chat.BlobReadFailed": "blob ማንበብ አልተሳካም",
  "KRIPTA.Chat.CardGivenTitle": "ካርድ ተሰጥቷል",
  "KRIPTA.Chat.CardReceiveSubtitle": "ተጫዋች {playerName} ካርድ {cardSubtitle} ይቀበላል",
  "KRIPTA.Chat.CardRequestCanceled": "የካርድ ጥያቄ ተሰርዟል።",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "የካርድ ጥያቄ ተረጋግጧል",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "የጥያቄ ውሂብ ማንበብ አልተሳካም።",
  "KRIPTA.Chat.CardSpentFooter": "ካርዱ ተጠቅሟል",
  "KRIPTA.Chat.CardSpentTitle": "ካርዱ ተጠቅሟል",
  "KRIPTA.Chat.FallbackPlayer": "ተጫዋች",
  "KRIPTA.Chat.ManualChoiceFooter": "በእጅ ምርጫ",
  "KRIPTA.Chat.ReferenceTitle": "ማጣቀሻ",
  "KRIPTA.Chat.RequestManualTitle": "የተመረጠ ካርድ ጥያቄ",
  "KRIPTA.Chat.RequestRandomTitle": "የዘፈቀደ ካርድ ጥያቄ",
  "KRIPTA.Chat.ShowCardTitle": "የካርድ ማጣቀሻ",
  "KRIPTA.Dialog.BindPlayer.Title": "የሰርቨር ተጫዋች አገናኝ",
  "KRIPTA.Dialog.BindPlayer.Header": "ለ{foundryUserName} ተጫዋች ምረጥ",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "የFoundry ተጠቃሚ",
  "KRIPTA.Dialog.Player.AddTitle": "ተጫዋች ጨምር",
  "KRIPTA.Dialog.Player.EditTitle": "ተጫዋች አርትዕ",
  "KRIPTA.Dialog.Player.DeleteTitle": "ተጫዋች ሰርዝ",
  "KRIPTA.Dialog.Player.DeleteWarning": "ተጫዋች \"{playerName}\" መሰረዝ መመለስ አይቻልም። \"{code}\" ያስገቡ እና ስረዛውን ያረጋግጡ።",
  "KRIPTA.Dialog.Count.TotalCards": "የዚህ አይነት ጠቅላላ ካርዶች - {max}",
  "KRIPTA.Error.InvalidCardLevel": "ለ{context} የማይሰራ ደረጃ: {level}",
  "KRIPTA.Error.InvalidCardNumber": "ለ{context} የማይሰራ ቁጥር: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "የማይሰራ የካርድ ደረጃ: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "የማይሰራ የካርድ ቁጥር: {number}",
  "KRIPTA.Error.InvalidRequestCard": "ለጥያቄ የማይሰራ ካርድ",
  "KRIPTA.Error.InvalidGiveCard": "ለመስጠት የማይሰራ ካርድ",
  "KRIPTA.Error.MissingRequestPlayerGuid": "ካርድ ለመስጠት playerGuid መወሰን አልተሳካም።",
  "KRIPTA.Error.MissingSelectedCard": "የተመረጠውን ካርድ መወሰን አልተሳካም።",
  "KRIPTA.Error.MissingSelectedCardForGive": "ለመስጠት የተመረጠውን ካርድ መወሰን አልተሳካም።",
  "KRIPTA.Error.MissingGivePlayer": "ካርዱን ለመስጠት ተጫዋቹን መወሰን አልተሳካም።",
  "KRIPTA.Error.MissingGiveCard": "ለመስጠት ካርዱን መወሰን አልተሳካም።",
  "KRIPTA.Error.MissingServerUrl": "የሰርቨር መንገድ ቅንብር የለም።",
  "KRIPTA.Error.InvalidReader": "የReader ቴክኒካዊ ተጠቃሚ በስህተት ተዋቅሯል።",
  "KRIPTA.Error.InvalidWriter": "የWriter ቴክኒካዊ ተጠቃሚ በስህተት ተዋቅሯል።",
  "KRIPTA.Error.MenuUnavailable": "ይህ ባህሪ አይገኝም። የሞጁሉን ቅንብሮች ይፈትሹ። ዝርዝሮች በአሳሽ console ውስጥ ናቸው።",
  "KRIPTA.Error.Generic": "ስህተት ተፈጥሯል",
  "KRIPTA.Error.Unknown": "ያልታወቀ ስህተት",
  "KRIPTA.Error.NameRequired": "የስም መስክ ያስፈልጋል።",
  "KRIPTA.Error.RegistryDeleteReturned": "ሰርቨሩ ከስረዛ በኋላ ተጫዋቹን በመዝገቡ ውስጥ መልሶታል።",
  "KRIPTA.Notification.CardGiven": "ካርድ ተሰጥቷል።",
  "KRIPTA.Notification.CardUsed": "ካርድ ተጠቅሟል እና ተወግዷል።",
  "KRIPTA.Notification.CardWrittenOff": "ካርድ ተወግዷል።",
  "KRIPTA.Notification.CannotUseMissingCard": "ይህ ካርድ ከእንግዲህ በሰርቨሩ ላይ አልተመዘገበም። መጠቀም አይቻልም።",
  "KRIPTA.Notification.MissingCard": "ይህ ካርድ ከእንግዲህ በሰርቨሩ ላይ አልተመዘገበም።",
  "KRIPTA.Notification.PlayerNotSelected": "ካርድ ለመስጠት ተጫዋች አልተመረጠም",
  "KRIPTA.Notification.PlayerBindingMissing": "ካርድ ለመስጠት የተጫዋች ግንኙነት መወሰን አልተሳካም",
  "KRIPTA.Notification.RequestSent": "የካርድ ጥያቄ ወደ ቻት ተልኳል።",
  "KRIPTA.Notification.ServerSuccess": "ግንኙነት ተሳክቷል።",
  "KRIPTA.Notification.ServerSuccessWithDetails": "ግንኙነት ተሳክቷል። {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "ከሰርቨሩ ጋር መገናኘት አልተሳካም። አድራሻውን፣ የሰርቨር ተገኝነትን እና የCORS/HTTPS ቅንብሮችን ይፈትሹ።",
  "KRIPTA.Notification.ServerCheckFailedFallback": "ሰርቨሩን መፈተሽ አልተሳካም።",
  "KRIPTA.Notification.InvalidServerUrl": "የማይሰራ የሰርቨር አድራሻ: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "የKripta Cards ቅንብሮች ክፍል ለጨዋታ መሪ እና ለረዳት የጨዋታ መሪ ሚናዎች ብቻ ይገኛል።",
  "KRIPTA.Notification.ServerCheckFailed": "የሰርቨር ፍተሻ አልተሳካም",
  "KRIPTA.Notification.TechUserReader": "አንባቢ",
  "KRIPTA.Notification.TechUserWriter": "ጸሐፊ",
  "KRIPTA.Notification.TechUsersCheckSuccess": "\"Reader\" እና \"Writer\" ቴክኒካዊ ተጠቃሚዎች ፍተሻውን አልፈዋል።",
  "KRIPTA.Notification.SettingsSaved": "የግንኙነት ቅንብሮች ተቀምጠዋል።",
  "KRIPTA.Notification.PlayerAdded": "ተጫዋች ታክሏል።",
  "KRIPTA.Notification.PlayerUpdated": "ተጫዋች ተዘምኗል።",
  "KRIPTA.Notification.PlayerDeleted": "ተጫዋች ተሰርዟል።",
  "KRIPTA.Notification.DeleteCanceledBadCode": "ስረዛ ተሰርዟል። የማረጋገጫ መስክ በስህተት ተሞልቷል።",
  "KRIPTA.Notification.BindingSaved": "ግንኙነት ተቀምጧል።",
  "KRIPTA.Notification.BindingDeleted": "ግንኙነት ተወግዷል።",
  "KRIPTA.Notification.BadCatalogCardNumber": "የተመረጠው ካርድ የማይሰራ ቁጥር አለው። የgetCardsList መልስን እና normalizeCardsListን ይፈትሹ።",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "ይህ ካርድ በእጅ ሊሰጥ አይችልም፣ ምክንያቱም የማይሰራ ቁጥር አለው። የgetCardsList መልስን እና normalizeCardsListን ይፈትሹ።",
  "KRIPTA.Notification.CardOutputFailed": "ካርዱን ወደ ቻት መለጠፍ አልተሳካም",
  "KRIPTA.Notification.CardGiveFailed": "ካርድ መስጠት አልተሳካም",
  "KRIPTA.Notification.CardUseFailed": "ካርድ መጠቀም አልተሳካም",
  "KRIPTA.Notification.CardTakeFailed": "ካርድ ማስወገድ አልተሳካም",
  "KRIPTA.Notification.CardRequestFailed": "የካርድ ጥያቄ መላክ አልተሳካም",
  "KRIPTA.Notification.CardRequestConfirmFailed": "የካርድ መስጠትን ማረጋገጥ አልተሳካም",
  "KRIPTA.Notification.PlayerAddFailed": "ተጫዋች መጨመር አልተሳካም",
  "KRIPTA.Notification.PlayerUpdateFailed": "ተጫዋች ማዘመን አልተሳካም",
  "KRIPTA.Notification.PlayerDeleteFailed": "ተጫዋች መሰረዝ አልተሳካም",
  "KRIPTA.Notification.CardRollFailed": "ካርድ መቀበል አልተሳካም።",
  "KRIPTA.Dialog.TakeCard.Title": "ካርድ አስወግድ",
  "KRIPTA.Dialog.TakeCard.Message": "ተጫዋች {playerName} ካርድ {cardName} ያጣል።",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "ካርድ ስጥ"
}
__END_LOCALE_JSON__
