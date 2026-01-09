#!/bin/bash

CONFIG_FILE="/etc/gammu-smsdrc"
DEVICE="${DEVICE:-/dev/ttyUSB2}"

logger -t gammu_smsd "Starting SMSD addon with device: $DEVICE"

# Wait for modem to appear
while [ ! -e "$DEVICE" ]; do
    echo "Waiting for modem $DEVICE..."
    logger -t gammu_smsd "Waiting for modem $DEVICE..."
    sleep 1
done

logger -t gammu_smsd "Modem detected: $DEVICE"

# Generate SMSD config
cat <<EOF > "$CONFIG_FILE"
[gammu]
device = ${DEVICE}
connection = at

[smsd]
service = files
logfile = /data/smsd.log
logformat = text
EOF

mkdir -p /data

echo "Using device: ${DEVICE}"
logger -t gammu_smsd "Using device: ${DEVICE}"

# Start MQTT bridge
/usr/local/bin/mqtt_bridge.sh &
logger -t gammu_smsd "MQTT bridge started"

# Start SMSD
gammu-smsd -c "$CONFIG_FILE"
STATUS=$?

if [ $STATUS -ne 0 ]; then
    echo "gammu-smsd failed with exit code $STATUS"
    logger -t gammu_smsd "gammu-smsd failed with exit code $STATUS"
fi

wait

