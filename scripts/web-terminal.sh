#!/bin/bash

start_web_terminal() {
  [ "$ENABLE_WEB_TERMINAL" != "true" ] && return 0
  local port="${WEB_TERMINAL_PORT:-7681}"
  local user="${WEB_TERMINAL_USER:-admin}"
  local pass="${WEB_TERMINAL_PASSWORD:-changeme}"

  if [ "$pass" = "changeme" ]; then
    echo -e "${C_RED}[web-terminal] WEB_TERMINAL_PASSWORD masih default 'changeme'! Ganti di panel sebelum expose ke publik.${C_RESET}"
  fi

  ttyd -p "$port" -c "${user}:${pass}" -W bash >/tmp/ttyd.log 2>&1 &
}
