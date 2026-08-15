#!/bin/bash

send_backup_to_telegram() {
  local file="$1"
  [ "$ENABLE_TELEGRAM_BACKUP" != "true" ] && return 0
  [ -z "$TELEGRAM_BOT_TOKEN" ] && return 0
  [ -z "$TELEGRAM_CHAT_ID" ] && return 0

  local size_mb
  size_mb=$(( $(stat -c%s "$file" 2>/dev/null || echo 0) / 1024 / 1024 ))

  if [ "$size_mb" -gt 49 ]; then
    echo -e "${C_YELLOW:-}[backup] file ${size_mb}MB kelewat limit Telegram Bot API (50MB), skip upload ke Telegram${C_RESET:-}"
    return 1
  fi

  curl -s -o /tmp/telegram-backup.log -F "chat_id=${TELEGRAM_CHAT_ID}" \
    -F "document=@${file}" \
    -F "caption=Codex Tools backup: $(basename "$file")" \
    "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendDocument"

  if grep -q '"ok":true' /tmp/telegram-backup.log 2>/dev/null; then
    echo -e "${C_GREEN:-}[backup] terkirim ke Telegram: $(basename "$file")${C_RESET:-}"
  else
    echo -e "${C_RED:-}[backup] gagal kirim ke Telegram, cek TELEGRAM_BOT_TOKEN/TELEGRAM_CHAT_ID${C_RESET:-}"
  fi
}

run_backup_once() {
  local backup_dir="/home/container/.codex/backups"
  mkdir -p "$backup_dir"
  local stamp
  stamp=$(date '+%Y%m%d-%H%M%S')
  local target="${backup_dir}/backup-${stamp}.tar.gz"

  tar --exclude="./.codex/backups" -czf "$target" -C /home/container . 2>/dev/null

  ls -1t "$backup_dir"/backup-*.tar.gz 2>/dev/null | tail -n +6 | xargs -r rm -f

  send_backup_to_telegram "$target"
}

start_auto_backup() {
  [ "$ENABLE_AUTO_BACKUP" != "true" ] && return 0
  local interval_hours="${BACKUP_INTERVAL_HOURS:-24}"

  (
    while true; do
      sleep "$((interval_hours * 3600))"
      run_backup_once
    done
  ) &
}
