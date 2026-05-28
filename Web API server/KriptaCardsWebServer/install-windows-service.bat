@echo off
chcp 65001 >nul
setlocal

set "SERVICE_NAME=dmicher-kripta-kards-tati"
set "DISPLAY_NAME=dmicher. Сервер Kripta Cards для Tati"
set "EXE_PATH=C:\www\KriptaCardsServices\run\Tati\ServerInstance\KriptaCardsWebServer.exe"
set "DESCRIPTION=dmicher. Сервер Web API модуля Карточки Крипты Foundry VTT. Автор dmicher abathur kubrow (c) 2026, Licensed under the Apache License 2.0."

echo dmicher abathur kubrow \ Установка службы Kripta Cards
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Запусти этот bat-файл от имени администратора.
    echo.
    pause
    exit /b 1
)

if not exist "%EXE_PATH%" (
    echo [ERROR] Не найден файл:
    echo %EXE_PATH%
    echo.
    pause
    exit /b 1
)

sc query "%SERVICE_NAME%" >nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] Служба уже установлена: %SERVICE_NAME%
    echo.
    sc query "%SERVICE_NAME%"
    echo.
    pause
    exit /b 0
)

echo [INFO] Устанавливаем службу: %SERVICE_NAME%
echo.

sc create "%SERVICE_NAME%" ^
    binPath= "\"%EXE_PATH%\"" ^
    DisplayName= "%DISPLAY_NAME%" ^
    start= auto

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Не удалось создать службу.
    echo.
    pause
    exit /b 1
)

sc description "%SERVICE_NAME%" "%DESCRIPTION%"

echo.
echo [INFO] Запускаем службу...
sc start "%SERVICE_NAME%"

if %errorlevel% neq 0 (
    echo.
    echo [WARN] Служба зарегистрирована, но не была запущена.
    echo Запусти приложение вручную из консоли и посмотри вывод с причиной ошибки:
    echo "%EXE_PATH%"
    echo.
    pause
    exit /b 2
)

echo.
echo [OK] Служба установлена и запущена: %SERVICE_NAME%
echo.

sc query "%SERVICE_NAME%"

echo.
pause
endlocal