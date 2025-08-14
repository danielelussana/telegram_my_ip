# Telegram my IP: notificatore di IP via telegram

Script bash per inviare l'indirizzo IP di un Raspberry Pi (o altra macchina Linux) tramite Telegram all'avvio del sistema.

Utile per macchine che si collegano in DHCP e di cui si vuole conoscere l'indirizzo IP senza dover accedere fisicamente alla macchina.

---

# Telegram my IP: a Telegram IP Notifier

Bash script to send the IP address of a Raspberry Pi (or other Linux machine) via Telegram on system startup.

Useful for machines that connect via DHCP if you want to know their IP address without having to physically access the machine.

---

## File / Files

- `telegram_my_ip_v1.sh` - Prima versione / First version
- `telegram_my_ip_v2.sh` - Versione migliorata / Improved version

## Differenze tra le versioni / Version differences

### Versione 1 / Version 1
```bash
myip=$(hostname -I | awk '{print $1}')
```
**Comportamento**: Restituisce il primo IP nella lista di `hostname -I`
**Behavior**: Returns the first IP from the `hostname -I` list

### Versione 2 / Version 2
```bash
myip=$(hostname -I | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | head -1)
```
**Comportamento**: Filtra specificamente solo gli indirizzi IPv4 usando una regex
**Behavior**: Specifically filters only IPv4 addresses using regex

**Miglioramenti della V2 / V2 improvements:**
- Controllo se l'IP è stato trovato / Check if IP was found
- Metodi alternativi commentati / Alternative methods commented
- Messaggio di errore personalizzato / Custom error message
- Gestione di scenari con solo IPv6 / Handling IPv6-only scenarios

---

## Prerequisiti / Prerequisites

### Sistema / System
- **Linux** (testato su Raspbian, Debian e Ubuntu / tested on Raspbian, Debian and Ubuntu)
- **curl** installato / installed
- **Connessione internet** attiva / Active **internet connection**
- **Bash** shell disponibile / available

### Bot Telegram / Telegram Bot
- **Account Telegram** / Telegram account
- **Bot Token** ottenuto da @BotFather / Bot token from @BotFather
- **Chat ID** dove ricevere i messaggi / Chat ID to receive messages

### Permessi sistema / System permissions
- Permessi di **lettura rete** (per `hostname -I`, `ip`) / Network read permissions
- Accesso **systemd** per installazione automatica (opzionale) / systemd access for automatic installation (optional)

---

## Configurazione necessaria / Required Configuration

**IMPORTANTE / IMPORTANT**: Prima di usare lo script devi configurare / Before using the script you must configure:

### 1. Token del Bot Telegram / Telegram Bot Token
Modifica la variabile / Modify the variable:
```bash
telegram_bot_api="YOUR_BOT_TOKEN_HERE"
```
**Come ottenere il token / How to get the token:**
- Cerca @BotFather su Telegram / Search @BotFather on Telegram
- Invia `/newbot` e segui le istruzioni / Send `/newbot` and follow instructions
- Copia il token fornito / Copy the provided token

### 2. ID della Chat / Chat ID
Modifica la variabile / Modify the variable:
```bash
telegram_chat="YOUR_CHAT_ID_HERE"
```
**Come ottenere l'ID / How to get the ID:**
- **Chat private / Private chat**: il tuo ID utente / your user ID
- **Gruppi / Groups**: l'ID del gruppo (inizia con -) / group ID (starts with -)
- **Strumento / Tool**: usa @userinfobot per ottenere il tuo ID / use @userinfobot to get your ID

---

## Metodi di esecuzione / Execution Methods

### Metodo 1: Esecuzione manuale / Manual execution
```bash
chmod +x telegram_my_ip_v2.sh
./telegram_my_ip_v2.sh
```

### Metodo 2: Esecuzione automatica all'avvio (systemd) / Automatic execution at startup (systemd)

**Raccomandato per sistemi moderni / Recommended for modern systems**

#### Installazione / Installation

1. **Copia lo script / Copy the script:**
   ```bash
   sudo mkdir -p /opt/scripts
   sudo cp telegram_my_ip_v2.sh /opt/scripts/telegram_my_ip.sh
   sudo chmod +x /opt/scripts/telegram_my_ip.sh
   ```

2. **Crea il file di servizio / Create service file** `/etc/systemd/system/telegram_my_ip.service`:
   ```ini
   [Unit]
   Wants=network-online.target
   After=network-online.target

   [Service]
   Type=oneshot
   RemainAfterExit=yes
   ExecStart=/opt/scripts/telegram_my_ip.sh

   [Install]
   WantedBy=multi-user.target
   ```

3. **Abilita e avvia il servizio / Enable and start service:**
   ```bash
   sudo chmod 644 /etc/systemd/system/telegram_my_ip.service
   sudo systemctl enable telegram_my_ip.service
   sudo systemctl start telegram_my_ip.service
   ```

#### Spiegazione configurazione systemd / systemd configuration explanation:
- `Wants=network-online.target`: Aspetta che la rete sia online / Waits for network to be online
- `After=network-online.target`: Esegue dopo l'attivazione della rete / Runs after network activation
- `Type=oneshot`: Esegue un comando e termina / Runs one command and exits
- `RemainAfterExit=yes`: Mantiene lo stato attivo / Keeps active state
- `WantedBy=multi-user.target`: Si avvia in modalità multi-utente / Starts in multi-user mode

### Metodo 3: Altri metodi alternativi / Other alternative methods

**Riferimento / Reference**: https://www.dexterindustries.com/howto/auto-run-python-programs-on-the-raspberry-pi/

**Altri approcci possibili / Other possible approaches:**
- Aggiunta a `/etc/rc.local` / Adding to `/etc/rc.local`
- Cron job con `@reboot` / Cron job with `@reboot`
- Servizi init tradizionali / Traditional init services

Il metodo systemd è raccomandato perché gestisce meglio le dipendenze di rete.
The systemd method is recommended because it better handles network dependencies.

---

## Metodi alternativi per ottenere l'IP / Alternative methods to get IP

La versione 2 include metodi commentati / Version 2 includes commented methods:

### Metodo A: IP dell'interfaccia di default / Default interface IP
```bash
myip=$(ip route get 8.8.8.8 | grep -oP 'src \K\S+')
```

### Metodo B: IP di interfaccia specifica / Specific interface IP
```bash
# Ethernet
myip=$(ip addr show eth0 | grep -oP 'inet \K[\d.]+')
# WiFi  
myip=$(ip addr show wlan0 | grep -oP 'inet \K[\d.]+')
```

---

## Test e debugging / Testing and debugging

### Verifica manuale / Manual verification
```bash
# Test del comando IP
hostname -I | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | head -1

# Test dell'invio Telegram
curl -s -X POST "https://api.telegram.org/bot<TOKEN>/sendMessage" \
     -d "chat_id=<CHAT_ID>" \
     -d "text=Test message"
```

### Verifica servizio systemd / systemd service verification
```bash
# Stato del servizio
sudo systemctl status telegram_my_ip.service

# Log del servizio  
sudo journalctl -u telegram_my_ip.service
```

---

## Licenza / License

Questo progetto è rilasciato sotto licenza libera. / This project is released under free license.

---

## Contributi / Contributing

Pull request e segnalazioni sono benvenute! / Pull requests and issues are welcome!
