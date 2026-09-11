#!/bin/bash

set -euo pipefail

# directory dove sono conservati i token
CONFIG_PATH="/etc/telegram-tokens"

# file di configurazione
CONFIG_FILE="${CONFIG_PATH}/config"

die() {
    echo "Errore: $*" >&2
    exit 1
}

check_secure_dir() {
    local dir="$1"
    local mode

    [[ -d "$dir" ]] || die "directory non trovata: $dir"
    [[ ! -L "$dir" ]] || die "la directory non deve essere un symlink: $dir"

    mode=$(stat -c '%a' "$dir") || die "impossibile leggere i permessi di $dir"

    case "$mode" in
        700|500) ;;
        *) die "permessi non sicuri su $dir: $mode (richiesti 700 o 500)" ;;
    esac
}

check_secure_file() {
    local file="$1"
    local mode

    [[ -f "$file" ]] || die "file di configurazione non trovato: $file"
    [[ ! -L "$file" ]] || die "il file non deve essere un symlink"

    mode=$(stat -c '%a' "$file") || die "impossibile leggere i permessi"

    case "$mode" in
        600|400) ;;
        *) die "permessi non sicuri su $file: $mode (richiesti 600 o 400)" ;;
    esac
}

read_config_value() {
    local key="$1"
    local file="$2"

    awk -F= -v search_key="$key" '
        /^[[:space:]]*#/ { next }
        /^[[:space:]]*$/ { next }
        $1 == search_key {
            sub(/^[^=]+= */, "", $0)
            print
            found=1
            exit
        }
        END {
            if (!found) exit 1
        }
    ' "$file"
}

check_secure_dir "$CONFIG_PATH"
check_secure_file "$CONFIG_FILE"

telegram_bot_api="$(read_config_value "telegram_bot_api" "$CONFIG_FILE")" \
    || die "telegram_bot_api mancante"

telegram_chat="$(read_config_value "telegram_chat" "$CONFIG_FILE")" \
    || die "telegram_chat mancante"

myip=$(hostname -I | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | head -1 || true)

if [[ -z "$myip" ]]; then
    message="$(hostname) è avviato ma non è stato possibile determinare l'indirizzo IPv4"
else
    message="$(hostname) is running with IP address: $myip"
fi

curl --silent --show-error --fail \
     -X POST "https://api.telegram.org/bot${telegram_bot_api}/sendMessage" \
     -d "chat_id=${telegram_chat}" \
     -d "text=${message}"
