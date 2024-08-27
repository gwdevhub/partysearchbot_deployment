FROM alpine:3.20

RUN apk update && apk add \
  bash \
  gdb \
  python3 py3-pip py3-tqdm py3-pefile

WORKDIR /app

# COPY linuxbuild/ /app/build/
COPY accounts/ /app/accounts/
COPY check_and_update_gw_keys.sh /app/check_and_update_gw_keys.sh
# COPY Dependencies/ /app/Dependencies/

CMD ["sh", "-c", "while :; do sleep 2073600; done"]
