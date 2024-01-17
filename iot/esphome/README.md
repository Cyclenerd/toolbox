# ESPhome

Website: <https://esphome.io/>

## Firmware

Prerequisites:

```bash
brew install esphome
```

If you want to see how ESPHome interprets your configuration:

```bash
esphome config nils.yaml
```

To view the logs from your node without uploading:

```bash
esphome logs nils.yaml
```

Compile and upload the custom firmware:

```bash
esphome run nils.yaml
```

## MQTT

Website: <https://mosquitto.org/>

Install:

```bash
brew install mosquitto
```

Subscribe to topic:

```bash
mosquitto_sub -h "test.mosquitto.org" -t "iot/nils/debug"
```

Topics:

* Uptime Sensor: `iot/nils/sensor/uptime_sensor/state`
* WiFi Signal Sensor: `iot/nils/sensor/wifi_signal_sensor/state`
* ESP IP Address: `iot/nils/sensor/esp_ip_address/state`
* ESP Connected SSID: `iot/nils/sensor/esp_connected_ssid/state`
* ESP Connected BSSID: `iot/nils/sensor/esp_connected_bssid/state`
* ESP Mac Wifi Address: `iot/nils/sensor/esp_mac_wifi_address/state`
* ESP Latest Scan Results: `iot/nils/sensor/esp_latest_scan_results/state`
* ESP DNS Address: `iot/nils/sensor/esp_dns_address/state`
* ESPHome Version: `iot/nils/sensor/esphome_version/state`
* MQTT Status: `iot/nils/status`
