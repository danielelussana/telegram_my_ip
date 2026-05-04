#!/bin/bash
set -u

#DLx
#[Unit]
#Wants=network-online.target
#After=network-online.target
#
#[Service]
#Type=oneshot
#RemainAfterExit=yes
#ExecStart=/opt/scripts/telegram_my_ip.sh
#
#[Install]
#WantedBy=multi-user.target

#VARIABLES
telegram_bot_api="YOUR_BOT_TOKEN_HERE"
telegram_chat="YOUR_CHAT_ID_HERE"

# Retry settings (seconds)
max_attempts=18
sleep_between_attempts=5

get_ipv4() {
    local ip

    # Metodo preferito: IP usato per la route di default
    ip=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($i=="src") {print $(i+1); exit}}')
    if [[ -n "${ip}" ]]; then
        echo "${ip}"
        return 0
    fi

    # Fallback: primo IPv4 non-loopback su interfacce UP
    ip=$(ip -o -4 addr show up scope global 2>/dev/null | awk '{split($4,a,"/"); print a[1]; exit}')
    if [[ -n "${ip}" ]]; then
        echo "${ip}"
        return 0
    fi

    # Ultimo fallback: parsing di hostname -I
    ip=$(hostname -I 2>/dev/null | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | head -1)
    if [[ -n "${ip}" ]]; then
        echo "${ip}"
        return 0
    fi

    return 1
}

myip=""
for ((attempt=1; attempt<=max_attempts; attempt++)); do
    if myip=$(get_ipv4); then
        break
    fi
    sleep "${sleep_between_attempts}"
done

if [[ -z "${myip}" ]]; then
    message="$(hostname) è avviato ma non è stato possibile determinare l'indirizzo IPv4 dopo $((max_attempts * sleep_between_attempts)) secondi"
else
    message="$(hostname) è avviato con indirizzo IP: ${myip}"
fi

curl -s -X POST "https://api.telegram.org/bot${telegram_bot_api}/sendMessage" \
     -d "chat_id=${telegram_chat}" \
     -d "text=${message}" >/dev/null
