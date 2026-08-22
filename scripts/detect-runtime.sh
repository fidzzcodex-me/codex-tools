#!/bin/bash

setup_runtime_paths() {
  export NVM_DIR="/usr/local/nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

  if [ -n "$NODE_VERSION" ] && command -v nvm >/dev/null 2>&1; then
    if nvm ls "$NODE_VERSION" >/dev/null 2>&1; then
      nvm use "$NODE_VERSION" >/dev/null 2>&1
    else
      ui_warn "Node ${NODE_VERSION} belum ada di cache image, downloading (ini cuma terjadi sekali)..."
      nvm install "$NODE_VERSION" >/tmp/nvm-install.log 2>&1
      nvm use "$NODE_VERSION" >/dev/null 2>&1
    fi
  fi

  if [ -n "$PYTHON_VERSION" ] && command -v "python$PYTHON_VERSION" >/dev/null 2>&1; then
    update-alternatives --set python3 "/usr/bin/python$PYTHON_VERSION" >/dev/null 2>&1
  fi

  if [ -n "$PHP_VERSION" ] && command -v "php$PHP_VERSION" >/dev/null 2>&1; then
    update-alternatives --set php "/usr/bin/php$PHP_VERSION" >/dev/null 2>&1
  fi

}

detect_and_setup_runtime() {
  local cmd="$STARTUP_CMD"
  DETECTED_RUNTIME="Unknown"

  if [ "$SKIP_DEPS_INSTALL" = "true" ]; then
    ui_info "SKIP_DEPS_INSTALL=true -> lewati semua install dependency, restart lebih cepat"
  fi

  case "$cmd" in
    *node\ * | node* | *npm\ * | npm* | *npx\ * | *pnpm\ * | pnpm* | *yarn\ * | yarn*)
      DETECTED_RUNTIME="Node.js"
      if [ -f "package.json" ] && [ "$SKIP_DEPS_INSTALL" != "true" ]; then
        LOCK_HASH_FILE=".codex-lock-hash"
        CURRENT_HASH=""
        for lockfile in package-lock.json pnpm-lock.yaml yarn.lock; do
          [ -f "$lockfile" ] && CURRENT_HASH="${CURRENT_HASH}$(md5sum "$lockfile" 2>/dev/null)"
        done
        [ -z "$CURRENT_HASH" ] && CURRENT_HASH="$(md5sum package.json 2>/dev/null)"

        PREV_HASH=""
        [ -f "$LOCK_HASH_FILE" ] && PREV_HASH="$(cat "$LOCK_HASH_FILE" 2>/dev/null)"

        if [ -d "node_modules" ] && [ "$CURRENT_HASH" = "$PREV_HASH" ]; then
          ui_ok "node_modules sudah lengkap dan lockfile tidak berubah, skip npm install"
        else
          case "$INSTALL_DEPS" in
            pnpm) pnpm install ;;
            yarn) yarn install ;;
            *)    [ -f "package-lock.json" ] && npm ci || npm install ;;
          esac
          echo "$CURRENT_HASH" > "$LOCK_HASH_FILE"
        fi
      fi
      ;;

    *python3\ * | python3* | *python\ * | python*)
      DETECTED_RUNTIME="Python"
      if [ -f "requirements.txt" ] && [ "$SKIP_DEPS_INSTALL" != "true" ]; then
        pip install --break-system-packages -r requirements.txt
      fi
      ;;

    *php\ * | php* | *artisan\ *)
      DETECTED_RUNTIME="PHP"
      if [ -f "composer.json" ] && [ "$SKIP_DEPS_INSTALL" != "true" ]; then
        composer install --no-interaction
      fi
      ;;
  esac

  export DETECTED_RUNTIME
}
