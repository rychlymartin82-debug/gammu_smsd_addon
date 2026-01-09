FROM alpine:3.20

# Základní nástroje + Gammu + MQTT klient
RUN apk add --no-cache \
    bash jq coreutils \
    gammu gammu-smsd \
    mosquitto-clients

# Startovací skript
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Výchozí gammurc (run.sh si vygeneruje vlastní podle options)
COPY gammurc /etc/gammurc

CMD ["/run.sh"]


