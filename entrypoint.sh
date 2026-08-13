#!/bin/bash
cd /home/container || exit 1

source /scripts/theme.sh
source /scripts/identity.sh
source /scripts/sysinfo.sh
source /scripts/config-check.sh
source /scripts/banner.sh
source /scripts/boot-animation.sh
source /scripts/live-stats.sh
source /scripts/log-rotate.sh
source /scripts/detect-runtime.sh
source /scripts/webhook.sh
source /scripts/backup.sh
source /scripts/web-terminal.sh
source /scripts/tunnel.sh
source /scripts/git-setup.sh

setup_identity
run_boot_animation

setup_git_repo

setup_runtime_paths
detect_and_setup_runtime

CHROME_BIN=$(find /opt/browsers -maxdepth 3 -type f -name "chrome" 2>/dev/null | head -n1)
if [ -n "$CHROME_BIN" ]; then
  export PUPPETEER_EXECUTABLE_PATH="$CHROME_BIN"
  export CHROME_PATH="$CHROME_BIN"
fi

start_web_terminal
start_cf_tunnel
start_auto_backup
send_webhook_notification

run_config_check
print_banner
start_live_stats_ticker
start_log_rotation

export HEADLESS_MODE="${HEADLESS_MODE:-true}"

FINAL_CMD="$STARTUP_CMD"
if [ "$PROCESS_MANAGER" = "true" ] && [[ "$STARTUP_CMD" == node\ * ]]; then
  FINAL_CMD="pm2-runtime ${STARTUP_CMD#node }"
fi

if [ -z "$FINAL_CMD" ]; then
  echo -e "${C_YELLOW}No STARTUP_CMD set. Dropping into shell.${C_RESET}"
  exec /bin/bash
fi

if [ "$HEADLESS_MODE" = "false" ]; then
  eval "xvfb-run -a --server-args='-screen 0 1280x1024x24' $FINAL_CMD"
else
  eval "$FINAL_CMD"
fi
