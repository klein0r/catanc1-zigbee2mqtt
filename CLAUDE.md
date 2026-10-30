# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A packaging repo, not application source. It wraps the upstream `ghcr.io/koenkk/zigbee2mqtt` Docker image into a PLCnext app (`.app` squashfs) for the Phoenix Contact **Catan C1** controller (arm64). There is no code to compile, and there are no tests or linters.

## Build

```bash
sudo apt install -y squashfs-tools docker-ce docker-ce-cli
bash build.sh <app version>   # e.g. 1.2.0; a leading "v" is stripped
```

- The app version is passed as the only argument and is independent of the zigbee2mqtt version (`TAG=` in [build.sh](build.sh)).
- Build on Linux: `build.sh` uses GNU `sed -i` and `md5sum`, so it fails on macOS as written.
- Needs Docker >= 25 so that `docker save` emits an OCI archive; the script checks this.
- Output: `zigbee2mqtt_<VERSION>_arm64.app` and a matching `.md5` in the repo root. Both are gitignored, as is the `app/` staging directory.

## Releases

[release.yml](.github/workflows/release.yml) runs when a GitHub release is published: it calls `build.sh` with the release tag as app version and attaches the `.app`, `.md5` and `LICENSE` to the release, zipped, because GitHub rejects `.app` release assets (HTTP 422). It installs its own Docker via `docker/setup-docker-action` with the containerd image store, because `build.sh` reads `.Identity` from `docker inspect` (Docker >= 29.2) and the runner's preinstalled Docker is older.

## Updating zigbee2mqtt

Most commits only bump `TAG=` in [build.sh](build.sh), which sets the upstream image tag. `TAG` goes verbatim into `IMAGE_TAG`; the app version comes from the release tag, not from `TAG`.

## How the pieces fit together

`build.sh` pulls the arm64 image, saves it as `app/image.tar.gz`, copies the two templates into `app/`, fills in build-time placeholders, and then runs `mksquashfs` with uid/gid 1001/1002.

There are two kinds of placeholders. Don't mix them up:

- **Build-time, `{CURLY}`**: `{VERSION}` (app version), `{IMAGE_TAG}` (zigbee2mqtt image tag), `{IMAGE_ID}` and `{IMAGE_IDENTITY}`, filled in by `sed` in `build.sh`. New placeholders also need a dummy value in [validate-app-info.yml](.github/workflows/validate-app-info.yml).
- **Runtime, `${SHELL}`**: `${APP_ID}`, `${APP_PERSISTENT_DIR}`, `${IMAGE_NAME}`, `${IMAGE_TAG}`, `${FIRST_INGRESS_PORT}` and `${FIRST_OUTGRESS_PORT}` in [zigbee2mqtt.container](zigbee2mqtt.container). PLCnext fills these in on the device. Some come from the firmware (`APP_ID`, `APP_PERSISTENT_DIR`); the rest come from `ocicontainer.environmentVariables` in [app_info.json](app_info.json).

[app_info.json](app_info.json) is the PLCnext app manifest. It declares:

- the persistent `data` directory, mounted into the container as `/app/data`;
- the image and quadlet file paths inside the app (`/image.tar.gz` and `/zigbee2mqtt.container`);
- the port mapping: container `8080` (zigbee2mqtt web UI) to host `58080`.

The `PortLink` URL `"58080/"` must stay in sync with `FIRST_OUTGRESS_PORT`. Keep `identifier` stable, because it identifies the app on the device for updates.

[zigbee2mqtt.container](zigbee2mqtt.container) is a Podman Quadlet unit; see the [podman-systemd.unit docs](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html). USB coordinators are passed through by bind-mounting `/dev/usb-devices` with `rslave` propagation, together with `User=1001:1002` (`app_user`:`plcnext`, as the [CatanIO app docs](https://github.com/PLCnext/CatanIO/tree/main/apps) require for store apps), `GroupAdd=keep-groups` and `UserNS=keep-id`. Users point zigbee2mqtt at a path under `/dev/usb-devices/symlinks/...`.

## Constraints

- USB passthrough requires firmware 2026.0.3 or later (`minfirmware_version` in the manifest).
- CH340/CH341-based USB dongles are not supported.
