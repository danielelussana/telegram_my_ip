#!/bin/bash
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

#then:
#sudo chmod 644 /etc/systemd/system/telegram_my_ip.service
#sudo systemctl enable telegram_my_ip.service
#Alternative method to run at boot hero:
#https://www.dexterindustries.com/howto/auto-run-python-programs-on-the-raspberry-pi/

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

# Metodo 1: Filtra solo IPv4 da hostname -I
myip=$(hostname -I | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | head -1)

# Metodo 2 (alternativo): Usa ip route per ottenere l'IP della route di default
# myip=$(ip route get 8.8.8.8 | grep -oP 'src \K\S+')

# Metodo 3 (alternativo): Specifica un'interfaccia particolare (es. eth0 o wlan0)
# myip=$(ip addr show eth0 | grep -oP 'inet \K[\d.]+')
# myip=$(ip addr show wlan0 | grep -oP 'inet \K[\d.]+')

# Verifica che abbiamo ottenuto un IP valido
if [[ -z "$myip" ]]; then
    message="$(hostname) è avviato ma non è stato possibile determinare l'indirizzo IPv4"
else
    message="$(hostname) is running with IP address: $myip"
fi

curl -s -X POST "https://api.telegram.org/bot${telegram_bot_api}/sendMessage" \
     -d "chat_id=${telegram_chat}" \
     -d "text=${message}"
