#!/bin/bash

run_config_check() {
  local warnings=()

  if [ "$ENABLE_WEB_TERMINAL" = "true" ] && [ "${WEB_TERMINAL_PASSWORD:-changeme}" = "changeme" ]; then
    warnings+=("Web Terminal aktif tapi password masih default 'changeme'")
  fi

  if [ "$ENABLE_CF_TUNNEL" = "true" ] && [ -z "$CF_TOKEN" ]; then
    warnings+=("Cloudflare Tunnel aktif tapi CF_TOKEN kosong, tunnel tidak akan jalan")
  fi

  if [ "$HEADLESS_MODE" = "false" ] && ! command -v xvfb-run >/dev/null 2>&1; then
    warnings+=("HEADLESS_MODE=false tapi xvfb-run tidak ditemukan di image")
  fi

  if [ -z "$SERVER_IP" ]; then
    warnings+=("SERVER_IP tidak tersedia dari Wings, alamat server di banner mungkin tidak akurat")
  fi

  if [ "$ENABLE_TELEGRAM_BACKUP" = "true" ] && { [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; }; then
    warnings+=("Backup to Telegram aktif tapi Bot Token/Chat ID belum lengkap diisi")
  fi

  if [ "$STATIC_HOST_MODE" = "true" ] && [ -n "$STARTUP_CMD" ]; then
    warnings+=("Static Host Mode aktif, STARTUP_CMD diabaikan (server statis yang jalan, bukan app kamu)")
  fi

  if [ "$STATIC_HOST_MODE" != "true" ] && [ -n "$STARTUP_CMD" ]; then
    local entry_file=""
    case "$STARTUP_CMD" in
      node\ *)    entry_file="${STARTUP_CMD#node }" ;;
      python3\ *) entry_file="${STARTUP_CMD#python3 }" ;;
      python\ *)  entry_file="${STARTUP_CMD#python }" ;;
      php\ *)     entry_file="${STARTUP_CMD#php }" ;;
    esac
    entry_file="${entry_file%% *}"
    if [ -n "$entry_file" ] && [ "${entry_file:0:1}" != "-" ] && [ ! -f "/home/container/${entry_file}" ]; then
      warnings+=("File '${entry_file}' dari Startup Command tidak ketemu di /home/container -> ini penyebab paling umum server crash langsung exit code 1. Upload file kamu (File Manager) atau isi Git Repository Address.")
    fi
  fi

  if [ "${#warnings[@]}" -eq 0 ]; then
    return 0
  fi

  ui_section "Config Warnings"
  for w in "${warnings[@]}"; do
    ui_warn "$w"
  done
}
