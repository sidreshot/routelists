#!/bin/bash
# Скрипт для автоматического обновления списков IP-адресов

# Настройки
REPO_DIR="$HOME/routelists"
COMBINED_FILE="combined_ips.txt"
LOG_FILE="$REPO_DIR/update.log"
TEMP_FILE="/tmp/combined_ips_temp.txt"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Список URL для скачивания
declare -a URLS=(
    "https://antifilter.network/download/ip.lst"
    "https://antifilter.network/download/ipsmart.lst"
    "https://antifilter.network/download/ipsum.lst"
    "https://raw.githubusercontent.com/touhidurrr/iplist-youtube/main/cidr4.txt"
    "https://raw.githubusercontent.com/touhidurrr/iplist-youtube/main/lists/ipv4.txt"
)

# Функция для логирования
log() {
    echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}

# Начало процесса
log "=== НАЧАЛО ОБНОВЛЕНИЯ СПИСКОВ IP ==="

# Проверка зависимостей
if ! command -v curl &> /dev/null; then
    log "ERROR: curl не установлен. Выполните: sudo apt install curl"
    exit 1
fi

if ! command -v git &> /dev/null; then
    log "ERROR: git не установлен. Выполните: sudo apt install git"
    exit 1
fi

# Очистка временного файла
> "$TEMP_FILE"

# Генерация списка Google IP через bgpq3 (если установлен)
if command -v bgpq3 &> /dev/null; then
    log "Генерация списка Google IP через bgpq3..."
    if bgpq3 AS-GOOGLE 2>/dev/null | tail -n +2 | awk '{print $NF}' >> "$TEMP_FILE"; then
        log "✓ Список Google IP добавлен"
    else
        log "⚠️ Ошибка генерации списка Google IP (bgpq3)"
    fi
else
    log "⚠️ bgpq3 не установлен. Для установки: sudo apt install bgpq3"
fi

# Скачивание списков
for url in "${URLS[@]}"; do
    log "Скачивание списка: $url"
    if curl -sSf --max-time 15 --retry 2 "$url" >> "$TEMP_FILE" 2>/dev/null; then
        log "✓ Успешно скачано"
    else
        log "⚠️ Ошибка скачивания: $url"
    fi
done

# Обработка и очистка списка
log "Обработка и очистка списка..."
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}(\/[0-9]{1,2})?' "$TEMP_FILE" | sort -u > "$REPO_DIR/$COMBINED_FILE"

# Подсчет количества записей
COUNT=$(wc -l < "$REPO_DIR/$COMBINED_FILE")
log "Готово! Общее количество уникальных записей: $COUNT"

# Обновление репозитория
cd "$REPO_DIR" || exit
git pull origin main 2>/dev/null

# Проверка изменений
if ! git diff --quiet "$COMBINED_FILE"; then
    log "Обнаружены изменения. Создание коммита..."
    git add "$COMBINED_FILE"
    git commit -m "Автообновление списков IP: $COUNT записей [$(date +"%Y-%m-%d")]" || true
    if git push origin main; then
        log "✓ Изменения успешно отправлены на GitHub"
    else
        log "⚠️ Ошибка отправки изменений на GitHub"
    fi
else
    log "Нет изменений. Обновление не требуется."
fi

log "=== ЗАВЕРШЕНИЕ ОБНОВЛЕНИЯ СПИСКОВ IP ==="
echo "" >> "$LOG_FILE"
exit 0
