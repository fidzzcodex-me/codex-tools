#!/bin/bash

C_RESET=$'\033[0m'
C_BOLD=$'\033[1m'

C_ROSEWATER=$'\033[38;2;245;224;220m'
C_PINK=$'\033[38;2;245;194;231m'
C_MAUVE=$'\033[38;2;203;166;247m'
C_SKY=$'\033[38;2;137;220;235m'
C_TEAL=$'\033[38;2;148;226;213m'
C_GREEN=$'\033[38;2;166;227;161m'
C_YELLOW=$'\033[38;2;249;226;175m'
C_PEACH=$'\033[38;2;250;179;135m'
C_RED=$'\033[38;2;243;139;168m'
C_TEXT=$'\033[38;2;205;214;244m'
C_OVERLAY=$'\033[38;2;108;112;134m'

ui_section() {
  local title="$1"
  echo ""
  echo -e "${C_MAUVE}  ╭──────────────────────────────────────────────╮${C_RESET}"
  printf "${C_MAUVE}  │${C_RESET}  ${C_BOLD}${C_TEXT}%-46s${C_RESET}${C_MAUVE}│${C_RESET}\n" "$title"
  echo -e "${C_MAUVE}  ╰──────────────────────────────────────────────╯${C_RESET}"
}

ui_row() {
  local label="$1" value="$2"
  printf "  ${C_SKY}%-16s${C_RESET}: ${C_TEXT}%s${C_RESET}\n" "$label" "$value"
}

ui_ok() {
  echo -e "  ${C_GREEN}✓${C_RESET} ${C_TEXT}$1${C_RESET}"
}

ui_warn() {
  echo -e "  ${C_YELLOW}!${C_RESET} ${C_TEXT}$1${C_RESET}"
}

ui_err() {
  echo -e "  ${C_RED}✗${C_RESET} ${C_TEXT}$1${C_RESET}"
}

ui_info() {
  echo -e "  ${C_OVERLAY}»${C_RESET} ${C_OVERLAY}$1${C_RESET}"
}
