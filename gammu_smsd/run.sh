#!/bin/bash

CONFIG_FILE="/etc/gammu-smsdrc"

# Load variables from HA (with defaults)
DEVICE="${DEVICE:-/dev/ttyUSB2}"
LOG_LEVEL="${LOG_LEVEL:-info}"
CHECK_INTERVAL="${CHECK_INTERVAL:-10}"
RECEIVE="${RECEIVE:-true}"

MQTT_HOST="${MQTT_HOST:-core-mosquitto}"
MQTT_PORT="${MQTT_PORT:-1883}"
MQTT_USER="${MQTT_USER:-smsd}"
MQTT_PASS="${MQTT_PASS}"

# --- FIX: fallback for missing topic ---
MQTT_OUTGOING_TOPIC="${MQTT_OUTGOING_TOPIC}"
if [ -z "$MQTT_OUTGOING_TOPIC" ]; then
  MQTT_OUTGOING_TOPIC="Ourplace/SMS/Outgoing"
  echo "Fallback: MQTT_OUTGOING_TOPIC was empty, using default."
fi

# Debug output
echo "MQTT_HOST='$MQTT_HOST'"
echo "MQTT_PORT='$MQTT_PORT'"
echo "MQTT_USER='$MQTT_USER'"
echo "MQTT_PASS='$MQTT_PASS'"
echo "MQTT_OUTGOING_TOPIC='$MQTT_OUTGOING_TOPIC'"

# Generate gammu-smsd config
cat <<EOF > $CONFIG_FILE
[gammu]
device = ${DEVICE}
connection = at

[smsd]
service = files
logfile = /data/smsd.log
logformat = ${LOG_LEVEL}
checksecurity = 0
receive = ${RECEIVE}
checkinterval = ${CHECK_INTERVAL}
phoneid = modem1
inboxpath = /data/inbox/
outboxpath = /data/outbox/
sentsmspath = /data/sent/
errorsmspath = /data/error/
EOF

# Create directories
mkdir -p /data/inbox /data/outbox /data/sent /data/error

echo "Using device: ${DEVICE}"
echo "MQTT: host=${MQTT_HOST} port=${MQTT_PORT} user=${MQTT_USER} topic=${MQTT_OUTGOING_TOPIC}"

# Start MQTT bridge
/usr/local/bin/mqtt_bridge.sh &

# Start SMSD
gammu-smsd -c $CONFIG_FILE

wait
