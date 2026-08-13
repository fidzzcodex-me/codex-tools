#!/bin/bash

send_webhook_notification() {
  [ -z "$WEBHOOK_URL" ] && return 0

  local ip time payload
  ip=$(hostname -I 2>/dev/null | awk '{print $1}')
  time=$(date '+%Y-%m-%d %H:%M:%S')

  if [ -n "$WEBHOOK_PAYLOAD" ]; then
    payload="$WEBHOOK_PAYLOAD"
    payload="${payload//\{event\}/start}"
    payload="${payload//\{server\}/${HOSTNAME:-server}}"
    payload="${payload//\{ip\}/$ip}"
    payload="${payload//\{time\}/$time}"
  else
    payload=$(cat <<JSON
{"content": "Server ${HOSTNAME:-container} started at ${time} (${ip})"}
JSON
)
  fi

  curl -s -X POST -H "Content-Type: application/json" -d "$payload" "$WEBHOOK_URL" >/dev/null 2>&1 &
}
