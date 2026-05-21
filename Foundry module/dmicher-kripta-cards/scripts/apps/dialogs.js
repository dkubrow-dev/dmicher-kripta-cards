import { escapeHtml } from "../helpers/utils.js";
import { format, localize } from "../helpers/lang.js";

const { DialogV2 } = foundry.applications.api;

async function waitDialog(config, fallback = null) {
  try {
    return await DialogV2.wait({
      rejectClose: false,
      modal: true,
      ...config
    });
  } catch (_error) {
    return fallback;
  }
}

export async function chooseServerPlayerDialog(players, currentGuid = "", foundryUserName = "") {
  const normalizedCurrentGuid = String(currentGuid ?? "").trim();
  const hasCurrentSelection = !!normalizedCurrentGuid && players.some((player) => String(player.guid ?? "").trim() === normalizedCurrentGuid);
  const escapedFoundryUserName = escapeHtml(foundryUserName || localize("Dialog.BindPlayer.DefaultFoundryUser"));

  const options = players.map((player) => {
    const playerGuid = String(player.guid ?? "").trim();
    const isChecked = hasCurrentSelection && playerGuid === normalizedCurrentGuid;

    return `
      <label
        style="
          display: flex;
          align-items: flex-start;
          gap: 10px;
          width: 100%;
          max-width: 100%;
          box-sizing: border-box;
          padding: 10px 12px;
          border: 1px solid rgba(255,255,255,0.12);
          border-radius: 6px;
          cursor: pointer;
        "
      >
        <input
          type="radio"
          name="guid"
          value="${escapeHtml(playerGuid)}"
          ${isChecked ? "checked" : ""}
          style="display: inline-block; width: 16px; height: 16px; margin-top: 4px; flex: 0 0 auto;"
        >
        <span
          style="
            display: block;
            flex: 1 1 auto;
            min-width: 0;
            max-width: 100%;
          "
        >
          <span
            style="
              display: block;
              font-weight: 700;
              color: #f5f5f5;
              line-height: 1.35;
              white-space: normal;
              overflow-wrap: anywhere;
              word-break: break-word;
            "
          >${escapeHtml(player.name)}</span>
          <span
            style="
              display: block;
              margin-top: 4px;
              font-size: 12px;
              line-height: 1.35;
              color: rgba(255,255,255,0.68);
              white-space: normal;
              overflow-wrap: anywhere;
              word-break: break-word;
            "
          >${escapeHtml(player.comment ?? "")}</span>
        </span>
      </label>
    `;
  }).join("");

  return waitDialog({
    window: {
      title: localize("Dialog.BindPlayer.Title")
    },
    content: `
      <form
        class="kripta-inline-form"
        style="
          width: 760px;
          min-width: 760px;
          max-width: 760px;
          box-sizing: border-box;
        "
      >
        <h4>${format("Dialog.BindPlayer.Header", { foundryUserName: escapedFoundryUserName })}</h4>
        <div class="form-group">
          <div
            style="
              width: 100%;
              max-width: 100%;
              max-height: 360px;
              overflow-y: auto;
              overflow-x: hidden;
              box-sizing: border-box;
            "
          >
            <div
              style="
                display: flex;
                flex-direction: column;
                gap: 8px;
                width: 100%;
                max-width: 100%;
                box-sizing: border-box;
              "
            >
              ${options}
            </div>
          </div>
        </div>
      </form>
    `,
    buttons: [
      {
        action: "confirm",
        label: localize("Button.Bind"),
        default: true,
        callback: (_event, button) =>
          button.form?.querySelector('input[name="guid"]:checked')?.value || null
      },
      {
        action: "cancel",
        label: localize("Button.Cancel"),
        callback: () => null
      }
    ]
  }, null);
}

export async function addEditPlayerDialog(player = null) {
  return waitDialog({
    window: {
      title: player ? localize("Dialog.Player.EditTitle") : localize("Dialog.Player.AddTitle")
    },
    content: `
      <div style="width: 760px; min-width: 760px; max-width: 760px; box-sizing: border-box;">
        <form
          class="kripta-inline-form"
          onsubmit="return false;"
          style="
            width: 760px;
            min-width: 760px;
            max-width: 760px;
            box-sizing: border-box;
          "
        >
          <div
            class="form-group"
            style="
              display: block;
              width: 100%;
              margin: 0 0 14px 0;
            "
          >
            <label
              style="
                display: block;
                width: 100%;
                margin: 0 0 8px 0;
              "
            >${localize("Label.Name")}</label>

            <input
              type="text"
              name="name"
              value="${escapeHtml(player?.name ?? "")}"
              maxlength="250"
              style="
                display: block;
                width: 100%;
                min-width: 100%;
                max-width: 100%;
                box-sizing: border-box;
              "
            >
          </div>

          <div
            class="form-group"
            style="
              display: block;
              width: 100%;
              margin: 0;
            "
          >
            <label
              style="
                display: block;
                width: 100%;
                margin: 0 0 8px 0;
              "
            >${localize("Label.Comment")}</label>

            <textarea
              name="comment"
              rows="6"
              maxlength="10000"
              style="
                display: block;
                width: 100%;
                min-width: 100%;
                max-width: 100%;
                min-height: 140px;
                resize: vertical;
                box-sizing: border-box;
              "
            >${escapeHtml(player?.comment ?? "")}</textarea>
          </div>
        </form>
      </div>
    `,
    buttons: [
      {
        action: "confirm",
        label: player ? localize("Button.Edit") : localize("Button.Add"),
        default: true,
        callback: (_event, button) => ({
          action: "confirm",
          name: String(button.form?.elements?.name?.value ?? "").trim(),
          comment: String(button.form?.elements?.comment?.value ?? "").trim()
        })
      },
      {
        action: "cancel",
        label: localize("Button.Cancel"),
        callback: () => ({ action: "cancel" })
      }
    ]
  }, { action: "cancel" });
}

export async function deletePlayerDialog(player) {
  const code = String(Math.floor(Math.random() * 100));

  return waitDialog({
    window: {
      title: localize("Dialog.Player.DeleteTitle")
    },
    content: `
      <div style="width: 760px; min-width: 760px; max-width: 760px; box-sizing: border-box;">
        <div class="kripta-danger-note" style="margin-bottom: 12px;">
          ${format("Dialog.Player.DeleteWarning", {
            playerName: escapeHtml(player?.name ?? ""),
            code: escapeHtml(code)
          })}
        </div>

        <form
          class="kripta-inline-form"
          style="
            width: 760px;
            min-width: 760px;
            max-width: 760px;
            box-sizing: border-box;
          "
        >
          <div
            class="form-group"
            style="
              display: block;
              width: 100%;
              margin: 0;
            "
          >
            <label
              style="
                display: block;
                width: 100%;
                margin: 0 0 8px 0;
              "
            >${localize("Label.ConfirmationCode")}</label>

            <input
              type="text"
              name="code"
              value=""
              style="
                display: block;
                width: 100%;
                min-width: 100%;
                max-width: 100%;
                box-sizing: border-box;
              "
            >
          </div>
        </form>
      </div>
    `,
    buttons: [
      {
        action: "confirm",
        label: localize("Button.Delete"),
        default: true,
        callback: (_event, button) => {
          const entered = String(button.form?.elements?.code?.value ?? "").trim();
          return entered === code
            ? { action: "confirm", valid: true }
            : { action: "confirm", valid: false };
        }
      },
      {
        action: "cancel",
        label: localize("Button.Cancel"),
        callback: () => ({ action: "cancel", valid: false })
      }
    ]
  }, { action: "cancel", valid: false });
}

export async function countPromptDialog({ title, message, max = 1, defaultValue = 1 }) {
  const safeMax = Math.max(1, Number(max) || 1);
  const safeDefault = Math.max(1, Math.min(safeMax, Number(defaultValue) || 1));

  const result = await waitDialog({
    window: {
      title
    },
    content: `
      <div class="kripta-danger-note">${message}</div>
      <form class="kripta-inline-form">
        <div class="form-group">
          <label>${localize("Label.Count")}</label>
          <input type="number" name="count" min="1" max="${safeMax}" value="${safeDefault}">
        </div>
        <div class="notes">${format("Dialog.Count.TotalCards", { max: safeMax })}</div>
      </form>
    `,
    buttons: [
      {
        action: "confirm",
        label: localize("Button.Confirm"),
        default: true,
        callback: (_event, button) => {
          const rawValue = Number(button.form?.elements?.count?.value || safeDefault);
          return {
            action: "confirm",
            count: Math.max(1, Math.min(safeMax, rawValue))
          };
        }
      },
      {
        action: "cancel",
        label: localize("Button.Cancel"),
        callback: () => ({
          action: "cancel",
          count: null
        })
      }
    ]
  }, { action: "cancel", count: null });

  if (result?.action !== "confirm") return null;
  return result.count;
}

export async function chooseBoundUserDialog(users) {
  const options = [`<option value="">${localize("Select.NotSelected")}</option>`].concat(
    users.map((item) => `
      <option value="${escapeHtml(item.foundryUserId)}">${escapeHtml(item.foundryUserName)}</option>
    `)
  ).join("");

  return waitDialog({
    window: {
      title: localize("Dialog.ChooseBoundUser.Title")
    },
    content: `
      <form class="kripta-inline-form">
        <div class="form-group">
          <label>${localize("Label.Player")}</label>
          <select name="foundryUserId">${options}</select>
        </div>
      </form>
    `,
    buttons: [
      {
        action: "confirm",
        label: localize("Button.Give"),
        default: true,
        callback: (_event, button) => ({
          action: "confirm",
          foundryUserId: String(button.form?.elements?.foundryUserId?.value || "")
        })
      },
      {
        action: "cancel",
        label: localize("Button.Cancel"),
        callback: () => ({
          action: "cancel",
          foundryUserId: null
        })
      }
    ]
  }, {
    action: "cancel",
    foundryUserId: null
  });
}
