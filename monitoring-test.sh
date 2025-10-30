#!/bin/bash
# ===============================================
# Monitor process "test" and check HTTPS endpoint
# Intelligent logging: start, stop, restart, and URL failures
# Author: Filkin Boris
# Version: 2.1
# ===============================================

PROCESS_NAME="ptest"
URL="https://test.com/monitoring/test/api"
LOG_FILE="/var/log/monitoring.log"
PID_FILE="/tmp/${PROCESS_NAME}_pid"

# Проверка наличия файла логов
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE" 2>/dev/null || {
        echo "$(date '+%Y-%m-%d %H:%M:%S'): ERROR — cannot create $LOG_FILE" >&2
        exit 1
    }
    chmod 644 "$LOG_FILE"
fi

# Получаем текущий PID процесса
CURRENT_PID=$(pgrep -x "$PROCESS_NAME" | head -n 1)

# Если процесс найден
if [ -n "$CURRENT_PID" ]; then
    # Был ли запущен ранее?
    if [ -f "$PID_FILE" ]; then
        LAST_PID=$(cat "$PID_FILE")

        if [ "$CURRENT_PID" != "$LAST_PID" ]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S'): Process '$PROCESS_NAME' DEAD (PID: $LAST_PID)" >> "$LOG_FILE"
            echo "$(date '+%Y-%m-%d %H:%M:%S'): Process '$PROCESS_NAME' STARTED (PID: $CURRENT_PID)" >> "$LOG_FILE"
        fi
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S'): Process '$PROCESS_NAME' STARTED (PID: $CURRENT_PID)" >> "$LOG_FILE"
    fi

    # Сохраняем текущий PID
    echo "$CURRENT_PID" > "$PID_FILE"

    # Проверка доступности URL
    if ! curl -fs --max-time 10 "$URL" > /dev/null; then
        echo "$(date '+%Y-%m-%d %H:%M:%S'): ERROR — HTTPS endpoint '$URL' is unavailable!" >> "$LOG_FILE"
    fi

# Если процесс не найден
else
    # Если ранее PID был, значит процесс умер
    if [ -f "$PID_FILE" ]; then
        LAST_PID=$(cat "$PID_FILE")
        echo "$(date '+%Y-%m-%d %H:%M:%S'): Process '$PROCESS_NAME' DEAD (PID: $LAST_PID)" >> "$LOG_FILE"
        rm -f "$PID_FILE"
    fi
    exit 0
fi
