#!/bin/bash

set -euo pipefail

# Load variables from config file in the same directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/telegram_my_ip.conf"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Config file not found: $CONFIG_FILE" >&2
    exit 1
fi

# shellcheck source=telegram_my_ip.conf
source "$CONFIG_FILE"

if [[ -z "$telegram_bot_api" || -z "$telegram_chat" ]]; then
    echo "Missing required variables in $CONFIG_FILE" >&2
    exit 1
fi

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
