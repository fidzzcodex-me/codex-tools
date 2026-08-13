#!/bin/bash

print_logo() {
  echo -e "${C_MAUVE}"
  cat << 'LOGO'
  ┌─────────────────────────┐
  │       C O D E X         │
  │      custom  tools      │
  └─────────────────────────┘
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
  clear 2>/dev/null
  print_logo
  echo -e "  ${C_SKY}Booting root's environment...${C_RESET}"
  echo ""
  boot_step "Registering console identity"
  boot_step "Mounting workspace"
  boot_step "Detecting runtime environment"
  boot_step "Starting background services"
  boot_step "Finalizing system"
  echo ""
}
