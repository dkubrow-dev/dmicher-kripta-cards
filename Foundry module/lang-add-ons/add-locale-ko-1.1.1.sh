#!/usr/bin/env sh
set -eu

if [ ! -f "dmicher-kripta-cards/module.json" ]; then
  echo "Run this script from the Foundry module workspace root, next to dmicher-kripta-cards/module.json." >&2
  exit 1
fi

SCRIPT_FILE="$0"
LOCALE_PATH="dmicher-kripta-cards/lang/ko.json"
mkdir -p "dmicher-kripta-cards/lang"
awk '/^__LOCALE_JSON__$/ {p=1; next} /^__END_LOCALE_JSON__$/ {p=0} p' "$SCRIPT_FILE" > "$LOCALE_PATH"

if command -v node >/dev/null 2>&1; then
  SCRIPT_FILE="$SCRIPT_FILE" node <<'NODE'
const fs = require("fs");
const script = fs.readFileSync(process.env.SCRIPT_FILE, "utf8");
function block(name) {
  const match = script.match(new RegExp("__" + name + "__\\r?\\n([\\s\\S]*?)\\r?\\n__END_" + name + "__"));
  if (!match) throw new Error("Missing block " + name);
  return match[1].trim();
}
const entry = JSON.parse(block("MANIFEST_JSON"));
const manifestPath = "dmicher-kripta-cards/module.json";
const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
manifest.languages = Array.isArray(manifest.languages) ? manifest.languages : [];
if (!manifest.languages.some((item) => item.lang === entry.lang)) {
  manifest.languages.push(entry);
}
fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2) + "\n", "utf8");
console.log("Locale " + entry.lang + " installed.");
NODE
elif command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1; then
  PYTHON_BIN="$(command -v python3 || command -v python)"
  SCRIPT_FILE="$SCRIPT_FILE" "$PYTHON_BIN" <<'PY'
import json
import os
import re

with open(os.environ["SCRIPT_FILE"], "r", encoding="utf-8") as script_file:
    script = script_file.read()

def block(name):
    match = re.search(r"__" + re.escape(name) + r"__\r?\n([\s\S]*?)\r?\n__END_" + re.escape(name) + r"__", script)
    if not match:
        raise RuntimeError("Missing block " + name)
    return match.group(1).strip()

entry = json.loads(block("MANIFEST_JSON"))
manifest_path = "dmicher-kripta-cards/module.json"
with open(manifest_path, "r", encoding="utf-8") as manifest_file:
    manifest = json.load(manifest_file)
manifest["languages"] = manifest.get("languages") or []
if not any(item.get("lang") == entry["lang"] for item in manifest["languages"]):
    manifest["languages"].append(entry)
with open(manifest_path, "w", encoding="utf-8") as manifest_file:
    json.dump(manifest, manifest_file, ensure_ascii=False, indent=2)
    manifest_file.write("\n")
print("Locale " + entry["lang"] + " installed.")
PY
else
  echo "Locale file was written, but module.json was not updated: install node or python and rerun the script." >&2
  exit 1
fi

exit 0
__MANIFEST_JSON__
{
  "lang": "ko",
  "name": "한국어",
  "path": "lang/ko.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "현재 Foundry 사용자가 Kripta Cards 모듈에서 서버 플레이어와 연결되어 있지 않습니다. 게임 마스터에게 문의하세요.",
  "KRIPTA.GMOnly": "이 작업은 게임 마스터만 사용할 수 있습니다.",
  "KRIPTA.Settings.ServerUrl.Name": "서버 주소",
  "KRIPTA.Settings.TechAuthUsers.Name": "기술 사용자",
  "KRIPTA.Settings.PlayerBindings.Name": "Foundry 사용자와 서버 플레이어 연결",
  "KRIPTA.Settings.UiPrefs.Name": "로컬 인터페이스 설정",
  "KRIPTA.Settings.Menu.Name": "Kripta Cards",
  "KRIPTA.Settings.Menu.Label": "모듈 설정",
  "KRIPTA.Settings.Menu.Hint": "API 연결 및 기술 사용자.",
  "KRIPTA.Settings.Help.BeforeServerLink": "모듈용 콘텐츠 서버를 아직 설치하고 설정하지 않았다면 ",
  "KRIPTA.Settings.Help.ServerLink": "이 링크",
  "KRIPTA.Settings.Help.AfterServerLink": "로 이동해 진행하세요. 빠른 설정을 위해 ",
  "KRIPTA.Settings.Help.DocumentationLink": "문서",
  "KRIPTA.Settings.Help.AfterDocumentationLink": "를 사용하세요.",
  "KRIPTA.Window.Catalog": "카드 카탈로그",
  "KRIPTA.Window.CardDetails": "카탈로그 카드",
  "KRIPTA.Window.GiveCard": "카드 지급",
  "KRIPTA.Window.MyCards": "플레이어 카드",
  "KRIPTA.Window.Players": "플레이어 관리",
  "KRIPTA.Window.Registry": "플레이어 등록부",
  "KRIPTA.Window.RequestCard": "카드 요청",
  "KRIPTA.Window.Settings": "Kripta Cards - 설정",
  "KRIPTA.Window.UseCard": "카드 사용",
  "KRIPTA.Menu.Title": "Kripta Cards",
  "KRIPTA.Menu.Catalog": "카드 카탈로그",
  "KRIPTA.Menu.GetCard": "카드 요청",
  "KRIPTA.Menu.MyCards": "내 카드",
  "KRIPTA.Menu.Players": "플레이어 관리",
  "KRIPTA.Label.Category": "카테고리",
  "KRIPTA.Label.Mode": "모드",
  "KRIPTA.Label.Card": "카드",
  "KRIPTA.Label.Player": "플레이어",
  "KRIPTA.Label.Name": "이름",
  "KRIPTA.Label.Comment": "댓글",
  "KRIPTA.Label.CardTypes": "카드 종류",
  "KRIPTA.Label.Count": "수량",
  "KRIPTA.Label.ConfirmationCode": "확인 코드",
  "KRIPTA.Label.Id": "Id",
  "KRIPTA.Label.Key": "Key",
  "KRIPTA.Label.ServerUrl": "서버 URL",
  "KRIPTA.Label.Writer": "Writer",
  "KRIPTA.Label.Reader": "Reader",
  "KRIPTA.Label.Role": "역할",
  "KRIPTA.Label.Binding": "연결",
  "KRIPTA.Role.GM": "게임 마스터",
  "KRIPTA.Role.Player": "플레이어",
  "KRIPTA.Status.InGame": "게임 중",
  "KRIPTA.Status.Offline": "오프라인",
  "KRIPTA.Binding.CardsIssued": "지급된 카드:",
  "KRIPTA.Binding.NoCards": "카드 없음",
  "KRIPTA.Binding.NotBound": "플레이어가 연결되어 있지 않습니다. 플레이어를 선택하세요.",
  "KRIPTA.Binding.CardsCountHint": "중복을 제외한 지급된 카드 종류 수",
  "KRIPTA.Button.Add": "추가",
  "KRIPTA.Button.Bind": "연결",
  "KRIPTA.Button.Cancel": "취소",
  "KRIPTA.Button.Close": "닫기",
  "KRIPTA.Button.Confirm": "확인",
  "KRIPTA.Button.Delete": "삭제",
  "KRIPTA.Button.Edit": "편집",
  "KRIPTA.Button.Give": "지급",
  "KRIPTA.Button.GiveCard": "카드 지급",
  "KRIPTA.Button.Info": "정보",
  "KRIPTA.Button.No": "아니요",
  "KRIPTA.Button.Output": "게시",
  "KRIPTA.Button.Refresh": "새로 고침",
  "KRIPTA.Button.Registry": "플레이어 등록부",
  "KRIPTA.Button.Request": "요청",
  "KRIPTA.Button.RequestCard": "요청",
  "KRIPTA.Button.SaveChanges": "변경 사항 저장",
  "KRIPTA.Button.Take": "회수",
  "KRIPTA.Button.TestAuth": "기술 사용자 확인",
  "KRIPTA.Button.TestServer": "서버 확인",
  "KRIPTA.Button.Unbind": "연결 해제",
  "KRIPTA.Button.Use": "사용",
  "KRIPTA.Button.Yes": "예",
  "KRIPTA.Mode.Manual": "수동 선택",
  "KRIPTA.Mode.Random": "무작위",
  "KRIPTA.Mode.Show": "보이기",
  "KRIPTA.Mode.Spend": "소모",
  "KRIPTA.View.Table": "표",
  "KRIPTA.View.Tiles": "타일",
  "KRIPTA.Placeholder.Search": "검색",
  "KRIPTA.Select.NotSelected": "-- 선택 안 됨 --",
  "KRIPTA.Template.EmptyCatalog": "서버에 등록된 카테고리나 카드가 없습니다.",
  "KRIPTA.Template.MyCardsTitle": "플레이어 카드: {playerName}",
  "KRIPTA.Template.UseCardMissing": "이 카드는 더 이상 서버에 등록되어 있지 않습니다.",
  "KRIPTA.Template.UseCardPrompt": "이 카드가 사용됩니다:",
  "KRIPTA.Card.FallbackName": "카드 {number}",
  "KRIPTA.Card.FallbackAddress": "카드 {level}/{number}",
  "KRIPTA.Card.MissingDescription": "카드 {level}/{number}가 현재 서버 카탈로그에 없습니다.",
  "KRIPTA.Card.NotRegisteredDescription": "카드 {level}/{number}가 더 이상 서버에 등록되어 있지 않습니다.",
  "KRIPTA.Level.FallbackName": "레벨 {level}",
  "KRIPTA.Level.MissingDescription": "이 레벨은 플레이어 인벤토리에 있지만 현재 서버 카탈로그에는 없습니다.",
  "KRIPTA.Chat.BlobReadFailed": "blob을 읽지 못했습니다",
  "KRIPTA.Chat.CardGivenTitle": "카드 지급됨",
  "KRIPTA.Chat.CardReceiveSubtitle": "플레이어 {playerName}이 카드 {cardSubtitle}를 받습니다",
  "KRIPTA.Chat.CardRequestCanceled": "카드 요청이 취소되었습니다.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "카드 요청 확인됨",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "요청 데이터를 읽지 못했습니다.",
  "KRIPTA.Chat.CardSpentFooter": "카드 소모됨",
  "KRIPTA.Chat.CardSpentTitle": "카드 소모됨",
  "KRIPTA.Chat.FallbackPlayer": "플레이어",
  "KRIPTA.Chat.ManualChoiceFooter": "수동 선택",
  "KRIPTA.Chat.ReferenceTitle": "참조",
  "KRIPTA.Chat.RequestManualTitle": "선택 카드 요청",
  "KRIPTA.Chat.RequestRandomTitle": "무작위 카드 요청",
  "KRIPTA.Chat.ShowCardTitle": "카드 참조",
  "KRIPTA.Dialog.BindPlayer.Title": "서버 플레이어 연결",
  "KRIPTA.Dialog.BindPlayer.Header": "{foundryUserName}에 연결할 플레이어 선택",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "Foundry 사용자",
  "KRIPTA.Dialog.Player.AddTitle": "플레이어 추가",
  "KRIPTA.Dialog.Player.EditTitle": "플레이어 편집",
  "KRIPTA.Dialog.Player.DeleteTitle": "플레이어 삭제",
  "KRIPTA.Dialog.Player.DeleteWarning": "플레이어 \"{playerName}\" 삭제는 되돌릴 수 없습니다. {code}를 입력하고 삭제를 확인하세요.",
  "KRIPTA.Dialog.Count.TotalCards": "이 종류의 총 카드 수 - {max}",
  "KRIPTA.Error.InvalidCardLevel": "{context}의 레벨이 올바르지 않습니다: {level}",
  "KRIPTA.Error.InvalidCardNumber": "{context}의 번호가 올바르지 않습니다: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "카드 레벨이 올바르지 않습니다: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "카드 번호가 올바르지 않습니다: {number}",
  "KRIPTA.Error.InvalidRequestCard": "요청할 카드가 올바르지 않습니다",
  "KRIPTA.Error.InvalidGiveCard": "지급할 카드가 올바르지 않습니다",
  "KRIPTA.Error.MissingRequestPlayerGuid": "카드 지급에 필요한 playerGuid를 확인하지 못했습니다.",
  "KRIPTA.Error.MissingSelectedCard": "선택한 카드를 확인하지 못했습니다.",
  "KRIPTA.Error.MissingSelectedCardForGive": "지급할 선택 카드를 확인하지 못했습니다.",
  "KRIPTA.Error.MissingGivePlayer": "카드를 받을 플레이어를 확인하지 못했습니다.",
  "KRIPTA.Error.MissingGiveCard": "지급할 카드를 확인하지 못했습니다.",
  "KRIPTA.Error.MissingServerUrl": "서버 경로 설정이 없습니다.",
  "KRIPTA.Error.InvalidReader": "Reader 기술 사용자가 잘못 구성되었습니다.",
  "KRIPTA.Error.InvalidWriter": "Writer 기술 사용자가 잘못 구성되었습니다.",
  "KRIPTA.Error.MenuUnavailable": "이 기능을 사용할 수 없습니다. 모듈 설정을 확인하세요. 자세한 내용은 브라우저 콘솔에 있습니다.",
  "KRIPTA.Error.Generic": "오류가 발생했습니다",
  "KRIPTA.Error.Unknown": "알 수 없는 오류",
  "KRIPTA.Error.NameRequired": "api 400: Name 필드는 필수입니다.",
  "KRIPTA.Error.RegistryDeleteReturned": "삭제 후 서버가 등록부에서 플레이어를 다시 반환했습니다.",
  "KRIPTA.Notification.CardGiven": "카드가 지급되었습니다.",
  "KRIPTA.Notification.CardUsed": "카드가 사용되고 소모되었습니다.",
  "KRIPTA.Notification.CardWrittenOff": "카드가 제거되었습니다.",
  "KRIPTA.Notification.CannotUseMissingCard": "이 카드는 더 이상 서버에 등록되어 있지 않아 사용할 수 없습니다.",
  "KRIPTA.Notification.MissingCard": "이 카드는 더 이상 서버에 등록되어 있지 않습니다.",
  "KRIPTA.Notification.PlayerNotSelected": "카드를 지급할 플레이어가 선택되지 않았습니다",
  "KRIPTA.Notification.PlayerBindingMissing": "카드 지급을 위한 플레이어 연결을 확인하지 못했습니다",
  "KRIPTA.Notification.RequestSent": "카드 요청을 채팅으로 보냈습니다.",
  "KRIPTA.Notification.ServerSuccess": "연결에 성공했습니다.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "연결에 성공했습니다. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "서버에 연결하지 못했습니다. 주소, 서버 상태, CORS/HTTPS 설정을 확인하세요.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "서버를 확인하지 못했습니다.",
  "KRIPTA.Notification.InvalidServerUrl": "서버 주소가 올바르지 않습니다: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "Kripta Cards 설정 섹션은 게임 마스터와 보조 게임 마스터 역할만 사용할 수 있습니다.",
  "KRIPTA.Notification.ServerCheckFailed": "서버 확인 실패",
  "KRIPTA.Notification.TechUserReader": "Reader",
  "KRIPTA.Notification.TechUserWriter": "Writer",
  "KRIPTA.Notification.TechUsersCheckSuccess": "Reader와 Writer 확인이 통과되었습니다.",
  "KRIPTA.Notification.SettingsSaved": "연결 설정이 저장되었습니다.",
  "KRIPTA.Notification.PlayerAdded": "플레이어가 추가되었습니다.",
  "KRIPTA.Notification.PlayerUpdated": "플레이어가 업데이트되었습니다.",
  "KRIPTA.Notification.PlayerDeleted": "플레이어가 삭제되었습니다.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "삭제가 취소되었습니다. 확인 필드가 잘못 입력되었습니다.",
  "KRIPTA.Notification.BindingSaved": "연결이 저장되었습니다.",
  "KRIPTA.Notification.BindingDeleted": "연결이 제거되었습니다.",
  "KRIPTA.Notification.BadCatalogCardNumber": "선택한 카드의 번호가 올바르지 않습니다. getCardsList 응답과 normalizeCardsList를 확인하세요.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "이 카드는 번호가 올바르지 않아 수동으로 지급할 수 없습니다. getCardsList 응답과 normalizeCardsList를 확인하세요.",
  "KRIPTA.Notification.CardOutputFailed": "카드를 채팅에 게시하지 못했습니다",
  "KRIPTA.Notification.CardGiveFailed": "카드를 지급하지 못했습니다",
  "KRIPTA.Notification.CardUseFailed": "카드를 사용하지 못했습니다",
  "KRIPTA.Notification.CardTakeFailed": "카드를 제거하지 못했습니다",
  "KRIPTA.Notification.CardRequestFailed": "카드 요청을 보내지 못했습니다",
  "KRIPTA.Notification.CardRequestConfirmFailed": "카드 지급을 확인하지 못했습니다",
  "KRIPTA.Notification.PlayerAddFailed": "플레이어를 추가하지 못했습니다",
  "KRIPTA.Notification.PlayerUpdateFailed": "플레이어를 업데이트하지 못했습니다",
  "KRIPTA.Notification.PlayerDeleteFailed": "플레이어를 삭제하지 못했습니다",
  "KRIPTA.Notification.CardRollFailed": "카드를 받지 못했습니다.",
  "KRIPTA.Dialog.TakeCard.Title": "카드 회수",
  "KRIPTA.Dialog.TakeCard.Message": "플레이어 {playerName}이 카드 {cardName}를 잃습니다.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "카드 지급"
}
__END_LOCALE_JSON__
