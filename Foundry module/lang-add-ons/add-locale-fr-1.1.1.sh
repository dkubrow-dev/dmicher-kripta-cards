#!/usr/bin/env sh
set -eu

if [ ! -f "dmicher-kripta-cards/module.json" ]; then
  echo "Run this script from the Foundry module workspace root, next to dmicher-kripta-cards/module.json." >&2
  exit 1
fi

SCRIPT_FILE="$0"
LOCALE_PATH="dmicher-kripta-cards/lang/fr.json"
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
  "lang": "fr",
  "name": "Français",
  "path": "lang/fr.json"
}
__END_MANIFEST_JSON__
__LOCALE_JSON__
{
  "KRIPTA.NoBinding": "Votre utilisateur Foundry n'est pas lié à un joueur du serveur dans le module Kripta Cards. Veuillez contacter le Meneur de Jeu.",
  "KRIPTA.GMOnly": "Cette action est réservée au Meneur de Jeu.",
  "KRIPTA.Settings.ServerUrl.Name": "Adresse du serveur",
  "KRIPTA.Settings.TechAuthUsers.Name": "Utilisateurs techniques",
  "KRIPTA.Settings.PlayerBindings.Name": "Liaisons entre utilisateurs Foundry et joueurs du serveur",
  "KRIPTA.Settings.UiPrefs.Name": "Paramètres locaux de l'interface",
  "KRIPTA.Settings.Menu.Name": "Kripta Cards",
  "KRIPTA.Settings.Menu.Label": "Paramètres du module",
  "KRIPTA.Settings.Menu.Hint": "Connexion à l'API et utilisateurs techniques.",
  "KRIPTA.Settings.Help.BeforeServerLink": "Si vous n'avez pas encore installé et configuré le serveur de contenu du module, suivez ",
  "KRIPTA.Settings.Help.ServerLink": "ce lien",
  "KRIPTA.Settings.Help.AfterServerLink": " pour le faire. Pour une configuration rapide, utilisez la ",
  "KRIPTA.Settings.Help.DocumentationLink": "documentation",
  "KRIPTA.Settings.Help.AfterDocumentationLink": ".",
  "KRIPTA.Window.Catalog": "Catalogue des cartes",
  "KRIPTA.Window.CardDetails": "Carte du catalogue",
  "KRIPTA.Window.GiveCard": "Donner une carte",
  "KRIPTA.Window.MyCards": "Cartes du joueur",
  "KRIPTA.Window.Players": "Gérer les joueurs",
  "KRIPTA.Window.Registry": "Registre des joueurs",
  "KRIPTA.Window.RequestCard": "Demander une carte",
  "KRIPTA.Window.Settings": "Kripta Cards - Paramètres",
  "KRIPTA.Window.UseCard": "Utiliser une carte",
  "KRIPTA.Menu.Title": "Kripta Cards",
  "KRIPTA.Menu.Catalog": "Catalogue des cartes",
  "KRIPTA.Menu.GetCard": "Demander une carte",
  "KRIPTA.Menu.MyCards": "Mes cartes",
  "KRIPTA.Menu.Players": "Gérer les joueurs",
  "KRIPTA.Label.Category": "Catégorie",
  "KRIPTA.Label.Mode": "Mode",
  "KRIPTA.Label.Card": "Carte",
  "KRIPTA.Label.Player": "Joueur",
  "KRIPTA.Label.Name": "Nom",
  "KRIPTA.Label.Comment": "Commentaire",
  "KRIPTA.Label.CardTypes": "Types de cartes",
  "KRIPTA.Label.Count": "Quantité",
  "KRIPTA.Label.ConfirmationCode": "Code de confirmation",
  "KRIPTA.Label.Id": "Id",
  "KRIPTA.Label.Key": "Clé",
  "KRIPTA.Label.ServerUrl": "URL du serveur",
  "KRIPTA.Label.Writer": "Writer",
  "KRIPTA.Label.Reader": "Reader",
  "KRIPTA.Label.Role": "Rôle",
  "KRIPTA.Label.Binding": "Liaison",
  "KRIPTA.Role.GM": "Meneur de Jeu",
  "KRIPTA.Role.Player": "Joueur",
  "KRIPTA.Status.InGame": "en jeu",
  "KRIPTA.Status.Offline": "hors ligne",
  "KRIPTA.Binding.CardsIssued": "cartes attribuées :",
  "KRIPTA.Binding.NoCards": "aucune carte",
  "KRIPTA.Binding.NotBound": "le joueur n'est pas lié, choisissez un joueur.",
  "KRIPTA.Binding.CardsCountHint": "Nombre de types de cartes attribuées, sans compter les doublons",
  "KRIPTA.Button.Add": "Ajouter",
  "KRIPTA.Button.Bind": "Lier",
  "KRIPTA.Button.Cancel": "Annuler",
  "KRIPTA.Button.Close": "Fermer",
  "KRIPTA.Button.Confirm": "Confirmer",
  "KRIPTA.Button.Delete": "Supprimer",
  "KRIPTA.Button.Edit": "Modifier",
  "KRIPTA.Button.Give": "Donner",
  "KRIPTA.Button.GiveCard": "Donner une carte",
  "KRIPTA.Button.Info": "Infos",
  "KRIPTA.Button.No": "Non",
  "KRIPTA.Button.Output": "Publier",
  "KRIPTA.Button.Refresh": "Actualiser",
  "KRIPTA.Button.Registry": "Registre des joueurs",
  "KRIPTA.Button.Request": "Demander",
  "KRIPTA.Button.RequestCard": "Demander",
  "KRIPTA.Button.SaveChanges": "Enregistrer les modifications",
  "KRIPTA.Button.Take": "Retirer",
  "KRIPTA.Button.TestAuth": "Tester les utilisateurs techniques",
  "KRIPTA.Button.TestServer": "Tester le serveur",
  "KRIPTA.Button.Unbind": "Délier",
  "KRIPTA.Button.Use": "Utiliser",
  "KRIPTA.Button.Yes": "Oui",
  "KRIPTA.Mode.Manual": "Choisir manuellement",
  "KRIPTA.Mode.Random": "Aléatoire",
  "KRIPTA.Mode.Show": "Montrer",
  "KRIPTA.Mode.Spend": "Dépenser",
  "KRIPTA.View.Table": "Tableau",
  "KRIPTA.View.Tiles": "Tuiles",
  "KRIPTA.Placeholder.Search": "Rechercher",
  "KRIPTA.Select.NotSelected": "-- non sélectionné --",
  "KRIPTA.Template.EmptyCatalog": "Aucune catégorie ni carte n'est enregistrée sur le serveur.",
  "KRIPTA.Template.MyCardsTitle": "Cartes du joueur : {playerName}",
  "KRIPTA.Template.UseCardMissing": "Cette carte n'est plus enregistrée sur le serveur.",
  "KRIPTA.Template.UseCardPrompt": "Cette carte sera utilisée :",
  "KRIPTA.Card.FallbackName": "Carte {number}",
  "KRIPTA.Card.FallbackAddress": "Carte {level}/{number}",
  "KRIPTA.Card.MissingDescription": "La carte {level}/{number} est absente du catalogue actuel du serveur.",
  "KRIPTA.Card.NotRegisteredDescription": "La carte {level}/{number} n'est plus enregistrée sur le serveur.",
  "KRIPTA.Level.FallbackName": "Niveau {level}",
  "KRIPTA.Level.MissingDescription": "Ce niveau existe dans l'inventaire du joueur mais manque dans le catalogue actuel du serveur.",
  "KRIPTA.Chat.BlobReadFailed": "Impossible de lire le blob",
  "KRIPTA.Chat.CardGivenTitle": "Carte donnée",
  "KRIPTA.Chat.CardReceiveSubtitle": "Le joueur {playerName} reçoit la carte {cardSubtitle}",
  "KRIPTA.Chat.CardRequestCanceled": "Demande de carte annulée.",
  "KRIPTA.Chat.CardRequestConfirmedTitle": "Demande de carte confirmée",
  "KRIPTA.Chat.CardRequestPayloadUnreadable": "Impossible de lire les données de la demande.",
  "KRIPTA.Chat.CardSpentFooter": "CARTE DÉPENSÉE",
  "KRIPTA.Chat.CardSpentTitle": "Carte dépensée",
  "KRIPTA.Chat.FallbackPlayer": "joueur",
  "KRIPTA.Chat.ManualChoiceFooter": "CHOIX MANUEL",
  "KRIPTA.Chat.ReferenceTitle": "Référence",
  "KRIPTA.Chat.RequestManualTitle": "Demande de carte choisie",
  "KRIPTA.Chat.RequestRandomTitle": "Demande de carte aléatoire",
  "KRIPTA.Chat.ShowCardTitle": "Référence de carte",
  "KRIPTA.Dialog.BindPlayer.Title": "Lier un joueur du serveur",
  "KRIPTA.Dialog.BindPlayer.Header": "Choisir un joueur pour {foundryUserName}",
  "KRIPTA.Dialog.BindPlayer.DefaultFoundryUser": "utilisateur Foundry",
  "KRIPTA.Dialog.Player.AddTitle": "Ajouter un joueur",
  "KRIPTA.Dialog.Player.EditTitle": "Modifier le joueur",
  "KRIPTA.Dialog.Player.DeleteTitle": "Supprimer le joueur",
  "KRIPTA.Dialog.Player.DeleteWarning": "La suppression du joueur \"{playerName}\" est irréversible. Saisissez {code} et confirmez la suppression.",
  "KRIPTA.Dialog.Count.TotalCards": "nombre total de cartes de ce type - {max}",
  "KRIPTA.Error.InvalidCardLevel": "Niveau invalide pour {context} : {level}",
  "KRIPTA.Error.InvalidCardNumber": "Numéro invalide pour {context} : {number}",
  "KRIPTA.Error.InvalidLocalCardLevel": "niveau de carte invalide : {level}",
  "KRIPTA.Error.InvalidLocalCardNumber": "numéro de carte invalide : {number}",
  "KRIPTA.Error.InvalidRequestCard": "Carte invalide pour la demande",
  "KRIPTA.Error.InvalidGiveCard": "Carte invalide à donner",
  "KRIPTA.Error.MissingRequestPlayerGuid": "Impossible de déterminer playerGuid pour donner la carte.",
  "KRIPTA.Error.MissingSelectedCard": "Impossible de déterminer la carte sélectionnée.",
  "KRIPTA.Error.MissingSelectedCardForGive": "Impossible de déterminer la carte sélectionnée à donner.",
  "KRIPTA.Error.MissingGivePlayer": "Impossible de déterminer le joueur à qui donner la carte.",
  "KRIPTA.Error.MissingGiveCard": "Impossible de déterminer la carte à donner.",
  "KRIPTA.Error.MissingServerUrl": "Le chemin du serveur n'est pas configuré.",
  "KRIPTA.Error.InvalidReader": "L'utilisateur technique Reader est mal configuré.",
  "KRIPTA.Error.InvalidWriter": "L'utilisateur technique Writer est mal configuré.",
  "KRIPTA.Error.MenuUnavailable": "Cette fonctionnalité est indisponible. Vérifiez les paramètres du module. Les détails se trouvent dans la console du navigateur.",
  "KRIPTA.Error.Generic": "Une erreur s'est produite",
  "KRIPTA.Error.Unknown": "erreur inconnue",
  "KRIPTA.Error.NameRequired": "api 400 : le champ Name est obligatoire.",
  "KRIPTA.Error.RegistryDeleteReturned": "le serveur a renvoyé le joueur dans le registre après la suppression.",
  "KRIPTA.Notification.CardGiven": "Carte donnée.",
  "KRIPTA.Notification.CardUsed": "Carte utilisée et dépensée.",
  "KRIPTA.Notification.CardWrittenOff": "Carte retirée.",
  "KRIPTA.Notification.CannotUseMissingCard": "Cette carte n'est plus enregistrée sur le serveur. Elle ne peut pas être utilisée.",
  "KRIPTA.Notification.MissingCard": "Cette carte n'est plus enregistrée sur le serveur.",
  "KRIPTA.Notification.PlayerNotSelected": "Aucun joueur sélectionné pour donner la carte",
  "KRIPTA.Notification.PlayerBindingMissing": "Impossible de déterminer la liaison du joueur pour donner la carte",
  "KRIPTA.Notification.RequestSent": "Demande de carte envoyée dans le chat.",
  "KRIPTA.Notification.ServerSuccess": "Connexion réussie.",
  "KRIPTA.Notification.ServerSuccessWithDetails": "Connexion réussie. {details}",
  "KRIPTA.Notification.ServerConnectionFailed": "Impossible de se connecter au serveur. Vérifiez l'adresse, la disponibilité du serveur et les paramètres CORS/HTTPS.",
  "KRIPTA.Notification.ServerCheckFailedFallback": "Impossible de tester le serveur.",
  "KRIPTA.Notification.InvalidServerUrl": "Adresse du serveur invalide : {url}",
  "KRIPTA.Notification.SettingsAccessDenied": "La section des paramètres Kripta Cards est réservée aux rôles Meneur de Jeu et Assistant du Meneur de Jeu.",
  "KRIPTA.Notification.ServerCheckFailed": "Le test du serveur a échoué",
  "KRIPTA.Notification.TechUserReader": "Reader",
  "KRIPTA.Notification.TechUserWriter": "Writer",
  "KRIPTA.Notification.TechUsersCheckSuccess": "Reader et Writer passent le test.",
  "KRIPTA.Notification.SettingsSaved": "Paramètres de connexion enregistrés.",
  "KRIPTA.Notification.PlayerAdded": "Joueur ajouté.",
  "KRIPTA.Notification.PlayerUpdated": "Joueur mis à jour.",
  "KRIPTA.Notification.PlayerDeleted": "Joueur supprimé.",
  "KRIPTA.Notification.DeleteCanceledBadCode": "Suppression annulée. Le champ de confirmation a été mal rempli.",
  "KRIPTA.Notification.BindingSaved": "Liaison enregistrée.",
  "KRIPTA.Notification.BindingDeleted": "Liaison supprimée.",
  "KRIPTA.Notification.BadCatalogCardNumber": "La carte sélectionnée possède un numéro invalide. Vérifiez la réponse de getCardsList et normalizeCardsList.",
  "KRIPTA.Notification.BadCatalogCardNumberForGive": "Cette carte ne peut pas être donnée manuellement car son numéro est invalide. Vérifiez la réponse de getCardsList et normalizeCardsList.",
  "KRIPTA.Notification.CardOutputFailed": "Impossible de publier la carte dans le chat",
  "KRIPTA.Notification.CardGiveFailed": "Impossible de donner la carte",
  "KRIPTA.Notification.CardUseFailed": "Impossible d'utiliser la carte",
  "KRIPTA.Notification.CardTakeFailed": "Impossible de retirer la carte",
  "KRIPTA.Notification.CardRequestFailed": "Impossible d'envoyer la demande de carte",
  "KRIPTA.Notification.CardRequestConfirmFailed": "Impossible de confirmer l'attribution de la carte",
  "KRIPTA.Notification.PlayerAddFailed": "Impossible d'ajouter le joueur",
  "KRIPTA.Notification.PlayerUpdateFailed": "Impossible de mettre à jour le joueur",
  "KRIPTA.Notification.PlayerDeleteFailed": "Impossible de supprimer le joueur",
  "KRIPTA.Notification.CardRollFailed": "Impossible de recevoir la carte.",
  "KRIPTA.Dialog.TakeCard.Title": "Retirer une carte",
  "KRIPTA.Dialog.TakeCard.Message": "Le joueur {playerName} perdra la carte {cardName}.",
  "KRIPTA.Dialog.ChooseBoundUser.Title": "Donner une carte"
}
__END_LOCALE_JSON__
