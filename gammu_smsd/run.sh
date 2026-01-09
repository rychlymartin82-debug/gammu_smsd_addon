#!/bin/bash
set -e

echo "=========================================="
echo "🚀 GAMMU SMS GATEWAY STARTING"
echo "=========================================="

CONFIG_PATH=/data/options.json
SMSD_CONFIG=/data/smsd.conf
SMSD_LOG=/data/smsd.log

# Parse config
DEVICE=$(grep -Po '"device":\s*"\K[^"]+' $CONFIG_PATH)
MQTT_HOST=$(grep -Po '"mqtt_host":\s*"\K[^"]+' $CONFIG_PATH)
MQTT_PORT=$(grep -Po '"mqtt_port":\s*\K[0-9]+' $CONFIG_PATH)
MQTT_USER=$(grep -Po '"mqtt_user":\s*"\K[^"]+' $CONFIG_PATH)
MQTT_PASS=$(grep -Po '"mqtt_password":\s*"\K[^"]+' $CONFIG_PATH)
MQTT_TOPIC=$(grep -Po '"mqtt_topic":\s*"\K[^"]+' $CONFIG_PATH)

echo "📱 Device: $DEVICE"
echo "🌐 MQTT: $MQTT_HOST:$MQTT_PORT"
echo "👤 User: $MQTT_USER"
echo "📬 Topic: $MQTT_TOPIC"
echo "=========================================="

# Check device exists
if [ ! -e "$DEVICE" ]; then
    echo "❌ ERROR: Device $DEVICE not found!"
    echo "Available devices:"
    ls -la /dev/ttyUSB* 2>/dev/null || echo "No ttyUSB devices!"
    exit 1
fi

echo "✅ Device found: $DEVICE"

# Create SMSD config
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
ClientID = gammu_smsd

[include_numbers]
number1 = *
ENDCONF

# Create directories
mkdir -p /data/{inbox,outbox,sent,error}

echo "⏳ Waiting for modem to initialize (15s)..."
sleep 15

echo "🔍 Testing modem connection..."
if gammu --config $SMSD_CONFIG identify; then
    echo "✅ Modem connected successfully!"
else
    echo "❌ Modem test failed!"
    echo "Trying to get more info..."
    gammu --config $SMSD_CONFIG identify 2>&1 || true
    exit 1
fi

echo "=========================================="
echo "🚀 Starting SMSD daemon..."
echo "=========================================="

exec gammu-smsd --config $SMSD_CONFIG --pid /var/run/smsd.pid
