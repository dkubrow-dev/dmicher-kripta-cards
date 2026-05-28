@echo off
setlocal

set "SERVICE_NAME=KriptaCardsWebServer"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference = 'Stop';" ^
  "$serviceName = $env:SERVICE_NAME;" ^
  "$principal = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent();" ^
  "if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw 'Run this file as Administrator.' };" ^
  "if ([string]::IsNullOrWhiteSpace($serviceName)) { throw 'SERVICE_NAME is empty.' };" ^
  "$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue;" ^
  "if (-not $service) { throw ('Service was not found: ' + $serviceName) };" ^
  "if ($service.Status -ne 'Stopped') { Stop-Service -Name $serviceName -Force -ErrorAction Stop; $service.WaitForStatus('Stopped', [TimeSpan]::FromSeconds(30)); };" ^
  "$result = sc.exe delete $serviceName;" ^
  "if ($LASTEXITCODE -ne 0) { throw ($result -join [Environment]::NewLine) };" ^
  "Write-Host ('Deleted Windows service: ' + $serviceName)"

if errorlevel 1 (
  echo.
  echo Failed to uninstall Windows service.
  exit /b 1
)

echo.
echo Windows service uninstalled successfully.
exit /b 0
