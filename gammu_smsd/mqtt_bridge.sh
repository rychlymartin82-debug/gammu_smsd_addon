#!/bin/bash

MQTT_HOST="core-mosquitto"
MQTT_PORT="1883"
MQTT_USER="smsd"
MQTT_PASS="EmA605285285"
MQTT_OUTGOING_TOPIC="Ourplace/SMS/Outgoing"

echo "MQTT bridge starting..."
echo "HOST=$MQTT_HOST PORT=$MQTT_PORT USER=$MQTT_USER TOPIC=$MQTT_OUTGOING_TOPIC"

while [ ! -f /data/smsd.log ]; do
    echo "Waiting for /data/smsd.log..."
    sleep 1
done

tail -F /data/smsd.log | while read -r line; do
    if [ -n "$line" ]; then
        echo "Publishing SMS: $line"
        mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASS" -t "$MQTT_OUTGOING_TOPIC" -m "$line"
    fi
done
