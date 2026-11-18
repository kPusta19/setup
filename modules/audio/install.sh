#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/../../lib/common.sh"
parse_args "$@" || { echo "Usage: audio.sh [--dry-run] [--yes] [--verbose]"; exit 0; }
preflight
info "Installing PipeWire audio stack."
apt_install pipewire wireplumber pipewire-pulse pipewire-alsa pavucontrol pamixer
if command -v systemctl >/dev/null && [[ -n "${XDG_RUNTIME_DIR:-}" || -d "/run/user/$(id -u)" ]]; then
 if ask "Enable PipeWire user sockets now?" Y; then
  run systemctl --user daemon-reload
  run systemctl --user enable --now pipewire.socket
  run systemctl --user enable --now pipewire-pulse.socket
  if systemctl --user list-unit-files wireplumber.service 2>/dev/null | grep -q wireplumber.service; then run systemctl --user enable --now wireplumber.service; fi
 fi
else warn "No active user systemd session; services can start after login."; fi
echo "Audio module complete. Mixer: pavucontrol. Volume: pamixer -i 5 / -d 5 / -t"
