#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/../../lib/common.sh"
parse_args "$@" || { echo "Usage: bluetooth.sh [--dry-run] [--yes] [--verbose]"; exit 0; }
preflight
info "Installing BlueZ and Blueman."
apt_install bluez blueman rfkill
if command -v systemctl >/dev/null && ask "Enable and start bluetooth.service?" Y; then run sudo systemctl enable --now bluetooth.service; fi
echo "Bluetooth module complete. GUI: blueman-manager; CLI: bluetoothctl"
