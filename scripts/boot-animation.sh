#!/bin/bash

print_logo() {
  echo -e "${C_MAUVE}"
  cat << 'LOGO'
  ╭──────────────────────────────────────────────────╮
  │                                                    │
  │     ▄████▄   ▒█████  ▓█████▄ ▓█████ ▒██   ██▒     │
  │    ▒██▀ ▀█  ▒██▒  ██▒▒██▀ ██▌▓█   ▀ ▒▒ █ █ ▒░     │
  │    ▒▓█    ▄ ▒██░  ██▒░██   █▌▒███   ░░  █   ░     │
  │    ▒▓▓▄ ▄██▒▒██   ██░░▓█▄   ▌▒▓█  ▄  ░ █ █ ▒      │
  │    ▒ ▓███▀ ░░ ████▓▒░░▒████▓ ░▒████▒▒██▒ ▒██▒     │
  │                custom tools runtime               │
  │                                                    │
  ╰──────────────────────────────────────────────────╯
LOGO
  echo -e "${C_RESET}"
}

boot_step() {
  local label="$1"
  printf "  ${C_OVERLAY}[    ] %s${C_RESET}\r" "$label"
  sleep 0.12
  printf "  ${C_GREEN}[ OK ]${C_RESET} ${C_TEXT}%s${C_RESET}\n" "$label"
}

run_boot_animation() {
  # Plain "clear" on modern ncurses also sends the E3 (erase-scrollback)
  # sequence. Pterodactyl's web console honors it, which was wiping out
  # every "[boot] ..." diagnostic line printed above before the user ever
  # got a chance to read them. "-x" clears only the visible viewport.
  clear -x 2>/dev/null || printf '\033[H\033[2J'
  print_logo
  echo -e "  ${C_SKY}Booting root's environment...${C_RESET}"
  echo ""
  boot_step "Registering console identity"
  boot_step "Mounting workspace"
  boot_step "Detecting runtime (Node.js/Python/PHP)"
  boot_step "Starting background services"
  boot_step "Finalizing system"
  echo ""
}
