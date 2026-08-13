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

  if [ "${#warnings[@]}" -eq 0 ]; then
    return 0
  fi

  echo ""
  echo -e "${C_YELLOW}  ⚠ Config warnings:${C_RESET}"
  for w in "${warnings[@]}"; do
    echo -e "${C_YELLOW}    - ${w}${C_RESET}"
  done
}
