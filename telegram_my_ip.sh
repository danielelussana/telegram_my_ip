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
#Alternative method to run at boot:
#https://www.dexterindustries.com/howto/auto-run-python-programs-on-the-raspberry-pi/

#VARIABLES

telegram_bot_api="YOUR_BOT_TOKEN_HERE"
telegram_chat="YOUR_CHAT_ID_HERE"
myip=$(hostname -I | awk '{print $1}')
message="$(hostname) is running with IP address: $myip"

curl -s -X POST "https://api.telegram.org/bot${telegram_bot_api}/sendMessage" \
     -d "chat_id=${telegram_chat}" \
     -d "text=${message}"


#myip=`echo $(hostname -I | sed 's| |%20|g')`
#message="$HOSTNAME completed reboot and has a new local IP address: $myip"

#curl "https://api.telegram.org/bot$telegram_bot_api/sendMessage?chat_id=$telegram_chat&text=$message"
