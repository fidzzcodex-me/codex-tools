#!/bin/bash

start_live_stats_ticker() {
  local interval="${LIVE_STATS_INTERVAL:-30}"
  [ "$interval" = "0" ] && return 0

  (
    while true; do
      sleep "$interval"
      local uptime_str ram_str disk_used disk_total mem_pct alert
      uptime_str=$(get_container_uptime)
      ram_str=$(get_container_memory)
      disk_used=$(df -h /home/container 2>/dev/null | awk 'NR==2 {print $3}')
      disk_total=$(df -h /home/container 2>/dev/null | awk 'NR==2 {print $2}')
      mem_pct=$(get_memory_percent)
      alert=""
      if [ "$mem_pct" -ge 90 ] 2>/dev/null; then
        alert=" ${C_RED}⚠ RAM ${mem_pct}%${C_RESET}"
      fi
      echo -e "${C_OVERLAY}[${C_YELLOW}live${C_OVERLAY}]${C_RESET} ${C_TEXT}uptime=${C_TEAL}${uptime_str}${C_TEXT} ram=${C_TEAL}${ram_str}${C_TEXT} disk=${C_TEAL}${disk_used}/${disk_total}${C_RESET}${alert}"
    done
  ) &
}
