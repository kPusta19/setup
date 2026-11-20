#!/usr/bin/env bash
set -Eeuo pipefail
SETUP_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SETUP_LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/setup"

mkdir -p "$SETUP_LOG_DIR"
if [[ -z "${SETUP_LOG_ACTIVE:-}" ]]; then
  export SETUP_LOG_ACTIVE=1
  exec > >(tee -a "$SETUP_LOG_DIR/install.log") 2>&1
fi

DRY_RUN=0
ASSUME_YES=0
VERBOSE=0

# Parses args
parse_args() {
  while (($#)); do
    case "$1" in --dry-run) DRY_RUN=1 ;; --yes | -y) ASSUME_YES=1 ;; --verbose) VERBOSE=1 ;; --help | -h) return 10 ;; *) die "Unknown option: $1" ;; esac
    shift
  done
  ((VERBOSE)) && set -x
}

# Logs INFO
info() { printf '\n[INFO] %s\n' "$*"; }

# Logs WARN
warn() { printf '\n[WARN] %s\n' "$*"; }

# Logs ERROR and exits with 1
die() {
  printf '\n[ERROR] %s\n' "$*" >&2
  exit 1
}

# Runs command
run() {
  printf '+'
  printf ' %q' "$@"
  printf '\n'
  ((DRY_RUN)) || "$@"
}

# Asks for Y/N
ask() {
  local p="$1" d="${2:-Y}" a
  if ((ASSUME_YES)); then
    [[ "$d" == Y ]]
    return
  fi
  read -r -p "$p [$d/$([[ "$d" == Y ]] && echo N || echo Y)] " a || true
  a="${a:-$d}"
  [[ "$a" =~ ^[Yy]$ ]]
}

# Chooses for variants
choose() {
  local p="$1" d="$2"
  shift 2
  local opts=("$@") a i=1
  if ((ASSUME_YES)); then
    printf '%s' "$d"
    return
  fi
  printf '\n%s\n' "$p"
  for x in "${opts[@]}"; do
    printf ' %d) %s\n' "$i" "$x"
    ((i += 1))
  done
  read -r -p "Select [default $d]: " a || true
  a="${a:-$d}"
  [[ "$a" =~ ^[0-9]+$ ]] && ((a >= 1 && a <= ${#opts[@]})) || a="$d"
  printf '%s' "$a"
}

# Checks conditions for the script
preflight() {
  [[ $EUID -ne 0 ]] || die "Run as a regular user, not root."
  command -v sudo >/dev/null || die "sudo is required."
  sudo -v
  [[ -r /etc/os-release ]] || die "Cannot identify OS."
  . /etc/os-release
  [[ "${ID:-}" == debian ]] || die "This module targets Debian."
  case "${VERSION_ID:-}" in 12 | 13) ;; *) warn "Debian ${VERSION_ID:-unknown} is not explicitly tested." ;; esac
}

# Installs apt package (pkgs=$@)
apt_install() {
  run sudo apt-get update
  run sudo apt-get install -y "$@"
}

# Appends line into file (line=$1 file=$2)
append_if_missing() {
  local line="$1"
  local file="$2"

  touch "$file"

  if ! grep -qxF -- "$line" "$file"; then
    [[ -s "$file" && -n "$(tail -c 1 "$file")" ]] && echo "" >>"$file"
    echo "$line" >>"$file"
  fi
}
