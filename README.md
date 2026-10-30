# zigbee2mqtt for Catan C1 (PLCnext)

[zigbee2mqtt](https://github.com/Koenkk/zigbee2mqtt) app image for **Phoenix Contact Catan C1**

> [!WARNING]
> This is an unofficial community project. It is not affiliated with, endorsed by, or supported by Phoenix Contact.
> No support is provided. Use at your own risk; the software comes without any warranty (see [LICENSE](LICENSE)).

- Firm Code `0000000`
- Product Codes `1337001`

## Supported Devices

- Controller - Catan C1 - 1886438 (Phoenix Contact)

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

## Dev

### Build

```bash
sudo apt install -y squashfs-tools docker-ce docker-ce-cli
bash build.sh <app version>   # e.g. bash build.sh 1.2.0
```

### Release

Publishing a GitHub release (tag e.g. `v1.2.0`) builds the app with that version and attaches a `.zip` with the `.app`, `.md5` and `LICENSE` files to the release (GitHub does not accept `.app` files as release assets).
