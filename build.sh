#!/bin/bash

ORG=ghcr.io/koenkk/zigbee2mqtt
TAG=2.9.1

# Fail fast
set -e

# Disable Docker Advertising
export DOCKER_CLI_HINTS=false

# Get Docker major version
DOCKER_MAJOR=$(docker version --format '{{.Server.Version}}' | cut -d. -f1)

# We need at least Docker 25 so 'docker save' creates OCI archives
if (( DOCKER_MAJOR < 25 )); then
    echo "Error: Docker version must be >= 25. Detected version: $DOCKER_MAJOR" >&2
    exit 1
fi

echo "Cleaning up old files.."
rm -Rf app
rm -f zigbee2mqtt_*.app
rm -f zigbee2mqtt_*.md5

echo "Creating app directory..."
mkdir -p app

echo "Pull Docker image..."
docker pull --platform linux/arm64 ${ORG}:${TAG}

#ARCH=$(docker inspect --format '{{.Architecture}}' ${ORG}:${TAG})
#echo "Verify Docker image architecture..."
#if [ "$ARCH" != "arm64" ]; then
#    echo "Error: Image must be arm64. Detected archicture: $ARCH" >&2
#    exit 1
#fi

echo "Exporting Docker image..."
docker save --platform linux/arm64 ${ORG}:${TAG} | gzip > app/image.tar.gz

IMAGE_ID_WITH_PREFIX=$(docker inspect --format "{{.Id}}" ${ORG}:${TAG})
IMAGE_ID=${IMAGE_ID_WITH_PREFIX#sha256:}
echo "Image ID: ${IMAGE_ID}"
sed "s|{IMAGE_ID}|${IMAGE_ID}|g" app_info.json > app/app_info.json
sed "s|{IMAGE_ID}|${IMAGE_ID}|g" zigbee2mqtt.container > app/zigbee2mqtt.container

VERSION=$(echo "$TAG" | sed -E 's/^([0-9]+\.[0-9]+)-([0-9]+).*/\1.\2/')
sed -i "s|{VERSION}|${VERSION}|g" app/app_info.json

IMAGE_IDENTITY=$(docker inspect --format "{{(index .Identity.Pull 0).Repository}}" ${ORG}:${TAG})
sed -i "s|{IMAGE_IDENTITY}|${IMAGE_IDENTITY}|g" app/app_info.json

echo "Building app..."
mksquashfs app "zigbee2mqtt_${VERSION}_arm64.app" -force-uid 1001 -force-gid 1002 -quiet

echo "Calculating app checksum..."
echo `md5sum zigbee2mqtt_${VERSION}_arm64.app | awk '{ print $1 }'` > zigbee2mqtt_${VERSION}_arm64.md5

echo "Cleanup..."
docker image rm ${ORG}:${TAG}

echo "Done."
