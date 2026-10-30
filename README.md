# zigbee2mqtt for Catan C1 (PLCnext)

[zigbee2mqtt](https://github.com/Koenkk/zigbee2mqtt) app image for **Phoenix Contact Catan C1**

> [!WARNING]
> This is an unofficial community project. It is not affiliated with, endorsed by, or supported by Phoenix Contact.
> No support is provided. Use at your own risk; the software comes without any warranty (see [LICENSE](LICENSE)).

- Firm Code `0000000`
- Product Codes `1337001`

## Supported Devices

- Controller - Catan C1 - 1886438 (Phoenix Contact)

## Usage

- Web UI: `http://<ip of the Catan C1>:58080/`
- On first start (no `configuration.yaml` yet), zigbee2mqtt shows its onboarding page there. Enter your MQTT broker (e.g. Mosquitto) and the USB adapter (see [USB devices](#usb-devices)). Keep the frontend enabled on port `8080` (the default), which the app maps to `58080`. If the onboarding page then forwards you to `localhost` or port `8080`, open `http://<ip of the Catan C1>:58080/` yourself.
- Persistent data on the controller: `/opt/plcnext/apps/home/data/00000001337001/data/` (e.g. `configuration.yaml`, `database.db`, `coordinator_backup.json`). This directory is kept on app updates. For a backup, stop the app first, so that all files are up to date.

## USB devices

> [!NOTE]
> Supported since firmware `2026.0.3`.

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

Publishing a GitHub release (tag e.g. `v1.2.0`) builds the app with that version and attaches a `.zip` with the `.app`, `.md5` and `LICENSE` files to the release.
