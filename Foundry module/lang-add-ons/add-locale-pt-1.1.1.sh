#!/usr/bin/env sh
set -eu

if [ ! -f "dmicher-kripta-cards/module.json" ]; then
  echo "Run this script from the Foundry module workspace root, next to dmicher-kripta-cards/module.json." >&2
  exit 1
fi

SCRIPT_FILE="$0"
LOCALE_PATH="dmicher-kripta-cards/lang/pt.json"
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
  "lang": "pt",
  "name": "Português",
  "path": "lang/pt.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "Seu usuário do Foundry não está vinculado a um jogador do servidor no módulo Kripta Cards. Entre em contato com o Mestre de Jogo.",
  "KRIPTA.GMOnly": "Esta ação está disponível apenas para o Mestre de Jogo.",
  "KRIPTA.Settings.ServerUrl.Name": "Endereço do servidor",
  "KRIPTA.Settings.TechAuthUsers.Name": "Usuários técnicos",
  "KRIPTA.Settings.PlayerBindings.Name": "Vínculos entre usuários do Foundry e jogadores do servidor",
  "KRIPTA.Settings.UiPrefs.Name": "Configurações locais da interface",
  "KRIPTA.Settings.Menu.Name": "Kripta Cards",
  "KRIPTA.Settings.Menu.Label": "Configurações do módulo",
  "KRIPTA.Settings.Menu.Hint": "Conexão com a API e usuários técnicos.",
  "KRIPTA.Settings.Help.BeforeServerLink": "Se você ainda não instalou e configurou o servidor de conteúdo para o módulo, acesse ",
  "KRIPTA.Settings.Help.ServerLink": "este link",
  "KRIPTA.Settings.Help.AfterServerLink": " para fazer isso. Para uma configuração rápida, use a ",
  "KRIPTA.Settings.Help.DocumentationLink": "documentação",
  "KRIPTA.Settings.Help.AfterDocumentationLink": ".",
  "KRIPTA.Window.Catalog": "Catálogo de cartas",
  "KRIPTA.Window.CardDetails": "Carta do catálogo",
  "KRIPTA.Window.GiveCard": "Dar carta",
  "KRIPTA.Window.MyCards": "Cartas do jogador",
  "KRIPTA.Window.Players": "Gerenciar jogadores",
  "KRIPTA.Window.Registry": "Registro de jogadores",
  "KRIPTA.Window.RequestCard": "Solicitar carta",
  "KRIPTA.Window.Settings": "Kripta Cards - Configurações",
  "KRIPTA.Window.UseCard": "Usar carta",
  "KRIPTA.Menu.Title": "Kripta Cards",
  "KRIPTA.Menu.Catalog": "Catálogo de cartas",
  "KRIPTA.Menu.GetCard": "Solicitar carta",
  "KRIPTA.Menu.MyCards": "Minhas cartas",
  "KRIPTA.Menu.Players": "Gerenciar jogadores",
  "KRIPTA.Label.Category": "Categoria",
  "KRIPTA.Label.Mode": "Modo",
  "KRIPTA.Label.Card": "Carta",
  "KRIPTA.Label.Player": "Jogador",
  "KRIPTA.Label.Name": "Nome",
  "KRIPTA.Label.Comment": "Comentário",
  "KRIPTA.Label.CardTypes": "Tipos de carta",
  "KRIPTA.Label.Count": "Quantidade",
  "KRIPTA.Label.ConfirmationCode": "Código de confirmação",
  "KRIPTA.Label.Id": "Id",
  "KRIPTA.Label.Key": "Chave",
  "KRIPTA.Label.ServerUrl": "URL do servidor",
  "KRIPTA.Label.Writer": "Writer",
  "KRIPTA.Label.Reader": "Reader",
  "KRIPTA.Label.Role": "Função",
  "KRIPTA.Label.Binding": "Vínculo",
  "KRIPTA.Role.GM": "Mestre de Jogo",
  "KRIPTA.Role.Player": "Jogador",
  "KRIPTA.Status.InGame": "online",
  "KRIPTA.Status.Offline": "offline",
  "KRIPTA.Binding.CardsIssued": "cartas dadas:",
  "KRIPTA.Binding.NoCards": "sem cartas",
  "KRIPTA.Binding.NotBound": "jogador não está vinculado, vincule um jogador.",
  "KRIPTA.Binding.CardsCountHint": "Número de tipos de cartas dadas, sem contar duplicadas",
  "KRIPTA.Button.Add": "Adicionar",
  "KRIPTA.Button.Bind": "Vincular",
  "KRIPTA.Button.Cancel": "Cancelar",
  "KRIPTA.Button.Close": "Fechar",
  "KRIPTA.Button.Confirm": "Confirmar",
  "KRIPTA.Button.Delete": "Excluir",
  "KRIPTA.Button.Edit": "Editar",
  "KRIPTA.Button.Give": "Dar",
  "KRIPTA.Button.GiveCard": "Dar carta",
  "KRIPTA.Button.Info": "Info",
  "KRIPTA.Button.No": "Não",
  "KRIPTA.Button.Output": "Publicar",
  "KRIPTA.Button.Refresh": "Atualizar",
  "KRIPTA.Button.Registry": "Registro de jogadores",
  "KRIPTA.Button.Request": "Solicitar",
  "KRIPTA.Button.RequestCard": "Solicitar",
  "KRIPTA.Button.SaveChanges": "Salvar alterações",
  "KRIPTA.Button.Take": "Retirar",
  "KRIPTA.Button.TestAuth": "Verificar usuários técnicos",
  "KRIPTA.Button.TestServer": "Verificar servidor",
  "KRIPTA.Button.Unbind": "Desvincular",
  "KRIPTA.Button.Use": "Usar",
  "KRIPTA.Button.Yes": "Sim",
  "KRIPTA.Mode.Manual": "Escolher manualmente",
  "KRIPTA.Mode.Random": "Aleatória",
  "KRIPTA.Mode.Show": "Mostrar",
  "KRIPTA.Mode.Spend": "Gastar",
  "KRIPTA.View.Table": "Tabela",
  "KRIPTA.View.Tiles": "Blocos",
  "KRIPTA.Placeholder.Search": "Pesquisar",
  "KRIPTA.Select.NotSelected": "-- não selecionado --",
  "KRIPTA.Template.EmptyCatalog": "Não há categorias ou cartas registradas no servidor.",
  "KRIPTA.Template.MyCardsTitle": "Cartas do jogador: {playerName}",
  "KRIPTA.Template.UseCardMissing": "Esta carta não está mais registrada no servidor.",
  "KRIPTA.Template.UseCardPrompt": "Esta carta será usada:",
  "KRIPTA.Card.FallbackName": "Carta {number}",
  "KRIPTA.Card.FallbackAddress": "Carta {level}/{number}",
  "KRIPTA.Card.MissingDescription": "A carta {level}/{number} está ausente do catálogo atual do servidor.",
  "KRIPTA.Card.NotRegisteredDescription": "A carta {level}/{number} não está mais registrada no servidor.",
  "KRIPTA.Level.FallbackName": "Nível {level}",
  "KRIPTA.Level.MissingDescription": "Este nível existe no inventário do jogador, mas está ausente do catálogo atual do servidor.",
  "KRIPTA.Chat.BlobReadFailed": "Falha ao ler blob",
  "KRIPTA.Chat.CardGivenTitle": "Carta dada",
  "KRIPTA.Chat.CardReceiveSubtitle": "O jogador {playerName} recebe a carta {cardSubtitle}",
  "KRIPTA.Chat.CardRequestCanceled": "Solicitação de carta cancelada.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "Solicitação de carta confirmada",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "Falha ao ler os dados da solicitação.",
  "KRIPTA.Chat.CardSpentFooter": "CARTA GASTA",
  "KRIPTA.Chat.CardSpentTitle": "Carta gasta",
  "KRIPTA.Chat.FallbackPlayer": "jogador",
  "KRIPTA.Chat.ManualChoiceFooter": "ESCOLHA MANUAL",
  "KRIPTA.Chat.ReferenceTitle": "Referência",
  "KRIPTA.Chat.RequestManualTitle": "Solicitação de carta escolhida",
  "KRIPTA.Chat.RequestRandomTitle": "Solicitação de carta aleatória",
  "KRIPTA.Chat.ShowCardTitle": "Referência da carta",
  "KRIPTA.Dialog.BindPlayer.Title": "Vincular jogador do servidor",
  "KRIPTA.Dialog.BindPlayer.Header": "Escolha um jogador para {foundryUserName}",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "usuário do Foundry",
  "KRIPTA.Dialog.Player.AddTitle": "Adicionar jogador",
  "KRIPTA.Dialog.Player.EditTitle": "Editar jogador",
  "KRIPTA.Dialog.Player.DeleteTitle": "Excluir jogador",
  "KRIPTA.Dialog.Player.DeleteWarning": "Excluir o jogador \"{playerName}\" não pode ser desfeito. Digite \"{code}\" e confirme a exclusão.",
  "KRIPTA.Dialog.Count.TotalCards": "total de cartas deste tipo - {max}",
  "KRIPTA.Error.InvalidCardLevel": "Nível inválido para {context}: {level}",
  "KRIPTA.Error.InvalidCardNumber": "Número inválido para {context}: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "nível de carta inválido: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "número de carta inválido: {number}",
  "KRIPTA.Error.InvalidRequestCard": "Carta inválida para solicitação",
  "KRIPTA.Error.InvalidGiveCard": "Carta inválida para dar",
  "KRIPTA.Error.MissingRequestPlayerGuid": "Falha ao determinar playerGuid para dar a carta.",
  "KRIPTA.Error.MissingSelectedCard": "Falha ao determinar a carta selecionada.",
  "KRIPTA.Error.MissingSelectedCardForGive": "Falha ao determinar a carta selecionada para dar.",
  "KRIPTA.Error.MissingGivePlayer": "Falha ao determinar o jogador que receberá a carta.",
  "KRIPTA.Error.MissingGiveCard": "Falha ao determinar a carta a ser dada.",
  "KRIPTA.Error.MissingServerUrl": "A configuração do caminho do servidor está ausente.",
  "KRIPTA.Error.InvalidReader": "O usuário técnico Reader está configurado incorretamente.",
  "KRIPTA.Error.InvalidWriter": "O usuário técnico Writer está configurado incorretamente.",
  "KRIPTA.Error.MenuUnavailable": "Este recurso está indisponível. Verifique as configurações do módulo. Os detalhes estão no console do navegador.",
  "KRIPTA.Error.Generic": "Ocorreu um erro",
  "KRIPTA.Error.Unknown": "erro desconhecido",
  "KRIPTA.Error.NameRequired": "O campo Name é obrigatório.",
  "KRIPTA.Error.RegistryDeleteReturned": "o servidor retornou o jogador no registro após a exclusão.",
  "KRIPTA.Notification.CardGiven": "Carta dada.",
  "KRIPTA.Notification.CardUsed": "Carta usada e gasta.",
  "KRIPTA.Notification.CardWrittenOff": "Carta removida.",
  "KRIPTA.Notification.CannotUseMissingCard": "Esta carta não está mais registrada no servidor. Ela não pode ser usada.",
  "KRIPTA.Notification.MissingCard": "Esta carta não está mais registrada no servidor.",
  "KRIPTA.Notification.PlayerNotSelected": "Nenhum jogador selecionado para receber a carta",
  "KRIPTA.Notification.PlayerBindingMissing": "Falha ao determinar o vínculo do jogador para dar a carta",
  "KRIPTA.Notification.RequestSent": "Solicitação de carta enviada para o chat.",
  "KRIPTA.Notification.ServerSuccess": "Conexão bem-sucedida.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "Conexão bem-sucedida. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "Falha ao conectar ao servidor. Verifique o endereço, a disponibilidade do servidor e as configurações de CORS/HTTPS.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "Falha ao verificar o servidor.",
  "KRIPTA.Notification.InvalidServerUrl": "Endereço do servidor inválido: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "A seção de configurações do Kripta Cards está disponível apenas para as funções Mestre de Jogo e Mestre de Jogo Assistente.",
  "KRIPTA.Notification.ServerCheckFailed": "Verificação do servidor falhou",
  "KRIPTA.Notification.TechUserReader": "Reader",
  "KRIPTA.Notification.TechUserWriter": "Writer",
  "KRIPTA.Notification.TechUsersCheckSuccess": "Os usuários técnicos \"Reader\" e \"Writer\" passaram na verificação.",
  "KRIPTA.Notification.SettingsSaved": "Configurações de conexão salvas.",
  "KRIPTA.Notification.PlayerAdded": "Jogador adicionado.",
  "KRIPTA.Notification.PlayerUpdated": "Jogador atualizado.",
  "KRIPTA.Notification.PlayerDeleted": "Jogador excluído.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "Exclusão cancelada. O campo de confirmação foi preenchido incorretamente.",
  "KRIPTA.Notification.BindingSaved": "Vínculo salvo.",
  "KRIPTA.Notification.BindingDeleted": "Vínculo removido.",
  "KRIPTA.Notification.BadCatalogCardNumber": "A carta selecionada tem um número inválido. Verifique a resposta de getCardsList e normalizeCardsList.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "Esta carta não pode ser dada manualmente porque tem um número inválido. Verifique a resposta de getCardsList e normalizeCardsList.",
  "KRIPTA.Notification.CardOutputFailed": "Falha ao publicar a carta no chat",
  "KRIPTA.Notification.CardGiveFailed": "Falha ao dar carta",
  "KRIPTA.Notification.CardUseFailed": "Falha ao usar carta",
  "KRIPTA.Notification.CardTakeFailed": "Falha ao remover carta",
  "KRIPTA.Notification.CardRequestFailed": "Falha ao enviar solicitação de carta",
  "KRIPTA.Notification.CardRequestConfirmFailed": "Falha ao confirmar a entrega da carta",
  "KRIPTA.Notification.PlayerAddFailed": "Falha ao adicionar jogador",
  "KRIPTA.Notification.PlayerUpdateFailed": "Falha ao atualizar jogador",
  "KRIPTA.Notification.PlayerDeleteFailed": "Falha ao excluir jogador",
  "KRIPTA.Notification.CardRollFailed": "Falha ao receber carta.",
  "KRIPTA.Dialog.TakeCard.Title": "Retirar carta",
  "KRIPTA.Dialog.TakeCard.Message": "O jogador {playerName} perderá a carta {cardName}.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Dar carta"
}
__END_LOCALE_JSON__
