#!/bin/bash

print_banner() {
  local node_ver python_ver php_ver os_name kernel cpu_cores ram_str disk_used disk_total uptime_str addr

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

  echo ""
  echo -e "${C_MAUVE}  ╭──────────────────────────────────────────────╮${C_RESET}"
  echo -e "${C_MAUVE}  │${C_RESET}  ${C_BOLD}${C_TEXT}root's Console${C_RESET}"
  echo -e "${C_MAUVE}  ╰──────────────────────────────────────────────╯${C_RESET}"
  echo ""
  echo -e "  ${C_SKY}OS${C_RESET}            : ${C_TEXT}${os_name}${C_RESET}"
  echo -e "  ${C_SKY}Kernel${C_RESET}        : ${C_TEXT}${kernel}${C_RESET} ${C_OVERLAY}(host-shared)${C_RESET}"
  echo -e "  ${C_SKY}CPU Cores${C_RESET}     : ${C_TEXT}${cpu_cores}${C_RESET}"
  echo -e "  ${C_SKY}RAM${C_RESET}           : ${C_TEXT}${ram_str}${C_RESET}"
  echo -e "  ${C_SKY}Disk${C_RESET}          : ${C_TEXT}${disk_used} / ${disk_total}${C_RESET}"
  echo -e "  ${C_SKY}Uptime${C_RESET}        : ${C_TEXT}${uptime_str}${C_RESET}"
  echo -e "  ${C_SKY}Server Address${C_RESET}: ${C_TEXT}${addr}${C_RESET}"
  echo ""
  echo -e "  ${C_SKY}Node.js${C_RESET}       : ${C_TEXT}${node_ver}${C_RESET}"
  echo -e "  ${C_SKY}Python${C_RESET}        : ${C_TEXT}${python_ver}${C_RESET}"
  echo -e "  ${C_SKY}PHP${C_RESET}           : ${C_TEXT}${php_ver}${C_RESET}"
  echo -e "  ${C_SKY}Headless Mode${C_RESET} : ${C_TEXT}${HEADLESS_MODE:-true}${C_RESET}"
  echo -e "  ${C_SKY}Process Manager${C_RESET}: ${C_TEXT}$([ "$PROCESS_MANAGER" = "true" ] && echo "PM2" || echo "off")${C_RESET}"
  echo ""
  echo -e "  ${C_SKY}Web Terminal${C_RESET}  : $([ "$ENABLE_WEB_TERMINAL" = "true" ] && echo "${C_GREEN}http://${SERVER_IP:-?}:${WEB_TERMINAL_PORT:-7681} (protected)${C_RESET}" || echo "${C_OVERLAY}disabled${C_RESET}")"
  echo -e "  ${C_SKY}Tunnel${C_RESET}        : $([ "$ENABLE_CF_TUNNEL" = "true" ] && echo "${C_GREEN}Cloudflare${C_RESET}" || echo "${C_OVERLAY}disabled${C_RESET}")"
  echo -e "  ${C_SKY}Auto Backup${C_RESET}   : $([ "$ENABLE_AUTO_BACKUP" = "true" ] && echo "${C_GREEN}every ${BACKUP_INTERVAL_HOURS:-24}h${C_RESET}" || echo "${C_OVERLAY}disabled${C_RESET}")"
  echo ""
}
