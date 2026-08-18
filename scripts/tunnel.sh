#!/bin/bash

start_cf_tunnel() {
  [ "$ENABLE_CF_TUNNEL" != "true" ] && return 0
  if [ -z "$CF_TOKEN" ]; then
    ui_warn "[tunnel] ENABLE_CF_TUNNEL is true but CF_TOKEN is empty, skipping."
    return 0
  fi
  cloudflared tunnel run --token "$CF_TOKEN" >/tmp/cloudflared.log 2>&1 &
}
