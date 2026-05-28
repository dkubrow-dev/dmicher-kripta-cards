#!/usr/bin/env sh
set -eu

MODULE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN=$(command -v python3)
elif command -v python >/dev/null 2>&1; then
  PYTHON_BIN=$(command -v python)
else
  echo "Python 3 is required to install a custom localization on Linux." >&2
  exit 1
fi

"$PYTHON_BIN" - "$MODULE_DIR" <<'PY'
import json
import os
import re
import shutil
import sys
import tempfile

module_dir = os.path.abspath(sys.argv[1])
module_path = os.path.join(module_dir, "module.json")
package_dir = os.path.join(module_dir, "add_custom_lang")
package_manifest_path = os.path.join(package_dir, "manifest.json")
package_lang_path = os.path.join(package_dir, "lang.json")
reference_lang_path = os.path.join(module_dir, "lang", "en.json")

for required in (module_path, package_manifest_path, package_lang_path, reference_lang_path):
    if not os.path.isfile(required):
        raise SystemExit(f"Required file was not found: {required}")

with open(package_manifest_path, "r", encoding="utf-8-sig") as file:
    entry = json.load(file)

if not isinstance(entry, dict):
    raise SystemExit("manifest.json must contain one localization manifest object.")

lang = str(entry.get("lang", ""))
name = str(entry.get("name", ""))
if not re.fullmatch(r"[A-Za-z0-9]+(?:-[A-Za-z0-9]+)*", lang):
    raise SystemExit("manifest.json: lang must be a safe locale identifier, for example fr or pt-BR.")
if not name.strip():
    raise SystemExit("manifest.json: name is required.")
if lang.lower() in {"ru", "en"}:
    raise SystemExit("Built-in ru and en localizations cannot be overwritten.")

expected_path = f"lang/{lang}.json"
if entry.get("path") != expected_path:
    raise SystemExit(f"manifest.json: path must be {expected_path}.")

with open(package_lang_path, "r", encoding="utf-8-sig") as file:
    locale_data = json.load(file)
if not isinstance(locale_data, dict):
    raise SystemExit("lang.json must contain a JSON object of localization strings.")

with open(reference_lang_path, "r", encoding="utf-8-sig") as file:
    reference_locale_data = json.load(file)
missing_keys = [key for key in reference_locale_data if key not in locale_data]
if missing_keys:
    raise SystemExit(
        "lang.json is incomplete for this module version. Missing keys: "
        + ", ".join(missing_keys)
    )

with open(module_path, "r", encoding="utf-8-sig") as file:
    module = json.load(file)
languages = module.get("languages")
if not isinstance(languages, list):
    raise SystemExit("module.json: languages must be an array.")

module["languages"] = [
    item for item in languages
    if not isinstance(item, dict) or str(item.get("lang", "")).lower() != lang.lower()
]
module["languages"].append({"lang": lang, "name": name, "path": expected_path})

backup_path = os.path.join(module_dir, "module.json.before-custom-locale.bak")
if not os.path.exists(backup_path):
    shutil.copy2(module_path, backup_path)

target_lang_dir = os.path.join(module_dir, "lang")
os.makedirs(target_lang_dir, exist_ok=True)
target_lang_path = os.path.join(target_lang_dir, f"{lang}.json")

with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=target_lang_dir, delete=False) as file:
    json.dump(locale_data, file, ensure_ascii=False, indent=2)
    file.write("\n")
    lang_temp_path = file.name
os.replace(lang_temp_path, target_lang_path)

with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=module_dir, delete=False) as file:
    json.dump(module, file, ensure_ascii=False, indent=2)
    file.write("\n")
    module_temp_path = file.name
os.replace(module_temp_path, module_path)

print(f"Installed locale {lang}. Restart Foundry VTT and select this language.")
PY
