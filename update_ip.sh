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
    "https://antifilter.network/download/subnet.lst"
    "https://raw.githubusercontent.com/touhidurrr/iplist-youtube/main/lists/cidr4.txt"
    "https://antifilter.download/list/ipresolve.lst"
    "https://antifilter.network/downloads/custom.lst"
    "https://antifilter.network/download/ipsum.lst"
    "https://raw.githubusercontent.com/touhidurrr/iplist-youtube/main/lists/ipv4.txt"
    "https://raw.githubusercontent.com/1andrevich/Re-filter-lists/refs/heads/main/ipsum.lst"
    "https://gist.githubusercontent.com/iamwildtuna/7772b7c84a11bf6e1385f23096a73a15/raw/083f8002e6a1c9b45e923afe358bfce747bc1c54/gistfile2.txt"
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

# Генерация списка GoDaddy через bgpq3 (если установлен)
if command -v bgpq3 &> /dev/null; then
    log "Генерация списка GoDaddy IP через bgpq3..."
    if bgpq3 AS-GODADDY 2>/dev/null | tail -n +2 | awk '{print $NF}' >> "$TEMP_FILE"; then
        log "✓ Список GoDaddy IP добавлен"
    else
        log "⚠️ Ошибка генерации списка GoDaddy IP (bgpq3)"
    fi
else
    log "⚠️ bgpq3 не установлен. Для установки: sudo apt install bgpq3"
fi

# Генерация списка GoDaddy AS4007 через bgpq3 (если установлен)
if command -v bgpq3 &> /dev/null; then
    log "Генерация списка GoDaddy IP через bgpq3..."
    if bgpq3 AS4007 2>/dev/null | tail -n +2 | awk '{print $NF}' >> "$TEMP_FILE"; then
        log "✓ Список GoDaddy IP добавлен"
    else
        log "⚠️ Ошибка генерации списка GoDaddy IP (bgpq3)"
    fi
else
    log "⚠️ bgpq3 не установлен. Для установки: sudo apt install bgpq3"
fi

# Генерация списка GoDaddy AS400754 через bgpq3 (если установлен)
if command -v bgpq3 &> /dev/null; then
    log "Генерация списка GoDaddy IP через bgpq3..."
    if bgpq3 AS400754 2>/dev/null | tail -n +2 | awk '{print $NF}' >> "$TEMP_FILE"; then
        log "✓ Список GoDaddy IP добавлен"
    else
        log "⚠️ Ошибка генерации списка GoDaddy IP (bgpq3)"
    fi
else
    log "⚠️ bgpq3 не установлен. Для установки: sudo apt install bgpq3"
fi



# Генерация списка AMAZON через bgpq3 (если установлен)
if command -v bgpq3 &> /dev/null; then
    log "Генерация списка AMAZON IP через bgpq3..."
    if bgpq3 AS-AMAZON 2>/dev/null | tail -n +2 | awk '{print $NF}' >> "$TEMP_FILE"; then
        log "✓ Список AMAZON IP добавлен"
    else
        log "⚠️ Ошибка генерации списка AMAZON IP (bgpq3)"
    fi
else
    log "⚠️ bgpq3 не установлен. Для установки: sudo apt install bgpq3"
fi


# Генерация списка AS20940 AKAMAI через bgpq3 (если установлен)
if command -v bgpq3 &> /dev/null; then
    log "Генерация списка AS20940 AKAMAI IP через bgpq3..."
    if bgpq3 AS20940 2>/dev/null | tail -n +2 | awk '{print $NF}' >> "$TEMP_FILE"; then
        log "✓ Список AS20940 IP добавлен"
    else
        log "⚠️ Ошибка генерации списка AS20940 AKAMAI IP (bgpq3)"
    fi
else
    log "⚠️ bgpq3 не установлен. Для установки: sudo apt install bgpq3"
fi

# лига легенд
if command -v bgpq3 &> /dev/null; then
    log "Генерация списка лига легенд IP через bgpq3..."
    if bgpq3 AS6507 2>/dev/null | tail -n +2 | awk '{print $NF}' >> "$TEMP_FILE"; then
        log "✓ Список лига легенд IP добавлен"
    else
        log "⚠️ Ошибка генерации списка лига легенд IP (bgpq3)"
    fi
else
    log "⚠️ bgpq3 не установлен. Для установки: sudo apt install bgpq3"
fi


# Скачивание списков
for url in "${URLS[@]}"; do
    # Удаляем лишние пробелы из URL
    clean_url=$(echo "$url" | xargs)
    log "Скачивание списка: $clean_url"
    if curl -sSf --max-time 15 --retry 2 "$clean_url" >> "$TEMP_FILE" 2>/dev/null; then
        log "✓ Успешно скачано"
    else
        log "⚠️ Ошибка скачивания: $clean_url"
    fi
done

# Дополнительно! Роскомсвобода листы - список ip адресов
#curl -s https://reestr.rublacklist.net/api/v3/ips/ | tr -d '[]"' | tr ',' '\n' | sed 's/^[[:space:]]*//; /^[[:space:]]*$/d' >> "$TEMP_FILE"


# Обработка и очистка списка
log "Обработка и очистка списка..."
# 1. Извлекаем IP-адреса и сети
# 2. Нормализуем формат (удаляем лишние символы)
# 3. Удаляем дубликаты через sort -u

# Удалить все строки, содержащие 0.0.0.0
sed -i '/0\.0\.0\.0/d' "$TEMP_FILE"
# ipv6 del
sed -i '/:/d' "$TEMP_FILE"

grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}(\/[0-9]{1,2})?' "$TEMP_FILE" | \
    awk '{gsub(/[^0-9.\/]/, "", $0); print $0}' | \
    sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n | \
    uniq > "$REPO_DIR/$COMBINED_FILE"

# Подсчет количества записей
COUNT=$(wc -l < "$REPO_DIR/$COMBINED_FILE")
log "Готово! Общее количество уникальных записей: $COUNT"

log "=== ЗАВЕРШЕНИЕ ОБНОВЛЕНИЯ СПИСКОВ IP ==="
echo "" >> "$LOG_FILE"
exit 0
