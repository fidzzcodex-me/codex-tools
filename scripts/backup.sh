#!/bin/bash

start_auto_backup() {
  [ "$ENABLE_AUTO_BACKUP" != "true" ] && return 0

  local interval_hours="${BACKUP_INTERVAL_HOURS:-24}"
  local backup_dir="/home/container/.codex/backups"
  mkdir -p "$backup_dir"

  (
    while true; do
      sleep "$((interval_hours * 3600))"
      local stamp
      stamp=$(date '+%Y%m%d-%H%M%S')
      tar --exclude="./.codex/backups" -czf "$backup_dir/backup-${stamp}.tar.gz" -C /home/container . 2>/dev/null

      ls -1t "$backup_dir"/backup-*.tar.gz 2>/dev/null | tail -n +6 | xargs -r rm -f
    done
  ) &
}
