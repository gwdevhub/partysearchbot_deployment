#!/bin/bash

ACCOUNT=""
DETACHED_MODE="-d"
DEBUG_MODE=""
RESTART_POLICY="--restart always"
LOG_MOUNT_OPTION=""

for arg in "$@"; do
  if [ "$arg" == "-i" ]; then
    DETACHED_MODE=""
  elif [ "$arg" == "-d" ]; then
    DEBUG_MODE="true"
  elif [ "$arg" == "-l" ]; then
    LOG_MOUNT_OPTION="-v /var/log/partysearchbot:/var/log/partysearchbot"
  else
    ACCOUNT="$arg"
  fi
done

if [ "$DEBUG_MODE" == "true" ]; then
  DETACHED_MODE="-d"
  RESTART_POLICY="--rm"
fi

if [ -z "$ACCOUNT" ]; then
  echo "Please specify an account name."
  exit 1
fi

CONTAINER_NAME="partysearchbot_${ACCOUNT}"

if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "Container with name $CONTAINER_NAME already exists. Removing it..."
    docker rm -f -t 1 $CONTAINER_NAME
fi

  # -v "$PWD/accounts":/app/accounts \
docker run $DETACHED_MODE $RESTART_POLICY $LOG_MOUNT_OPTION --name "$CONTAINER_NAME" \
  --add-host party.gwtoolbox.com:217.160.162.89 \
  -v "$PWD/linuxbuild":/app/build \
  -v "$PWD/Dependencies":/app/Dependencies \
  -e ACCOUNT="$ACCOUNT" \
  partysearchbot_alpine sh -c "
    source /app/accounts/\$ACCOUNT.sh &&
    NOW=\$(date '+%Y-%m-%d_%H-%M-%S') &&
    BIN_DIR=/app/build/bin &&
    CLIENT_EXE=\$BIN_DIR/client &&
    LOG_FILE=\"/var/log/partysearchbot/\$CHARACTER/\$NOW.txt\" &&
    BUILD_VERSION_FILE=\Gw.build &&
    PLUGIN_EXE=\$BIN_DIR/libGuildWarsPartySearch.Bot.so &&
    LOG_DIR=\$(dirname \"\$LOG_FILE\") &&
    mkdir -p \"\$LOG_DIR\" &&
    touch \"\$LOG_FILE\" &&
    source /app/check_and_update_gw_keys.sh &&
    export HEADQUARTER_PASSWORD=\"\$PASSWORD\" &&
    export HEADQUARTER_2FA_SECRET=\"\$2FA_SECRET\" &&
    RUN_CMD=\"\$CLIENT_EXE -email \\\"\$EMAIL\\\" -character \\\"\$CHARACTER\\\" -district \\\"\$DISTRICT\\\" -travel-mapid \\\"\$MAP_ID\\\" -api-key \\\"\$WEBSOCKET_API_KEY\\\" -websocket-url \\\"\$WEBSOCKET_URL\\\" -l \\\"\$LOG_FILE\\\" -file-game-version \\\"\$BUILD_VERSION_FILE\\\" \$PLUGIN_EXE\" &&
    echo \"Running command: \$RUN_CMD\"
    if [ \"$DEBUG_MODE\" == \"true\" ]; then
      echo \"Container is now in debug mode. Use 'docker exec -ti $CONTAINER_NAME /bin/sh' to access it.\"
      exec sleep infinity
    else
      bash -c \"\$RUN_CMD\"
    fi
  "

if [ "$DEBUG_MODE" == "true" ]; then
  docker exec -ti $CONTAINER_NAME /bin/sh
  docker stop -t 1 $CONTAINER_NAME
fi
