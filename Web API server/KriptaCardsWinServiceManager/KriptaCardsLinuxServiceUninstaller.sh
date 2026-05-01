#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="kripta-cards-service"
UNIT_PATH="/etc/systemd/system/${SERVICE_NAME}.service"

if [[ "$EUID" -ne 0 ]]; then
    echo "Запусти скрипт через sudo:"
    echo "sudo ./uninstall-kripta-cards-service.sh"
    exit 1
fi

echo "Удаление службы: ${SERVICE_NAME}"

if systemctl list-unit-files | grep -q "^${SERVICE_NAME}.service"; then
    echo "Останавливаем службу..."
    systemctl stop "${SERVICE_NAME}" || true

    echo "Отключаем автозапуск..."
    systemctl disable "${SERVICE_NAME}" || true
else
    echo "Служба ${SERVICE_NAME} не зарегистрирована в systemd."
fi

if [[ -f "$UNIT_PATH" ]]; then
    echo "Удаляем unit-файл: ${UNIT_PATH}"
    rm -f "$UNIT_PATH"
else
    echo "Unit-файл не найден: ${UNIT_PATH}"
fi

echo "Обновляем systemd..."
systemctl daemon-reload
systemctl reset-failed "${SERVICE_NAME}" || true

echo "Готово. Служба ${SERVICE_NAME} остановлена и удалена."