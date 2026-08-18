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

  # nvm use prepends its own node bin dir to PATH; re-assert these so they
  # stay reachable no matter which NODE_VERSION got selected above.
  export PATH="/usr/local/go/bin:${CARGO_HOME:-/usr/local/cargo}/bin:${BUN_INSTALL:-/usr/local/bun}/bin:${PATH}"

  # Force Go's build cache to a writable location. Without this, Go falls
  # back to $XDG_CACHE_HOME/go-build, which is /opt/camoufox-cache (baked
  # read-only for Camoufox) and makes every go build/run fail.
  export GOCACHE="/home/container/.cache/go-build"
  mkdir -p "$GOCACHE" 2>/dev/null
}

detect_and_setup_runtime() {
  local cmd="$STARTUP_CMD"
  DETECTED_RUNTIME="Unknown"

  case "$cmd" in
    *bun\ * | bun*)
      DETECTED_RUNTIME="Bun"
      if [ -f "package.json" ]; then
        bun install
      fi
      ;;

    *node\ * | node* | *npm\ * | npm* | *npx\ * | *pnpm\ * | pnpm* | *yarn\ * | yarn*)
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

    *go\ run\ * | *go\ build\ * | go\ * | ./app_bin* | ./main*)
      DETECTED_RUNTIME="Go"
      if [ -f "go.mod" ]; then
        go mod download
        if [ "$AUTO_BUILD" = "true" ] && [[ "$cmd" == ./* ]]; then
          go build -o app_bin .
        fi
      fi
      ;;

    *cargo\ run* | *cargo\ * | ./target/*)
      DETECTED_RUNTIME="Rust"
      if [ -f "Cargo.toml" ] && [ "$AUTO_BUILD" = "true" ] && [[ "$cmd" == ./target/* ]]; then
        cargo build --release
      fi
      ;;

    *g++\ * | *gcc\ *)
      DETECTED_RUNTIME="C/C++"
      ;;
  esac

  export DETECTED_RUNTIME
}
