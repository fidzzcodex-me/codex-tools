#!/bin/bash

C_RESET=$'\033[0m'
C_BOLD=$'\033[1m'
C_DIM=$'\033[2m'

C_ROSEWATER=$'\033[38;2;245;224;220m'
C_PINK=$'\033[38;2;245;194;231m'
C_MAUVE=$'\033[38;2;203;166;247m'
C_SKY=$'\033[38;2;137;220;235m'
C_TEAL=$'\033[38;2;148;226;213m'
C_GREEN=$'\033[38;2;166;227;161m'
C_YELLOW=$'\033[38;2;249;226;175m'
C_PEACH=$'\033[38;2;250;179;135m'
C_RED=$'\033[38;2;243;139;168m'
C_LAVENDER=$'\033[38;2;180;190;254m'
C_TEXT=$'\033[38;2;205;214;244m'
C_SUBTEXT=$'\033[38;2;166;173;200m'
C_OVERLAY=$'\033[38;2;108;112;134m'
C_SURFACE=$'\033[38;2;69;71;90m'

UI_WIDTH=54

# Strip ANSI color codes so we can measure real visible length.
_ui_strip_ansi() {
  printf '%s' "$1" | sed -E 's/\x1b\[[0-9;]*m//g'
}

# Truncate a plain string to N visible chars, appending an ellipsis if cut.
_ui_truncate() {
  local str="$1" max="$2"
  local len=${#str}
  if [ "$len" -le "$max" ]; then
    printf '%s' "$str"
  else
    printf '%s…' "${str:0:$((max - 1))}"
  fi
}

# Pad a plain (already-truncated) string to N visible chars with spaces.
_ui_pad() {
  local str="$1" width="$2"
  local len=${#str}
  local pad=$((width - len))
  [ "$pad" -lt 0 ] && pad=0
  printf '%s%*s' "$str" "$pad" ""
}

ui_section() {
  local title="$1"
  local inner=$((UI_WIDTH - 2))
  local line
  line=$(printf '─%.0s' $(seq 1 "$inner"))
  echo ""
  echo -e "${C_MAUVE}  ╭${line}╮${C_RESET}"
  printf "${C_MAUVE}  │${C_RESET} ${C_BOLD}${C_TEXT}%s${C_RESET}${C_MAUVE} │${C_RESET}\n" "$(_ui_pad "$(_ui_truncate "$title" $((inner - 2)))" $((inner - 2)))"
  echo -e "${C_MAUVE}  ╰${line}╯${C_RESET}"
}

ui_row() {
  local label="$1" value="$2"
  local label_w=15 value_w=$((UI_WIDTH - label_w - 6))
  local lbl val
  lbl=$(_ui_pad "$(_ui_truncate "$label" "$label_w")" "$label_w")
  val=$(_ui_truncate "$value" "$value_w")
  printf "  ${C_SKY}%s${C_RESET} ${C_OVERLAY}│${C_RESET} ${C_TEXT}%s${C_RESET}\n" "$lbl" "$val"
}

# Two labeled values on one line, evenly split. Good for compact stat pairs.
ui_row2() {
  local l1="$1" v1="$2" l2="$3" v2="$4"
  local half=$(((UI_WIDTH - 2) / 2))
  local lbl_w=9
  local val_w=$((half - lbl_w - 2))
  local lbl1 val1 lbl2 val2
  lbl1=$(_ui_pad "$(_ui_truncate "$l1" "$lbl_w")" "$lbl_w")
  val1=$(_ui_pad "$(_ui_truncate "$v1" "$val_w")" "$val_w")
  lbl2=$(_ui_pad "$(_ui_truncate "$l2" "$lbl_w")" "$lbl_w")
  val2=$(_ui_truncate "$v2" "$val_w")
  printf "  ${C_SKY}%s${C_RESET} ${C_TEXT}%s${C_RESET}  ${C_SKY}%s${C_RESET} ${C_TEXT}%s${C_RESET}\n" "$lbl1" "$val1" "$lbl2" "$val2"
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

# Small colored pill/badge, e.g. ui_badge "ready" green
ui_badge() {
  local text="$1" color="${2:-green}"
  local c
  case "$color" in
    green)  c="$C_GREEN" ;;
    yellow) c="$C_YELLOW" ;;
    red)    c="$C_RED" ;;
    sky)    c="$C_SKY" ;;
    mauve)  c="$C_MAUVE" ;;
    *)      c="$C_OVERLAY" ;;
  esac
  printf "${c}[%s]${C_RESET}" "$text"
}

ui_divider() {
  local inner=$((UI_WIDTH - 2))
  echo -e "  ${C_SURFACE}$(printf '·%.0s' $(seq 1 "$inner"))${C_RESET}"
}

# Runtime version line with a colored dot: ui_lang "Node.js" "v22.11.0"
ui_lang() {
  local name="$1" ver="$2"
  local dot="●"
  if [ "$ver" = "not active" ] || [ -z "$ver" ]; then
    printf "  ${C_OVERLAY}%s${C_RESET} ${C_OVERLAY}%-11s${C_RESET} ${C_OVERLAY}not active${C_RESET}\n" "$dot" "$name"
  else
    printf "  ${C_GREEN}%s${C_RESET} ${C_TEXT}%-11s${C_RESET} ${C_SUBTEXT}%s${C_RESET}\n" "$dot" "$name" "$ver"
  fi
}

# Runtime availability line with [+]/[–] prefix and ✓/✗: ui_check "Node.js" true
ui_check() {
  local name="$1" ok="$2"
  local label_w=12
  local lbl
  lbl=$(_ui_pad "$(_ui_truncate "$name" "$label_w")" "$label_w")
  if [ "$ok" = "true" ]; then
    printf "  ${C_GREEN}[+]${C_RESET} ${C_TEXT}%s${C_RESET} ${C_GREEN}✓${C_RESET}\n" "$lbl"
  else
    printf "  ${C_RED}[–]${C_RESET} ${C_OVERLAY}%s${C_RESET} ${C_RED}✗${C_RESET}\n" "$lbl"
  fi
}

# Runtime availability with [+]/[–] prefix, ✓/✗ symbol, and version text:
# ui_check_ver "Node.js" true "v22.11.0"  ->  [+] Node.js  ✓  v22.11.0
ui_check_ver() {
  local name="$1" ok="$2" ver="$3"
  local label_w=11 ver_w=18
  local lbl v
  lbl=$(_ui_pad "$(_ui_truncate "$name" "$label_w")" "$label_w")
  if [ "$ok" = "true" ]; then
    v=$(_ui_truncate "$ver" "$ver_w")
    printf "  ${C_GREEN}[+]${C_RESET} ${C_TEXT}%s${C_RESET} ${C_GREEN}✓${C_RESET}  ${C_SUBTEXT}%s${C_RESET}\n" "$lbl" "$v"
  else
    printf "  ${C_RED}[–]${C_RESET} ${C_OVERLAY}%s${C_RESET} ${C_RED}✗${C_RESET}  ${C_OVERLAY}not installed${C_RESET}\n" "$lbl"
  fi
}
