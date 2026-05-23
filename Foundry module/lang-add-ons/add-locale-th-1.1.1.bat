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
$localePath = 'dmicher-kripta-cards/lang/th.json'
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
  "lang": "th",
  "name": "ไทย",
  "path": "lang/th.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "ผู้ใช้ Foundry ของคุณยังไม่ได้เชื่อมกับผู้เล่นบนเซิร์ฟเวอร์ในโมดูล Kripta Cards โปรดติดต่อ Game Master",
  "KRIPTA.GMOnly": "การกระทำนี้ใช้ได้เฉพาะ Game Master เท่านั้น",
  "KRIPTA.Settings.ServerUrl.Name": "ที่อยู่เซิร์ฟเวอร์",
  "KRIPTA.Settings.TechAuthUsers.Name": "ผู้ใช้ทางเทคนิค",
  "KRIPTA.Settings.PlayerBindings.Name": "การเชื่อมผู้ใช้ Foundry กับผู้เล่นบนเซิร์ฟเวอร์",
  "KRIPTA.Settings.UiPrefs.Name": "การตั้งค่าอินเทอร์เฟซในเครื่อง",
  "KRIPTA.Settings.Menu.Name": "Kripta Cards",
  "KRIPTA.Settings.Menu.Label": "การตั้งค่าโมดูล",
  "KRIPTA.Settings.Menu.Hint": "การเชื่อมต่อ API และผู้ใช้ทางเทคนิค",
  "KRIPTA.Settings.Help.BeforeServerLink": "หากคุณยังไม่ได้ติดตั้งและกำหนดค่าเซิร์ฟเวอร์เนื้อหาสำหรับโมดูล ให้ไปที่",
  "KRIPTA.Settings.Help.ServerLink": "ลิงก์นี้",
  "KRIPTA.Settings.Help.AfterServerLink": "เพื่อดำเนินการ สำหรับการตั้งค่าอย่างรวดเร็ว ให้ใช้",
  "KRIPTA.Settings.Help.DocumentationLink": "เอกสารประกอบ",
  "KRIPTA.Settings.Help.AfterDocumentationLink": ".",
  "KRIPTA.Window.Catalog": "แคตตาล็อกการ์ด",
  "KRIPTA.Window.CardDetails": "การ์ดในแคตตาล็อก",
  "KRIPTA.Window.GiveCard": "มอบการ์ด",
  "KRIPTA.Window.MyCards": "การ์ดของผู้เล่น",
  "KRIPTA.Window.Players": "จัดการผู้เล่น",
  "KRIPTA.Window.Registry": "ทะเบียนผู้เล่น",
  "KRIPTA.Window.RequestCard": "ขอการ์ด",
  "KRIPTA.Window.Settings": "Kripta Cards - การตั้งค่า",
  "KRIPTA.Window.UseCard": "ใช้การ์ด",
  "KRIPTA.Menu.Title": "Kripta Cards",
  "KRIPTA.Menu.Catalog": "แคตตาล็อกการ์ด",
  "KRIPTA.Menu.GetCard": "ขอการ์ด",
  "KRIPTA.Menu.MyCards": "การ์ดของฉัน",
  "KRIPTA.Menu.Players": "จัดการผู้เล่น",
  "KRIPTA.Label.Category": "หมวดหมู่",
  "KRIPTA.Label.Mode": "โหมด",
  "KRIPTA.Label.Card": "การ์ด",
  "KRIPTA.Label.Player": "ผู้เล่น",
  "KRIPTA.Label.Name": "ชื่อ",
  "KRIPTA.Label.Comment": "ความคิดเห็น",
  "KRIPTA.Label.CardTypes": "ประเภทการ์ด",
  "KRIPTA.Label.Count": "จำนวน",
  "KRIPTA.Label.ConfirmationCode": "รหัสยืนยัน",
  "KRIPTA.Label.Id": "Id",
  "KRIPTA.Label.Key": "Key",
  "KRIPTA.Label.ServerUrl": "URL เซิร์ฟเวอร์",
  "KRIPTA.Label.Writer": "Writer",
  "KRIPTA.Label.Reader": "Reader",
  "KRIPTA.Label.Role": "บทบาท",
  "KRIPTA.Label.Binding": "การเชื่อม",
  "KRIPTA.Role.GM": "Game Master",
  "KRIPTA.Role.Player": "ผู้เล่น",
  "KRIPTA.Status.InGame": "ออนไลน์",
  "KRIPTA.Status.Offline": "ออฟไลน์",
  "KRIPTA.Binding.CardsIssued": "การ์ดที่มอบแล้ว:",
  "KRIPTA.Binding.NoCards": "ไม่มีการ์ด",
  "KRIPTA.Binding.NotBound": "ผู้เล่นยังไม่ได้เชื่อม โปรดเชื่อมผู้เล่น",
  "KRIPTA.Binding.CardsCountHint": "จำนวนประเภทการ์ดที่มอบแล้ว โดยไม่นับรายการซ้ำ",
  "KRIPTA.Button.Add": "เพิ่ม",
  "KRIPTA.Button.Bind": "เชื่อม",
  "KRIPTA.Button.Cancel": "ยกเลิก",
  "KRIPTA.Button.Close": "ปิด",
  "KRIPTA.Button.Confirm": "ยืนยัน",
  "KRIPTA.Button.Delete": "ลบ",
  "KRIPTA.Button.Edit": "แก้ไข",
  "KRIPTA.Button.Give": "มอบ",
  "KRIPTA.Button.GiveCard": "มอบการ์ด",
  "KRIPTA.Button.Info": "ข้อมูล",
  "KRIPTA.Button.No": "ไม่",
  "KRIPTA.Button.Output": "โพสต์",
  "KRIPTA.Button.Refresh": "รีเฟรช",
  "KRIPTA.Button.Registry": "ทะเบียนผู้เล่น",
  "KRIPTA.Button.Request": "ขอ",
  "KRIPTA.Button.RequestCard": "ขอ",
  "KRIPTA.Button.SaveChanges": "บันทึกการเปลี่ยนแปลง",
  "KRIPTA.Button.Take": "นำออก",
  "KRIPTA.Button.TestAuth": "ตรวจสอบผู้ใช้ทางเทคนิค",
  "KRIPTA.Button.TestServer": "ตรวจสอบเซิร์ฟเวอร์",
  "KRIPTA.Button.Unbind": "ยกเลิกการเชื่อม",
  "KRIPTA.Button.Use": "ใช้",
  "KRIPTA.Button.Yes": "ใช่",
  "KRIPTA.Mode.Manual": "เลือกเอง",
  "KRIPTA.Mode.Random": "สุ่ม",
  "KRIPTA.Mode.Show": "แสดง",
  "KRIPTA.Mode.Spend": "ใช้หมด",
  "KRIPTA.View.Table": "ตาราง",
  "KRIPTA.View.Tiles": "ไทล์",
  "KRIPTA.Placeholder.Search": "ค้นหา",
  "KRIPTA.Select.NotSelected": "-- ยังไม่ได้เลือก --",
  "KRIPTA.Template.EmptyCatalog": "ไม่มีหมวดหมู่หรือการ์ดที่ลงทะเบียนไว้บนเซิร์ฟเวอร์",
  "KRIPTA.Template.MyCardsTitle": "การ์ดของผู้เล่น: {playerName}",
  "KRIPTA.Template.UseCardMissing": "การ์ดนี้ไม่ได้ลงทะเบียนบนเซิร์ฟเวอร์อีกต่อไป",
  "KRIPTA.Template.UseCardPrompt": "จะใช้การ์ดนี้:",
  "KRIPTA.Card.FallbackName": "การ์ด {number}",
  "KRIPTA.Card.FallbackAddress": "การ์ด {level}/{number}",
  "KRIPTA.Card.MissingDescription": "การ์ด {level}/{number} ไม่มีอยู่ในแคตตาล็อกเซิร์ฟเวอร์ปัจจุบัน",
  "KRIPTA.Card.NotRegisteredDescription": "การ์ด {level}/{number} ไม่ได้ลงทะเบียนบนเซิร์ฟเวอร์อีกต่อไป",
  "KRIPTA.Level.FallbackName": "เลเวล {level}",
  "KRIPTA.Level.MissingDescription": "เลเวลนี้มีอยู่ในคลังของผู้เล่น แต่ไม่มีอยู่ในแคตตาล็อกเซิร์ฟเวอร์ปัจจุบัน",
  "KRIPTA.Chat.BlobReadFailed": "อ่าน blob ไม่สำเร็จ",
  "KRIPTA.Chat.CardGivenTitle": "มอบการ์ดแล้ว",
  "KRIPTA.Chat.CardReceiveSubtitle": "ผู้เล่น {playerName} ได้รับการ์ด {cardSubtitle}",
  "KRIPTA.Chat.CardRequestCanceled": "ยกเลิกคำขอการ์ดแล้ว",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "ยืนยันคำขอการ์ดแล้ว",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "อ่านข้อมูลคำขอไม่สำเร็จ",
  "KRIPTA.Chat.CardSpentFooter": "การ์ดถูกใช้หมดแล้ว",
  "KRIPTA.Chat.CardSpentTitle": "การ์ดถูกใช้หมดแล้ว",
  "KRIPTA.Chat.FallbackPlayer": "ผู้เล่น",
  "KRIPTA.Chat.ManualChoiceFooter": "เลือกเอง",
  "KRIPTA.Chat.ReferenceTitle": "อ้างอิง",
  "KRIPTA.Chat.RequestManualTitle": "คำขอการ์ดที่เลือก",
  "KRIPTA.Chat.RequestRandomTitle": "คำขอการ์ดสุ่ม",
  "KRIPTA.Chat.ShowCardTitle": "อ้างอิงการ์ด",
  "KRIPTA.Dialog.BindPlayer.Title": "เชื่อมผู้เล่นเซิร์ฟเวอร์",
  "KRIPTA.Dialog.BindPlayer.Header": "เลือกผู้เล่นสำหรับ {foundryUserName}",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "ผู้ใช้ Foundry",
  "KRIPTA.Dialog.Player.AddTitle": "เพิ่มผู้เล่น",
  "KRIPTA.Dialog.Player.EditTitle": "แก้ไขผู้เล่น",
  "KRIPTA.Dialog.Player.DeleteTitle": "ลบผู้เล่น",
  "KRIPTA.Dialog.Player.DeleteWarning": "การลบผู้เล่น \"{playerName}\" ไม่สามารถย้อนกลับได้ ป้อน \"{code}\" และยืนยันการลบ",
  "KRIPTA.Dialog.Count.TotalCards": "จำนวนการ์ดทั้งหมดของประเภทนี้ - {max}",
  "KRIPTA.Error.InvalidCardLevel": "เลเวลไม่ถูกต้องสำหรับ {context}: {level}",
  "KRIPTA.Error.InvalidCardNumber": "หมายเลขไม่ถูกต้องสำหรับ {context}: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "เลเวลการ์ดไม่ถูกต้อง: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "หมายเลขการ์ดไม่ถูกต้อง: {number}",
  "KRIPTA.Error.InvalidRequestCard": "การ์ดไม่ถูกต้องสำหรับคำขอ",
  "KRIPTA.Error.InvalidGiveCard": "การ์ดไม่ถูกต้องสำหรับการมอบ",
  "KRIPTA.Error.MissingRequestPlayerGuid": "ไม่สามารถระบุ playerGuid สำหรับการมอบการ์ดได้",
  "KRIPTA.Error.MissingSelectedCard": "ไม่สามารถระบุการ์ดที่เลือกได้",
  "KRIPTA.Error.MissingSelectedCardForGive": "ไม่สามารถระบุการ์ดที่เลือกสำหรับการมอบได้",
  "KRIPTA.Error.MissingGivePlayer": "ไม่สามารถระบุผู้เล่นที่จะได้รับการ์ดได้",
  "KRIPTA.Error.MissingGiveCard": "ไม่สามารถระบุการ์ดที่จะมอบได้",
  "KRIPTA.Error.MissingServerUrl": "ไม่มีการตั้งค่าเส้นทางเซิร์ฟเวอร์",
  "KRIPTA.Error.InvalidReader": "ผู้ใช้ทางเทคนิค Reader กำหนดค่าไม่ถูกต้อง",
  "KRIPTA.Error.InvalidWriter": "ผู้ใช้ทางเทคนิค Writer กำหนดค่าไม่ถูกต้อง",
  "KRIPTA.Error.MenuUnavailable": "ฟีเจอร์นี้ไม่พร้อมใช้งาน ตรวจสอบการตั้งค่าโมดูล รายละเอียดอยู่ในคอนโซลของเบราว์เซอร์",
  "KRIPTA.Error.Generic": "เกิดข้อผิดพลาด",
  "KRIPTA.Error.Unknown": "ข้อผิดพลาดที่ไม่รู้จัก",
  "KRIPTA.Error.NameRequired": "ต้องกรอกฟิลด์ Name",
  "KRIPTA.Error.RegistryDeleteReturned": "เซิร์ฟเวอร์ส่งผู้เล่นกลับมาในทะเบียนหลังจากลบแล้ว",
  "KRIPTA.Notification.CardGiven": "มอบการ์ดแล้ว",
  "KRIPTA.Notification.CardUsed": "ใช้และใช้หมดการ์ดแล้ว",
  "KRIPTA.Notification.CardWrittenOff": "นำการ์ดออกแล้ว",
  "KRIPTA.Notification.CannotUseMissingCard": "การ์ดนี้ไม่ได้ลงทะเบียนบนเซิร์ฟเวอร์อีกต่อไป จึงไม่สามารถใช้ได้",
  "KRIPTA.Notification.MissingCard": "การ์ดนี้ไม่ได้ลงทะเบียนบนเซิร์ฟเวอร์อีกต่อไป",
  "KRIPTA.Notification.PlayerNotSelected": "ไม่ได้เลือกผู้เล่นสำหรับมอบการ์ด",
  "KRIPTA.Notification.PlayerBindingMissing": "ไม่สามารถระบุการเชื่อมผู้เล่นสำหรับการมอบการ์ดได้",
  "KRIPTA.Notification.RequestSent": "ส่งคำขอการ์ดไปยังแชตแล้ว",
  "KRIPTA.Notification.ServerSuccess": "เชื่อมต่อสำเร็จ",
  "KRIPTA.Notification.ServerSuccessWithDetails": "เชื่อมต่อสำเร็จ {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "เชื่อมต่อเซิร์ฟเวอร์ไม่สำเร็จ ตรวจสอบที่อยู่ ความพร้อมใช้งานของเซิร์ฟเวอร์ และการตั้งค่า CORS/HTTPS",
  "KRIPTA.Notification.ServerCheckFailedFallback": "ตรวจสอบเซิร์ฟเวอร์ไม่สำเร็จ",
  "KRIPTA.Notification.InvalidServerUrl": "ที่อยู่เซิร์ฟเวอร์ไม่ถูกต้อง: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "ส่วนการตั้งค่า Kripta Cards ใช้ได้เฉพาะบทบาท Game Master และ Assistant Game Master",
  "KRIPTA.Notification.ServerCheckFailed": "การตรวจสอบเซิร์ฟเวอร์ล้มเหลว",
  "KRIPTA.Notification.TechUserReader": "Reader",
  "KRIPTA.Notification.TechUserWriter": "Writer",
  "KRIPTA.Notification.TechUsersCheckSuccess": "ผู้ใช้ทางเทคนิค \"Reader\" และ \"Writer\" ผ่านการตรวจสอบ",
  "KRIPTA.Notification.SettingsSaved": "บันทึกการตั้งค่าการเชื่อมต่อแล้ว",
  "KRIPTA.Notification.PlayerAdded": "เพิ่มผู้เล่นแล้ว",
  "KRIPTA.Notification.PlayerUpdated": "อัปเดตผู้เล่นแล้ว",
  "KRIPTA.Notification.PlayerDeleted": "ลบผู้เล่นแล้ว",
  "KRIPTA.Notification.DeleteCanceledBadCode": "ยกเลิกการลบแล้ว ช่องยืนยันถูกกรอกไม่ถูกต้อง",
  "KRIPTA.Notification.BindingSaved": "บันทึกการเชื่อมแล้ว",
  "KRIPTA.Notification.BindingDeleted": "ลบการเชื่อมแล้ว",
  "KRIPTA.Notification.BadCatalogCardNumber": "การ์ดที่เลือกมีหมายเลขไม่ถูกต้อง ตรวจสอบการตอบกลับ getCardsList และ normalizeCardsList",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "การ์ดนี้ไม่สามารถมอบด้วยตนเองได้ เพราะมีหมายเลขไม่ถูกต้อง ตรวจสอบการตอบกลับ getCardsList และ normalizeCardsList",
  "KRIPTA.Notification.CardOutputFailed": "โพสต์การ์ดไปยังแชตไม่สำเร็จ",
  "KRIPTA.Notification.CardGiveFailed": "มอบการ์ดไม่สำเร็จ",
  "KRIPTA.Notification.CardUseFailed": "ใช้การ์ดไม่สำเร็จ",
  "KRIPTA.Notification.CardTakeFailed": "นำการ์ดออกไม่สำเร็จ",
  "KRIPTA.Notification.CardRequestFailed": "ส่งคำขอการ์ดไม่สำเร็จ",
  "KRIPTA.Notification.CardRequestConfirmFailed": "ยืนยันการมอบการ์ดไม่สำเร็จ",
  "KRIPTA.Notification.PlayerAddFailed": "เพิ่มผู้เล่นไม่สำเร็จ",
  "KRIPTA.Notification.PlayerUpdateFailed": "อัปเดตผู้เล่นไม่สำเร็จ",
  "KRIPTA.Notification.PlayerDeleteFailed": "ลบผู้เล่นไม่สำเร็จ",
  "KRIPTA.Notification.CardRollFailed": "รับการ์ดไม่สำเร็จ",
  "KRIPTA.Dialog.TakeCard.Title": "นำการ์ดออก",
  "KRIPTA.Dialog.TakeCard.Message": "ผู้เล่น {playerName} จะเสียการ์ด {cardName}",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "มอบการ์ด"
}
__END_LOCALE_JSON__
