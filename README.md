# Telegram my IP: a Telegram IP Notifier

Bash script to send the IP address of a Raspberry Pi (or other Linux machine) via Telegram on system startup.

Useful for machines that connect via DHCP if you want to know their IP address without having to physically access the machine.

---

---

# Telegram my IP: notificatore di IP via telegram

Script bash per inviare l'indirizzo IP di un Raspberry Pi (o altra macchina Linux) tramite Telegram all'avvio del sistema.

Utile per macchine che si collegano in DHCP e di cui si vuole conoscere l'indirizzo IP senza dover accedere fisicamente alla macchina.

---

## Files / File

- `telegram_my_ip_v1.sh` - First version / Prima versione
- `telegram_my_ip.sh` - Improved version / Versione migliorata

## Version differences / Differenze tra le versioni

### Version 1 / Versione 1
```bash
myip=$(hostname -I | awk '{print $1}')
```
**Behavior**: Returns the first IP from the `hostname -I` list
**Comportamento**: Restituisce il primo IP nella lista di `hostname -I`

### Version 2 / Versione 2
```bash
myip=$(hostname -I | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | head -1)
```
**Behavior**: Specifically filters only IPv4 addresses using regex
**Comportamento**: Filtra specificamente solo gli indirizzi IPv4 usando una regex

**Miglioramenti della V2 / V2 improvements:**
- Check if IP was found / Controllo se l'IP è stato trovato
- Alternative methods commented / Metodi alternativi commentati
- Custom error message / Messaggio di errore personalizzato
- Handling IPv6-only scenarios / Gestione di scenari con solo IPv6

---

## Prerequisites / Prerequisiti

### System / Sistema
- **Linux** (testato su Raspbian, Debian e Ubuntu / tested on Raspbian, Debian and Ubuntu)
- **curl** installed / installato
- Active **internet connection** / **Connessione internet** attiva
- **Bash** shell available / disponibile

### Telegram Bot / Bot Telegram
- Telegram account / **Account Telegram**
- Bot token from @BotFather / **Bot Token** ottenuto da @BotFather
- Chat ID to receive messages / **Chat ID** dove ricevere i messaggi

### System permissions / Permessi sistema
- Permessi di **lettura rete** (per `hostname -I`, `ip`) / Network read permissions
- Accesso **systemd** per installazione automatica (opzionale) / systemd access for automatic installation (optional)

---

## Required Configuration / Configurazione necessaria

**IMPORTANTE / IMPORTANT**: Prima di usare lo script devi configurare / Before using the script you must configure:

### 1. Telegram Bot Token / Token del Bot Telegram
Modifica la variabile / Modify the variable:
```bash
telegram_bot_api="YOUR_BOT_TOKEN_HERE"
```
**Come ottenere il token / How to get the token:**
- Search @BotFather on Telegram / Cerca @BotFather su Telegram
- Invia `/newbot` e segui le istruzioni / Send `/newbot` and follow instructions
- Copy the provided token / Copia il token fornito

### 2. Chat ID / ID della Chat
Modifica la variabile / Modify the variable:
```bash
telegram_chat="YOUR_CHAT_ID_HERE"
```
**Come ottenere l'ID / How to get the ID:**
- **Chat private / Private chat**: il tuo ID utente / your user ID
- **Gruppi / Groups**: l'ID del gruppo (inizia con -) / group ID (starts with -)
- **Strumento / Tool**: usa @userinfobot per ottenere il tuo ID / use @userinfobot to get your ID

---

## Execution Methods / Metodi di esecuzione

### Method 1: Manual execution / Metodo 1: Esecuzione manuale
```bash
chmod +x telegram_my_ip_v2.sh
./telegram_my_ip_v2.sh
```

### notifly mode / Modalità notifly
Con `--notifly [CANALE]` lo script invia tramite [notifly](/opt/scripts/notifly) (credenziali in `bot_credentials.txt`) invece di usare `telegram_my_ip.conf`. Senza opzioni usa il bot nativo con il file `.conf` (vedi `telegram_my_ip.conf.example`).
With `--notifly [CHANNEL]` the script sends through notifly instead of using `telegram_my_ip.conf`.
```bash
./telegram_my_ip.sh --notifly telegram
```
Lo script risolve i link simbolici, quindi `telegram_my_ip.conf` viene cercato nella cartella reale dello script / symlinks are resolved, so the `.conf` is looked up in the script's real directory.

### Method 2: Automatic execution at startup (systemd) / Metodo 2: Esecuzione automatica all'avvio (systemd)

**Raccomandato per sistemi moderni / Recommended for modern systems**

#### Installation / Installazione

1. **Copia lo script / Copy the script:**
   ```bash
   sudo mkdir -p /opt/scripts
   sudo ln -s "$PWD/telegram_my_ip.sh" /usr/local/bin/telegram_my_ip
   sudo chmod +x telegram_my_ip.sh
   ```

2. **Crea il file di servizio / Create service file** `/etc/systemd/system/telegram_my_ip.service`:
   ```ini
   [Unit]
   Wants=network-online.target
   After=network-online.target

   [Service]
   Type=simple
   ExecStart=/usr/local/bin/telegram_my_ip --notifly telegram
   Restart=on-failure
   RestartSec=5

   [Install]
   WantedBy=multi-user.target
   ```

3. **Abilita e avvia il servizio / Enable and start service:**
   ```bash
   sudo chmod 644 /etc/systemd/system/telegram_my_ip.service
   sudo systemctl enable telegram_my_ip.service
   sudo systemctl start telegram_my_ip.service
   ```

#### systemd configuration explanation / Spiegazione configurazione systemd:
- `Wants=network-online.target`: Aspetta che la rete sia online / Waits for network to be online
- `After=network-online.target`: Esegue dopo l'attivazione della rete / Runs after network activation
- `Type=oneshot`: Esegue un comando e termina / Runs one command and exits
- `RemainAfterExit=yes`: Mantiene lo stato attivo / Keeps active state
- `WantedBy=multi-user.target`: Si avvia in modalità multi-utente / Starts in multi-user mode

### Method 3: Other alternative methods / Metodo 3: Altri metodi alternativi

**Riferimento / Reference**: https://www.dexterindustries.com/howto/auto-run-python-programs-on-the-raspberry-pi/

**Altri approcci possibili / Other possible approaches:**
- Aggiunta a `/etc/rc.local` / Adding to `/etc/rc.local`
- Cron job con `@reboot` / Cron job with `@reboot`
- Traditional init services / Servizi init tradizionali

Il metodo systemd è raccomandato perché gestisce meglio le dipendenze di rete.
The systemd method is recommended because it better handles network dependencies.

---

## Alternative methods to get IP / Metodi alternativi per ottenere l'IP

La versione 2 include metodi commentati / Version 2 includes commented methods:

### Method A: Default interface IP / Metodo A: IP dell'interfaccia di default
```bash
myip=$(ip route get 8.8.8.8 | grep -oP 'src \K\S+')
```

### Method B: Specific interface IP / Metodo B: IP di interfaccia specifica
```bash
# Ethernet
myip=$(ip addr show eth0 | grep -oP 'inet \K[\d.]+')
# WiFi  
myip=$(ip addr show wlan0 | grep -oP 'inet \K[\d.]+')
```

---

## Testing and debugging / Test e debugging

### Manual verification / Verifica manuale
```bash
# Test del comando IP
hostname -I | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | head -1

# Test dell'invio Telegram
curl -s -X POST "https://api.telegram.org/bot<TOKEN>/sendMessage" \
     -d "chat_id=<CHAT_ID>" \
     -d "text=Test message"
```

### systemd service verification / Verifica servizio systemd
```bash
# Stato del servizio
sudo systemctl status telegram_my_ip.service

# Log del servizio  
sudo journalctl -u telegram_my_ip.service
```

---

## License / Licenza

This project is released under GNU AFFERO GENERAL PUBLIC LICENSE V3 license. / Questo progetto è rilasciato sotto licenza GNU AFFERO GENERAL PUBLIC LICENSE, V3.

---

## Contributing / Contributi

Pull requests and issues are welcome! / Pull request e segnalazioni sono benvenute!
