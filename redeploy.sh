#!/bin/bash

# Set the temporary directory and Docker image name
TMP_DIR="/tmp/partysearchbot_code"
DOCKER_IMAGE="partysearchbot_alpine"
ORIG_DIR="$PWD"

# Clear any existing temporary folder
rm -rf "$TMP_DIR"

# Clone the latest code into the temporary folder
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"
git clone --depth=1 --recursive https://github.com/gwdevhub/GuildWarsPartySearch.git

# Build the code using an Alpine Docker container
docker run --rm -v "$TMP_DIR/GuildWarsPartySearch":/app:Z -w /app/GuildWarsPartySearch.Bot alpine:3.20 sh -c "apk add --no-cache bash cmake ninja alpine-sdk && cmake -B linuxbuild -G \"Ninja\" && ninja -C linuxbuild"

# Stop all running containers that use the current image (after building)
docker stop $(docker ps --format "{{.ID}} {{.Image}}" | grep "partysearchbot_alpine" | awk '{print $1}')

cd "$ORIG_DIR"

# Remove the old linuxbuild directory from the current folder after stopping containers
rm -rf "$PWD/linuxbuild"

# Copy the linuxbuild directory from the temporary folder to the current folder
cp -r "$TMP_DIR/GuildWarsPartySearch/GuildWarsPartySearch.Bot/linuxbuild" "$PWD/"

# Copy the Dependencies directory from the temporary folder to the current folder
cp -r "$TMP_DIR/GuildWarsPartySearch/GuildWarsPartySearch.Bot/Dependencies" "$PWD/"

# Copy the script directory from the temporary folder to the current folder
cp -f "$TMP_DIR/GuildWarsPartySearch/GuildWarsPartySearch.Bot/check_and_update_gw_keys.sh" "$PWD/"

# Clean up the temporary folder
rm -rf "$TMP_DIR"

# Build the Docker image with the updated linuxbuild and Dependencies directory
docker build -t $DOCKER_IMAGE .
