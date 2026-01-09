cat > run.sh << 'EOF'
#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
SMSD_CONFIG=/data/smsd.conf
SMSD_LOG=/data/smsd.log

# Read config
DEVICE=$(grep -Po '"device":\s*"\K[^"]+' $CONFIG_PATH)
MQTT_HOST=$(grep -Po '"mqtt_host":\s*"\K[^"]+' $CONFIG_PATH)
MQTT_PORT=$(grep -Po '"mqtt_port":\s*\K[0-9]+' $CONFIG_PATH)
MQTT_USER=$(grep -Po '"mqtt_user":\s*"\K[^"]+' $CONFIG_PATH)
MQTT_PASS=$(grep -Po '"mqtt_password":\s*"\K[^"]+' $CONFIG_PATH)
MQTT_TOPIC=$(grep -Po '"mqtt_topic":\s*"\K[^"]+' $CONFIG_PATH)

echo "=========================================="
echo "SMS GATEWAY DEBUG LOG"
echo "=========================================="
echo "Device: $DEVICE"
echo "MQTT: $MQTT_HOST:$MQTT_PORT (user: $MQTT_USER)"
echo "Topic: $MQTT_TOPIC"
echo "=========================================="

# Create config
cat > $SMSD_CONFIG << ENDCONF
[gammu]
device = $DEVICE
connection = at

[smsd]
service = files
logfile = $SMSD_LOG
debuglevel = 1
inboxpath = /data/inbox/
outboxpath = /data/outbox/
sentsmspath = /data/sent/
errorsmspath = /data/error/

RunOnReceive = /app/on_receive.sh

PhoneID = SMSGateway
User = $MQTT_USER
Password = $MQTT_PASS
Host = $MQTT_HOST:$MQTT_PORT
ClientID = smsd_gateway

[include_numbers]
number1 = *
ENDCONF

mkdir -p /data/{inbox,outbox,sent,error}

echo "Waiting for modem (10s)..."
sleep 10

echo "Testing modem connection..."
if ! gammu --config $SMSD_CONFIG identify 2>&1; then
    echo "ERROR: Modem test failed!"
    echo "Showing device info:"
    ls -la /dev/ttyUSB* || echo "No ttyUSB devices found!"
    exit 1
fi

echo "✓ Modem OK"
echo "Starting SMSD daemon..."
exec gammu-smsd --config $SMSD_CONFIG --pid /var/run/smsd.pid
EOF

chmod +x run.sh
