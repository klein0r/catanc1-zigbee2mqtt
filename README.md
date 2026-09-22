# zigbee2mqtt for Catan C1 (PLCnext)

[zigbee2mqtt](https://github.com/Koenkk/zigbee2mqtt) app image for **Phoenix Contact Catan C1**

## Build

```bash
sudo apt install -y squashfs-tools docker-ce docker-ce-cli
bash build.sh
```

## USB devices

Supported since firmware `2026.0.3`.

Path (example):

```
/dev/usb-devices/symlinks/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_b005234c56c9eb11b4d08f4f1d69213e-if00-port0
```

## WBM

![plcNextControl](/docs/img/plcNextControl.png)

## Known issues

- No support for ch340/ch341 chipsets
