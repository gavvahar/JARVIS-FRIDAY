# Shared CYAN/YELLOW/RED color vars and log/warn/err helpers, used by
# termux/install.sh and zsh/install.sh. Meant to be sourced, not executed —
# no `set -e` here, callers own their own strict-mode setting.

CYAN=$'\e[1;36m'; YELLOW=$'\e[1;33m'; RED=$'\e[1;31m'; RESET=$'\e[0m'
log()  { printf "${CYAN}[J.A.R.V.I.S.]${RESET} %s\n" "$*"; }
warn() { printf "${YELLOW}[J.A.R.V.I.S.]${RESET} %s\n" "$*"; }
err()  { printf "${RED}[J.A.R.V.I.S.]${RESET} %s\n" "$*" >&2; exit 1; }
