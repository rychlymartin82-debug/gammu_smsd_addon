FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    gammu \
    gammu-smsd \
    mosquitto-clients \
    jq \
    bash \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY run.sh /usr/local/bin/run.sh
COPY mqtt_bridge.sh /usr/local/bin/mqtt_bridge.sh

RUN chmod +x /usr/local/bin/run.sh && \
    chmod +x /usr/local/bin/mqtt_bridge.sh

CMD ["/usr/local/bin/run.sh"]

