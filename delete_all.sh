#!/bin/bash

# Get all containers with 'partysearchbot_alpine' in the image name
CONTAINER_IDS=$(docker ps -a --format "{{.ID}} {{.Image}}" | grep "partysearchbot_alpine" | awk '{print $1}')

if [ -z "$CONTAINER_IDS" ]; then
  echo "No running containers with 'partysearchbot_alpine' in the image name found."
else
  echo "Forcefully stopping and removing the following containers:"
  echo "$CONTAINER_IDS"

  for CONTAINER_ID in $CONTAINER_IDS; do
    docker rm -f -t 1 $CONTAINER_ID
  done

  echo "All containers with 'partysearchbot_alpine' in the image name have been forcefully stopped and removed."
fi
