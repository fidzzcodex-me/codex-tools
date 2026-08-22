#!/bin/bash

print_banner() {
  local cpu_cores ram_str disk_used disk_total uptime_str

  cpu_cores=$(get_container_cpu_cores)
  ram_str=$(get_container_memory)
  disk_used=$(df -h /home/container 2>/dev/null | awk 'NR==2 {print $3}')
  disk_total=$(df -h /home/container 2>/dev/null | awk 'NR==2 {print $2}')
  uptime_str=$(get_container_uptime)

  ui_section "codex-tools · Console"

  ui_row2 "CPU" "${cpu_cores} cores" "Uptime" "$uptime_str"
  ui_row2 "RAM" "$ram_str" "Disk" "${disk_used}/${disk_total}"
  echo ""
}

# Live-checks each toolchain right now (not cached) and prints a
# [+]/[-] line with version, e.g. "[+] Node.js  v22.11.0"
print_runtime_status() {
  local node_ver python_ver php_ver

  ui_section "Runtime"

  if command -v node >/dev/null 2>&1; then
    node_ver=$(node -v 2>/dev/null)
    ui_check_ver "Node.js" "true" "$node_ver"
  else
    ui_check_ver "Node.js" "false" ""
  fi

  if command -v python3 >/dev/null 2>&1; then
    python_ver=$(python3 --version 2>/dev/null | awk '{print $2}')
    ui_check_ver "Python" "true" "v${python_ver}"
  else
    ui_check_ver "Python" "false" ""
  fi

  if command -v php >/dev/null 2>&1; then
    php_ver=$(php -v 2>/dev/null | head -n1 | awk '{print $2}')
    ui_check_ver "PHP" "true" "v${php_ver}"
  else
    ui_check_ver "PHP" "false" ""
  fi
  echo ""
}

print_access_info() {
  local port="${APP_PORT:-3000}"
  local addr
  addr=$(get_server_address)

  ui_section "Access Info"
  ui_ok "App  → http://${SERVER_IP:-$addr}:${port}"

  if [ "$ENABLE_CF_TUNNEL" = "true" ]; then
    local tunnel_id
    tunnel_id=$(grep -oE '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' /tmp/cloudflared.log 2>/dev/null | head -n1)
    if [ -n "$tunnel_id" ]; then
      ui_info "Tunnel target → ${tunnel_id}.cfargotunnel.com"
    fi
  fi

  if [ -n "$DETECTED_RUNTIME" ] && [ "$DETECTED_RUNTIME" != "Unknown" ]; then
    ui_ok "Runtime terdeteksi → ${DETECTED_RUNTIME}"
  fi
  echo ""
}
