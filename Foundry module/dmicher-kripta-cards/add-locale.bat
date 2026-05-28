@echo off
setlocal
set "KRIPTA_MODULE_DIR=%~dp0"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference = 'Stop';" ^
  "$moduleDir = [IO.Path]::GetFullPath($env:KRIPTA_MODULE_DIR);" ^
  "$modulePath = Join-Path $moduleDir 'module.json';" ^
  "$packageDir = Join-Path $moduleDir 'add_custom_lang';" ^
  "$packageManifestPath = Join-Path $packageDir 'manifest.json';" ^
  "$packageLangPath = Join-Path $packageDir 'lang.json';" ^
  "$referenceLangPath = Join-Path $moduleDir 'lang\en.json';" ^
  "if (-not (Test-Path -LiteralPath $modulePath -PathType Leaf)) { throw 'module.json was not found next to add-locale.bat.' };" ^
  "if (-not (Test-Path -LiteralPath $packageManifestPath -PathType Leaf)) { throw 'add_custom_lang/manifest.json was not found.' };" ^
  "if (-not (Test-Path -LiteralPath $packageLangPath -PathType Leaf)) { throw 'add_custom_lang/lang.json was not found.' };" ^
  "if (-not (Test-Path -LiteralPath $referenceLangPath -PathType Leaf)) { throw 'The built-in lang/en.json reference file was not found.' };" ^
  "$entry = Get-Content -LiteralPath $packageManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json;" ^
  "$lang = [string]$entry.lang;" ^
  "$name = [string]$entry.name;" ^
  "if ($lang -notmatch '^[A-Za-z0-9]+(?:-[A-Za-z0-9]+)*$') { throw 'manifest.json: lang must be a safe locale identifier, for example fr or pt-BR.' };" ^
  "if ([string]::IsNullOrWhiteSpace($name)) { throw 'manifest.json: name is required.' };" ^
  "if (@('ru', 'en') -contains $lang.ToLowerInvariant()) { throw 'Built-in ru and en localizations cannot be overwritten.' };" ^
  "$expectedPath = 'lang/' + $lang + '.json';" ^
  "if ([string]$entry.path -ne $expectedPath) { throw ('manifest.json: path must be ' + $expectedPath + '.'); };" ^
  "$locale = Get-Content -LiteralPath $packageLangPath -Raw -Encoding UTF8 | ConvertFrom-Json;" ^
  "$referenceLocale = Get-Content -LiteralPath $referenceLangPath -Raw -Encoding UTF8 | ConvertFrom-Json;" ^
  "$localeKeys = @($locale.PSObject.Properties.Name);" ^
  "$missingKeys = @($referenceLocale.PSObject.Properties.Name | Where-Object { $localeKeys -notcontains $_ });" ^
  "if ($missingKeys.Count -gt 0) { throw ('lang.json is incomplete for this module version. Missing keys: ' + ($missingKeys -join ', ')); };" ^
  "$module = Get-Content -LiteralPath $modulePath -Raw -Encoding UTF8 | ConvertFrom-Json;" ^
  "if ($null -eq $module.languages) { $module | Add-Member -NotePropertyName languages -NotePropertyValue @(); };" ^
  "$languages = @($module.languages | Where-Object { ([string]$_.lang).ToLowerInvariant() -ne $lang.ToLowerInvariant() });" ^
  "$module.languages = @($languages + [PSCustomObject]@{ lang = $lang; name = $name; path = $expectedPath });" ^
  "$encoding = New-Object System.Text.UTF8Encoding -ArgumentList $false;" ^
  "$backupPath = Join-Path $moduleDir 'module.json.before-custom-locale.bak';" ^
  "if (-not (Test-Path -LiteralPath $backupPath)) { [IO.File]::Copy($modulePath, $backupPath, $false); };" ^
  "$langDir = Join-Path $moduleDir 'lang'; [IO.Directory]::CreateDirectory($langDir) | Out-Null;" ^
  "$targetLangPath = Join-Path $langDir ($lang + '.json');" ^
  "$langText = [IO.File]::ReadAllText($packageLangPath, [Text.Encoding]::UTF8).TrimEnd();" ^
  "$langTemp = $targetLangPath + '.tmp'; [IO.File]::WriteAllText($langTemp, $langText + [Environment]::NewLine, $encoding); Move-Item -LiteralPath $langTemp -Destination $targetLangPath -Force;" ^
  "$moduleTemp = $modulePath + '.tmp'; [IO.File]::WriteAllText($moduleTemp, ($module | ConvertTo-Json -Depth 100) + [Environment]::NewLine, $encoding); Move-Item -LiteralPath $moduleTemp -Destination $modulePath -Force;" ^
  "Write-Host ('Installed locale ' + $lang + '. Restart Foundry VTT and select this language.');"

if errorlevel 1 (
  echo Locale installation failed.
  exit /b 1
)

exit /b 0
