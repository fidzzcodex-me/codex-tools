#!/bin/bash

start_web_terminal() {
  [ "$ENABLE_WEB_TERMINAL" != "true" ] && return 0
  local port="${WEB_TERMINAL_PORT:-7681}"
  local user="${WEB_TERMINAL_USER:-admin}"
  local pass="${WEB_TERMINAL_PASSWORD:-changeme}"

  if [ "$pass" = "changeme" ]; then
    ui_warn "[web-terminal] WEB_TERMINAL_PASSWORD masih default 'changeme'! Ganti di panel sebelum expose ke publik."
  fi

  if ! command -v ttyd >/dev/null 2>&1; then
    ui_err "[web-terminal] binary ttyd tidak ditemukan di image, rebuild image dulu"
    return 1
  fi

  ttyd -p "$port" -c "${user}:${pass}" -W bash >/tmp/ttyd.log 2>&1 &
  local ttyd_pid=$!
  sleep 1
  if kill -0 "$ttyd_pid" 2>/dev/null; then
    ui_ok "[web-terminal] ttyd jalan di port ${port} (pid ${ttyd_pid})"
    ui_info "[web-terminal] pastikan port ${port} sudah ditambahkan sebagai Allocation di tab Network panel, kalau belum dia tidak akan bisa diakses dari luar"
  else
    ui_err "[web-terminal] ttyd gagal start, isi /tmp/ttyd.log:"
    sed 's/^/    /' /tmp/ttyd.log 2>/dev/null
  fi
}
