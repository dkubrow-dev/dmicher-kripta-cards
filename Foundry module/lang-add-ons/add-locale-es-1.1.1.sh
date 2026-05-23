#!/usr/bin/env sh
set -eu

if [ ! -f "dmicher-kripta-cards/module.json" ]; then
  echo "Run this script from the Foundry module workspace root, next to dmicher-kripta-cards/module.json." >&2
  exit 1
fi

SCRIPT_FILE="$0"
LOCALE_PATH="dmicher-kripta-cards/lang/es.json"
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
  "lang": "es",
  "name": "Español",
  "path": "lang/es.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "Tu usuario de Foundry no está vinculado a un jugador del servidor en el módulo Kripta Cards. Contacta con el Director de Juego.",
  "KRIPTA.GMOnly": "Esta acción solo está disponible para el Director de Juego.",
  "KRIPTA.Settings.ServerUrl.Name": "Dirección del servidor",
  "KRIPTA.Settings.TechAuthUsers.Name": "Usuarios técnicos",
  "KRIPTA.Settings.PlayerBindings.Name": "Vinculaciones de usuarios de Foundry con jugadores del servidor",
  "KRIPTA.Settings.UiPrefs.Name": "Configuración local de la interfaz",
  "KRIPTA.Settings.Menu.Name": "Kripta Cards",
  "KRIPTA.Settings.Menu.Label": "Configuración del módulo",
  "KRIPTA.Settings.Menu.Hint": "Conexión con la API y usuarios técnicos.",
  "KRIPTA.Settings.Help.BeforeServerLink": "Si aún no ha instalado y configurado el servidor de contenido para el módulo, siga ",
  "KRIPTA.Settings.Help.ServerLink": "este enlace",
  "KRIPTA.Settings.Help.AfterServerLink": " para hacerlo. Para una configuración rápida, use la ",
  "KRIPTA.Settings.Help.DocumentationLink": "documentación",
  "KRIPTA.Settings.Help.AfterDocumentationLink": ".",
  "KRIPTA.Window.Catalog": "Catálogo de cartas",
  "KRIPTA.Window.CardDetails": "Carta del catálogo",
  "KRIPTA.Window.GiveCard": "Entregar carta",
  "KRIPTA.Window.MyCards": "Cartas del jugador",
  "KRIPTA.Window.Players": "Gestionar jugadores",
  "KRIPTA.Window.Registry": "Registro de jugadores",
  "KRIPTA.Window.RequestCard": "Solicitar carta",
  "KRIPTA.Window.Settings": "Kripta Cards - Configuración",
  "KRIPTA.Window.UseCard": "Usar carta",
  "KRIPTA.Menu.Title": "Kripta Cards",
  "KRIPTA.Menu.Catalog": "Catálogo de cartas",
  "KRIPTA.Menu.GetCard": "Solicitar carta",
  "KRIPTA.Menu.MyCards": "Mis cartas",
  "KRIPTA.Menu.Players": "Gestionar jugadores",
  "KRIPTA.Label.Category": "Categoría",
  "KRIPTA.Label.Mode": "Modo",
  "KRIPTA.Label.Card": "Carta",
  "KRIPTA.Label.Player": "Jugador",
  "KRIPTA.Label.Name": "Nombre",
  "KRIPTA.Label.Comment": "Comentario",
  "KRIPTA.Label.CardTypes": "Tipos de cartas",
  "KRIPTA.Label.Count": "Cantidad",
  "KRIPTA.Label.ConfirmationCode": "Código de confirmación",
  "KRIPTA.Label.Id": "Id",
  "KRIPTA.Label.Key": "Clave",
  "KRIPTA.Label.ServerUrl": "URL del servidor",
  "KRIPTA.Label.Writer": "Escritor",
  "KRIPTA.Label.Reader": "Lector",
  "KRIPTA.Label.Role": "Rol",
  "KRIPTA.Label.Binding": "Vinculación",
  "KRIPTA.Role.GM": "Director de Juego",
  "KRIPTA.Role.Player": "Jugador",
  "KRIPTA.Status.InGame": "en partida",
  "KRIPTA.Status.Offline": "sin conexión",
  "KRIPTA.Binding.CardsIssued": "cartas entregadas:",
  "KRIPTA.Binding.NoCards": "sin cartas",
  "KRIPTA.Binding.NotBound": "el jugador no está vinculado, elige un jugador.",
  "KRIPTA.Binding.CardsCountHint": "Número de tipos de cartas entregadas, sin contar duplicados",
  "KRIPTA.Button.Add": "Añadir",
  "KRIPTA.Button.Bind": "Vincular",
  "KRIPTA.Button.Cancel": "Cancelar",
  "KRIPTA.Button.Close": "Cerrar",
  "KRIPTA.Button.Confirm": "Confirmar",
  "KRIPTA.Button.Delete": "Eliminar",
  "KRIPTA.Button.Edit": "Editar",
  "KRIPTA.Button.Give": "Entregar",
  "KRIPTA.Button.GiveCard": "Entregar carta",
  "KRIPTA.Button.Info": "Información",
  "KRIPTA.Button.No": "No",
  "KRIPTA.Button.Output": "Publicar",
  "KRIPTA.Button.Refresh": "Actualizar",
  "KRIPTA.Button.Registry": "Registro de jugadores",
  "KRIPTA.Button.Request": "Solicitar",
  "KRIPTA.Button.RequestCard": "Solicitar",
  "KRIPTA.Button.SaveChanges": "Guardar cambios",
  "KRIPTA.Button.Take": "Retirar",
  "KRIPTA.Button.TestAuth": "Comprobar usuarios técnicos",
  "KRIPTA.Button.TestServer": "Comprobar servidor",
  "KRIPTA.Button.Unbind": "Desvincular",
  "KRIPTA.Button.Use": "Usar",
  "KRIPTA.Button.Yes": "Sí",
  "KRIPTA.Mode.Manual": "Elegir manualmente",
  "KRIPTA.Mode.Random": "Aleatoria",
  "KRIPTA.Mode.Show": "Mostrar",
  "KRIPTA.Mode.Spend": "Gastar",
  "KRIPTA.View.Table": "Tabla",
  "KRIPTA.View.Tiles": "Mosaico",
  "KRIPTA.Placeholder.Search": "Buscar",
  "KRIPTA.Select.NotSelected": "-- no seleccionado --",
  "KRIPTA.Template.EmptyCatalog": "No hay categorías ni cartas registradas en el servidor.",
  "KRIPTA.Template.MyCardsTitle": "Cartas del jugador: {playerName}",
  "KRIPTA.Template.UseCardMissing": "Esta carta ya no está registrada en el servidor.",
  "KRIPTA.Template.UseCardPrompt": "Se usará esta carta:",
  "KRIPTA.Card.FallbackName": "Carta {number}",
  "KRIPTA.Card.FallbackAddress": "Carta {level}/{number}",
  "KRIPTA.Card.MissingDescription": "La carta {level}/{number} no está en el catálogo actual del servidor.",
  "KRIPTA.Card.NotRegisteredDescription": "La carta {level}/{number} ya no está registrada en el servidor.",
  "KRIPTA.Level.FallbackName": "Nivel {level}",
  "KRIPTA.Level.MissingDescription": "Este nivel existe en el inventario del jugador, pero falta en el catálogo actual del servidor.",
  "KRIPTA.Chat.BlobReadFailed": "No se pudo leer el blob",
  "KRIPTA.Chat.CardGivenTitle": "Carta entregada",
  "KRIPTA.Chat.CardReceiveSubtitle": "El jugador {playerName} recibe la carta {cardSubtitle}",
  "KRIPTA.Chat.CardRequestCanceled": "Solicitud de carta cancelada.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "Solicitud de carta confirmada",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "No se pudieron leer los datos de la solicitud.",
  "KRIPTA.Chat.CardSpentFooter": "CARTA GASTADA",
  "KRIPTA.Chat.CardSpentTitle": "Carta gastada",
  "KRIPTA.Chat.FallbackPlayer": "jugador",
  "KRIPTA.Chat.ManualChoiceFooter": "ELECCIÓN MANUAL",
  "KRIPTA.Chat.ReferenceTitle": "Referencia",
  "KRIPTA.Chat.RequestManualTitle": "Solicitud de carta elegida",
  "KRIPTA.Chat.RequestRandomTitle": "Solicitud de carta aleatoria",
  "KRIPTA.Chat.ShowCardTitle": "Referencia de carta",
  "KRIPTA.Dialog.BindPlayer.Title": "Vincular jugador del servidor",
  "KRIPTA.Dialog.BindPlayer.Header": "Elegir un jugador para {foundryUserName}",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "usuario de Foundry",
  "KRIPTA.Dialog.Player.AddTitle": "Añadir jugador",
  "KRIPTA.Dialog.Player.EditTitle": "Editar jugador",
  "KRIPTA.Dialog.Player.DeleteTitle": "Eliminar jugador",
  "KRIPTA.Dialog.Player.DeleteWarning": "Eliminar al jugador \"{playerName}\" no se puede deshacer. Introduce {code} y confirma la eliminación.",
  "KRIPTA.Dialog.Count.TotalCards": "total de cartas de este tipo - {max}",
  "KRIPTA.Error.InvalidCardLevel": "Nivel no válido para {context}: {level}",
  "KRIPTA.Error.InvalidCardNumber": "Número no válido para {context}: {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "nivel de carta no válido: {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "número de carta no válido: {number}",
  "KRIPTA.Error.InvalidRequestCard": "Carta no válida para la solicitud",
  "KRIPTA.Error.InvalidGiveCard": "Carta no válida para entregar",
  "KRIPTA.Error.MissingRequestPlayerGuid": "No se pudo determinar playerGuid para entregar la carta.",
  "KRIPTA.Error.MissingSelectedCard": "No se pudo determinar la carta seleccionada.",
  "KRIPTA.Error.MissingSelectedCardForGive": "No se pudo determinar la carta seleccionada para entregar.",
  "KRIPTA.Error.MissingGivePlayer": "No se pudo determinar el jugador al que entregar la carta.",
  "KRIPTA.Error.MissingGiveCard": "No se pudo determinar la carta que se va a entregar.",
  "KRIPTA.Error.MissingServerUrl": "Falta la configuración de la ruta del servidor.",
  "KRIPTA.Error.InvalidReader": "El usuario técnico Reader está configurado incorrectamente.",
  "KRIPTA.Error.InvalidWriter": "El usuario técnico Writer está configurado incorrectamente.",
  "KRIPTA.Error.MenuUnavailable": "Esta función no está disponible. Comprueba la configuración del módulo. Los detalles están en la consola del navegador.",
  "KRIPTA.Error.Generic": "Se produjo un error",
  "KRIPTA.Error.Unknown": "error desconocido",
  "KRIPTA.Error.NameRequired": "api 400: El campo Name es obligatorio.",
  "KRIPTA.Error.RegistryDeleteReturned": "el servidor devolvió el jugador en el registro después de la eliminación.",
  "KRIPTA.Notification.CardGiven": "Carta entregada.",
  "KRIPTA.Notification.CardUsed": "Carta usada y gastada.",
  "KRIPTA.Notification.CardWrittenOff": "Carta retirada.",
  "KRIPTA.Notification.CannotUseMissingCard": "Esta carta ya no está registrada en el servidor. No se puede usar.",
  "KRIPTA.Notification.MissingCard": "Esta carta ya no está registrada en el servidor.",
  "KRIPTA.Notification.PlayerNotSelected": "No se ha seleccionado un jugador para entregar la carta",
  "KRIPTA.Notification.PlayerBindingMissing": "No se pudo determinar la vinculación del jugador para entregar la carta",
  "KRIPTA.Notification.RequestSent": "Solicitud de carta enviada al chat.",
  "KRIPTA.Notification.ServerSuccess": "Conexión correcta.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "Conexión correcta. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "No se pudo conectar con el servidor. Comprueba la dirección, la disponibilidad del servidor y la configuración CORS/HTTPS.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "No se pudo comprobar el servidor.",
  "KRIPTA.Notification.InvalidServerUrl": "Dirección del servidor no válida: {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "La sección de configuración de Kripta Cards solo está disponible para los roles Director de Juego y Asistente del Director de Juego.",
  "KRIPTA.Notification.ServerCheckFailed": "La comprobación del servidor falló",
  "KRIPTA.Notification.TechUserReader": "Reader",
  "KRIPTA.Notification.TechUserWriter": "Writer",
  "KRIPTA.Notification.TechUsersCheckSuccess": "Reader y Writer pasan la comprobación.",
  "KRIPTA.Notification.SettingsSaved": "Configuración de conexión guardada.",
  "KRIPTA.Notification.PlayerAdded": "Jugador añadido.",
  "KRIPTA.Notification.PlayerUpdated": "Jugador actualizado.",
  "KRIPTA.Notification.PlayerDeleted": "Jugador eliminado.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "Eliminación cancelada. El campo de confirmación se rellenó incorrectamente.",
  "KRIPTA.Notification.BindingSaved": "Vinculación guardada.",
  "KRIPTA.Notification.BindingDeleted": "Vinculación eliminada.",
  "KRIPTA.Notification.BadCatalogCardNumber": "La carta seleccionada tiene un número no válido. Comprueba la respuesta de getCardsList y normalizeCardsList.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "Esta carta no puede entregarse manualmente porque tiene un número no válido. Comprueba la respuesta de getCardsList y normalizeCardsList.",
  "KRIPTA.Notification.CardOutputFailed": "No se pudo publicar la carta en el chat",
  "KRIPTA.Notification.CardGiveFailed": "No se pudo entregar la carta",
  "KRIPTA.Notification.CardUseFailed": "No se pudo usar la carta",
  "KRIPTA.Notification.CardTakeFailed": "No se pudo retirar la carta",
  "KRIPTA.Notification.CardRequestFailed": "No se pudo enviar la solicitud de carta",
  "KRIPTA.Notification.CardRequestConfirmFailed": "No se pudo confirmar la entrega de la carta",
  "KRIPTA.Notification.PlayerAddFailed": "No se pudo añadir el jugador",
  "KRIPTA.Notification.PlayerUpdateFailed": "No se pudo actualizar el jugador",
  "KRIPTA.Notification.PlayerDeleteFailed": "No se pudo eliminar el jugador",
  "KRIPTA.Notification.CardRollFailed": "No se pudo recibir la carta.",
  "KRIPTA.Dialog.TakeCard.Title": "Retirar carta",
  "KRIPTA.Dialog.TakeCard.Message": "El jugador {playerName} perderá la carta {cardName}.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Entregar carta"
}
__END_LOCALE_JSON__
