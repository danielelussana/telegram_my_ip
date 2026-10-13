#!/bin/bash

set -euo pipefail

# Load variables from config file in the same directory
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/telegram_my_ip.conf"

# Notifly: script esterno con piu' canali di notifica (Telegram, ntfy,
# KDE Connect, CallMeBot, notify-send). Vedi /opt/scripts/notifly.
NOTIFLY_MODE=false
NOTIFLY_METHOD=""

usage() {
    cat <<EOF
Uso: $(basename "$0") [--notifly [CANALE]]

  --notifly [CANALE]
      Invia la notifica tramite notifly invece del bot Telegram nativo
      (${CONFIG_FILE}). Puoi indicare il canale (o piu' canali separati
      da virgola: telegram, ntfy, kdeconnect, callmebot, notify-send);
      se omesso usa il metodo di default configurato in notifly
      (bot_credentials.txt).
EOF
}

die() {
    echo "Errore: $*" >&2
    exit 1
}

find_notifly() {
    local candidate script_dir

    if candidate=$(command -v notifly 2>/dev/null); then
        printf '%s\n' "$candidate"
        return 0
    fi

    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    for candidate in \
        "/opt/scripts/notifly/notifly.py" \
        "${script_dir}/../notifly/notifly.py"
    do
        if [[ -x "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    return 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --notifly)
            NOTIFLY_MODE=true
            if [[ $# -ge 2 && "$2" != -* ]]; then
                NOTIFLY_METHOD="$2"
                shift
            fi
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            usage >&2
            die "opzione sconosciuta: $1"
            ;;
    esac
    shift
done

myip=$(hostname -I | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | head -1 || true)

if [[ -z "$myip" ]]; then
    message="$(hostname) è avviato ma non è stato possibile determinare l'indirizzo IPv4"
else
    message="$(hostname) is running with IP address: $myip"
fi

if [[ "$NOTIFLY_MODE" == true ]]; then
    notifly_bin="$(find_notifly)" || die "notifly non trovato (richiesto per --notifly)"

    notifly_args=("$notifly_bin" -o)
    if [[ -n "$NOTIFLY_METHOD" ]]; then
        notifly_args+=(-m "$NOTIFLY_METHOD")
    fi
    notifly_args+=("$message")

    "${notifly_args[@]}"
else
    [[ -f "$CONFIG_FILE" ]] || die "Config file not found: $CONFIG_FILE"

    # shellcheck source=telegram_my_ip.conf
    source "$CONFIG_FILE"

    if [[ -z "${telegram_bot_api:-}" || -z "${telegram_chat:-}" ]]; then
        die "Missing required variables in $CONFIG_FILE"
    fi

    curl --silent --show-error --fail \
         -X POST "https://api.telegram.org/bot${telegram_bot_api}/sendMessage" \
         -d "chat_id=${telegram_chat}" \
         -d "text=${message}"
fi
