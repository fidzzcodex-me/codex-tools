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
source /scripts/cron-runner.sh

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
start_cron_runner

run_config_check
print_banner
start_live_stats_ticker
start_log_rotation

export HEADLESS_MODE="${HEADLESS_MODE:-true}"

FINAL_CMD="$STARTUP_CMD"
USE_SUPERVISOR="false"

if [ "$STATIC_HOST_MODE" = "true" ]; then
  STATIC_DIR="${STATIC_HOST_DIR:-public}"
  mkdir -p "/home/container/${STATIC_DIR}"
  FINAL_CMD="python3 -m http.server ${APP_PORT:-3000} --directory ${STATIC_DIR} --bind 0.0.0.0"
  echo -e "${C_GREEN}[static-host] serving ./${STATIC_DIR} on port ${APP_PORT:-3000}${C_RESET}"
elif [ "$PROCESS_MANAGER" = "true" ] && [[ "$STARTUP_CMD" == node\ * ]]; then
  FINAL_CMD="pm2-runtime ${STARTUP_CMD#node }"
elif [ "$PROCESS_MANAGER" = "true" ] && [ -n "$STARTUP_CMD" ]; then
  USE_SUPERVISOR="true"
fi

if [ -z "$FINAL_CMD" ]; then
  echo -e "${C_YELLOW}No STARTUP_CMD set. Dropping into shell.${C_RESET}"
  exec /bin/bash
fi

print_access_info

EXEC_CMD="$FINAL_CMD"
if [ "$HEADLESS_MODE" = "false" ]; then
  EXEC_CMD="xvfb-run -a --server-args='-screen 0 1280x1024x24' $FINAL_CMD"
fi

if [ "$USE_SUPERVISOR" = "true" ]; then
  echo -e "${C_GREEN}[supervisor] crash-recovery aktif buat: ${FINAL_CMD}${C_RESET}"
  cat > /tmp/supervisord.conf << SUPERVISOR_EOF
[supervisord]
nodaemon=true
logfile=/tmp/supervisord.log
pidfile=/tmp/supervisord.pid

[program:app]
command=/bin/bash -c "${EXEC_CMD}"
directory=/home/container
autostart=true
autorestart=true
startretries=999
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
SUPERVISOR_EOF
  exec supervisord -c /tmp/supervisord.conf
else
  eval "$EXEC_CMD"
fi
