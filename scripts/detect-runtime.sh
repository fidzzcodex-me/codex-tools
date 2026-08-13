#!/bin/bash

setup_runtime_paths() {
  export NVM_DIR="/usr/local/nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

  if [ -n "$NODE_VERSION" ] && command -v nvm >/dev/null 2>&1; then
    nvm install "$NODE_VERSION" >/tmp/nvm-install.log 2>&1
    nvm use "$NODE_VERSION" >/dev/null 2>&1
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

  case "$cmd" in
    *node\ * | node* | *npm\ * | npm* | *npx\ * | *bun\ * | bun*)
      DETECTED_RUNTIME="Node.js"
      if [ -f "package.json" ]; then
        case "$INSTALL_DEPS" in
          pnpm) pnpm install ;;
          yarn) yarn install ;;
          bun)  bun install ;;
          *)    npm install ;;
        esac
      fi
      ;;

    *python3\ * | python3* | *python\ * | python*)
      DETECTED_RUNTIME="Python"
      if [ -f "requirements.txt" ]; then
        pip install --break-system-packages -r requirements.txt
      fi
      ;;

    *php\ * | php* | *artisan\ *)
      DETECTED_RUNTIME="PHP"
      if [ -f "composer.json" ]; then
        composer install --no-interaction
      fi
      ;;
  esac

  export DETECTED_RUNTIME
}
