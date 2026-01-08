#!/bin/bash
set -euo pipefail

OPTIONS_FILE="/data/options.json"

# Načtení voleb z options.json
DEVICE=$(jq -r '.device // "/dev/ttyUSB0"' "$OPTIONS_FILE")
PIN=$(jq -r '.pin // ""' "$OPTIONS_FILE")
SMSC=$(jq -r '.smsc // ""' "$OPTIONS_FILE")
LOG_LEVEL=$(jq -r '.log_level // "info"' "$OPTIONS_FILE")
CHECK_INTERVAL=$(jq -r '.check_interval // 10' "$OPTIONS_FILE")
RECEIVE=$(jq -r '.receive // true' "$OPTIONS_FILE")
DELETE_AFTER_RECV=$(jq -r '.delete_after_recv // false' "$OPTIONS_FILE")

echo "Gammu SMSD starting..."
echo "Device: $DEVICE, PIN: ${PIN:+(set)}, SMSC: ${SMSC:-(auto)}, Log: $LOG_LEVEL, Interval: $CHECK_INTERVAL s"

# Vytvoření /etc/gammurc
cat > /etc/gammurc <<EOF
[gammu]
device = ${DEVICE}
connection = at
# Některé Huawei modemy potřebují specifický port (obvykle ttyUSB0 pro AT)
# Pokud máš ModemManager/mbim, zkontroluj který port dává AT odpovědi (AT, ATI).

# PIN (pokud používáš)
# Pozn.: Gammu PIN lze ovládat i přes smsdrc (init)
EOF

# Vytvoření /etc/gammu-smsdrc
cat > /etc/gammu-smsdrc <<EOF
# Gammu SMSD config
# Dokumentace: https://wammu.eu/docs/manual/smsd/

# Které zařízení obsluhovat
[gammu]
device = ${DEVICE}
connection = at

[smsd]
service = files
logfile = /data/smsd.log
debuglevel = ${LOG_LEVEL}
# kam ukládat přijaté zprávy
inboxpath = /data/inbox
outboxpath = /data/outbox
sentpath = /data/sent
errorpath = /data/error

# Interval kontroly outboxu
checkinterval = ${CHECK_INTERVAL}

# SMSC – pokud prázdné, použije se nastavení z karty/SIM
${SMSC:+smsc = ${SMSC}}

# Inicializační příkazy (volitelně PIN)
${PIN:+init = AT+CPIN=${PIN}}

# Příjem zpráv
receive = ${RECEIVE}

# Smazání po přijetí (opatrně)
deleteafterreceive = ${DELETE_AFTER_RECV}
EOF

# Připravíme adresáře pro data
mkdir -p /data/inbox /data/outbox /data/sent /data/error
touch /data/smsd.log

# Spuštění Gammu SMSD v popředí (Supervisor to vyžaduje)
exec gammu-smsd --config /etc/gammu-smsdrc --pid /var/run/gammu-smsd.pid --daemon never
