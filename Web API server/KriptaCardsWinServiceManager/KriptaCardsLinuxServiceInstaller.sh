#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="kripta-cards-service"
APP_DIR="$(cd "$(dirname "$0")" && pwd)"
RUN_USER="${SUDO_USER:-$USER}"

# Вариант 1: Linux self-contained publish: ./KriptaCardsWebServer
# Вариант 2: framework-dependent publish: dotnet KriptaCardsWebServer.dll
if [[ -x "$APP_DIR/KriptaCardsWebServer" ]]; then
    EXEC_START="$APP_DIR/KriptaCardsWebServer"
elif [[ -f "$APP_DIR/KriptaCardsWebServer.dll" ]]; then
    EXEC_START="/usr/bin/dotnet $APP_DIR/KriptaCardsWebServer.dll"
else
    echo "Ошибка: рядом со скриптом не найден KriptaCardsWebServer или KriptaCardsWebServer.dll"
    exit 1
fi

if [[ "$EUID" -ne 0 ]]; then
    echo "Запусти скрипт через sudo:"
    echo "sudo ./install-kripta-cards-service.sh"
    exit 1
fi

cat > "/etc/systemd/system/${SERVICE_NAME}.service" <<EOF
[Unit]
Description=Сервер Web API модуля Карточки Крипты Foundry VTT. Автор dmicher abathur kubrow (c) 2026, Licensed under the Apache License 2.0.
After=network.target

[Service]
Type=simple
User=${RUN_USER}
WorkingDirectory=${APP_DIR}
ExecStart=${EXEC_START}
Restart=on-failure
RestartSec=5
KillSignal=SIGINT
SyslogIdentifier=${SERVICE_NAME}
Environment=ASPNETCORE_ENVIRONMENT=Production

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable "${SERVICE_NAME}"
systemctl restart "${SERVICE_NAME}"

echo "Служба установлена и запущена: ${SERVICE_NAME}"
echo
systemctl --no-pager --full status "${SERVICE_NAME}"