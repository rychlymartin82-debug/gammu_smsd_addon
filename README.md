# Gammu SMSD Add-on for Home Assistant

Tento add-on umožňuje přijímat SMS zprávy pomocí modemu přes Gammu a přeposílat je do MQTT.  
Je určen pro integraci s Home Assistantem nebo Node-RED.

---

## 📦 Funkce

- Přijímání SMS zpráv přes Gammu SMSD
- Automatické přeposílání do MQTT topicu
- Podpora více architektur (amd64, armv7, aarch64)
- Konfigurovatelný port modemu, interval, logování
- Volitelné mazání zpráv po přijetí

---

## 🔧 Požadavky

- Home Assistant s podporou vlastních add-on repozitářů
- MQTT broker (např. Mosquitto) s vytvořeným uživatelem
- USB modem kompatibilní s Gammu (např. Huawei E173)
- Správně nastavené zařízení `/dev/ttyUSB2` nebo `/dev/serial/by-id/...`

---

## 🚀 Instalace

1. Přidej repozitář do Home Assistantu:

