#!/bin/bash

echo "Starting MQTT bridge..."

publish() {
    mosquitto_pub \
        -h "${MQTT_HOST}" \
        -p "${MQTT_PORT}" \
        -u "${MQTT_USER}" \
        -P "${MQTT_PASS}" \
        -t "${MQTT_OUTGOING_TOPIC}" \
        -m "$1" || echo "MQTT publish failed"
}

publish "SMSD started"

tail -F /data/smsd.log | while read line; do
    if echo "$line" | grep -q "Received SMS"; then
        publish "$line"
    fi
done

