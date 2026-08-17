#!/bin/bash

print_banner() {
  local node_ver python_ver php_ver os_name kernel cpu_cores ram_str disk_used disk_total uptime_str addr pm_mode

  node_ver=$(node -v 2>/dev/null || echo "not active")
  python_ver=$(python3 --version 2>/dev/null | awk '{print $2}' || echo "not active")
  php_ver=$(php -v 2>/dev/null | head -n1 | awk '{print $2}' || echo "not active")

  os_name=$(grep -oP '(?<=PRETTY_NAME=").*(?=")' /etc/os-release 2>/dev/null)
  [ -z "$os_name" ] && os_name="unknown"
  kernel=$(uname -r)
  cpu_cores=$(get_container_cpu_cores)
  ram_str=$(get_container_memory)
  disk_used=$(df -h /home/container 2>/dev/null | awk 'NR==2 {print $3}')
  disk_total=$(df -h /home/container 2>/dev/null | awk 'NR==2 {print $2}')
  uptime_str=$(get_container_uptime)
  addr=$(get_server_address)

  if [ "$PROCESS_MANAGER" != "true" ]; then
    pm_mode="off"
  elif [[ "$STARTUP_CMD" == node\ * ]]; then
    pm_mode="PM2 (Node)"
  else
    pm_mode="Supervisor"
  fi

  ui_section "root's Console"

  ui_row "OS" "$os_name"
  ui_row "Kernel" "${kernel} (host-shared)"
  ui_row "CPU Cores" "$cpu_cores"
  ui_row "RAM" "$ram_str"
  ui_row "Disk" "${disk_used} / ${disk_total}"
  ui_row "Uptime" "$uptime_str"
  ui_row "Address" "$addr"
  echo ""
  ui_row "Node.js" "$node_ver"
  ui_row "Python" "$python_ver"
  ui_row "PHP" "$php_ver"
  ui_row "Headless" "${HEADLESS_MODE:-true}"
  ui_row "Proc. Manager" "$pm_mode"
  echo ""
  ui_row "Chromium" "${PUPPETEER_EXECUTABLE_PATH:-not found}"
  ui_row "Firefox" "$(get_browser_path firefox)"
  ui_row "WebKit" "$(get_browser_path webkit)"
  ui_row "Camoufox" "$([ -d /opt/camoufox-cache ] && echo "ready" || echo "not baked")"
  ui_row "Modules" "ffmpeg, imagemagick, sharp/canvas, git-lfs, pg/mysql/redis"
  echo ""

  if [ "$ENABLE_WEB_TERMINAL" = "true" ]; then
    ui_ok "Web Terminal  -> http://${SERVER_IP:-?}:${WEB_TERMINAL_PORT:-7681} (protected)"
  else
    ui_info "Web Terminal  -> disabled"
  fi

  if [ "$ENABLE_CF_TUNNEL" = "true" ]; then
    ui_ok "Tunnel        -> Cloudflare"
  else
    ui_info "Tunnel        -> disabled"
  fi

  if [ "$ENABLE_AUTO_BACKUP" = "true" ]; then
    ui_ok "Auto Backup   -> every ${BACKUP_INTERVAL_HOURS:-24}h"
  else
    ui_info "Auto Backup   -> disabled"
  fi

  if [ "$ENABLE_TELEGRAM_BACKUP" = "true" ]; then
    ui_ok "  -> Telegram sync aktif"
  else
    ui_info "  -> Telegram sync off"
  fi
  echo ""
}

print_access_info() {
  local port="${APP_PORT:-3000}"
  local addr
  addr=$(get_server_address)

  ui_section "Access Info"
  ui_ok "App          -> http://${SERVER_IP:-$addr}:${port}"

  if [ "$ENABLE_CF_TUNNEL" = "true" ]; then
    local tunnel_id
    tunnel_id=$(grep -oE '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' /tmp/cloudflared.log 2>/dev/null | head -n1)
    if [ -n "$tunnel_id" ]; then
      ui_info "Tunnel target -> ${tunnel_id}.cfargotunnel.com"
    fi
  fi
  echo ""
}
