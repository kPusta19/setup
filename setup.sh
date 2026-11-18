#!/usr/bin/env bash
set -Eeuo pipefail

# Import common and check instance
source "${WORK_DIR}/lib/common.sh"
source "${WORK_DIR}/lib/gpu_drivers.sh"
preflight

# Install drivers
gpu_install

# Install base packages (XOrg, UI tools, fonts)
info "Installing base packages..."
BASE_PKGS=(
    xorg xinit # XOrg base
    libinput xserver-xorg-input-libinput # XOrg controls
)
apt_install "${BASE_PKGS[@]}"

# Apply configs
info "Apply configs..."
run cp -r "${WORK_DIR}/configs/.xinitrc" "~/xinitrc"
run cp -r "${WORK_DIR}/configs/.config" "~/.config"

run cp -r "${WORK_DIR}/configs/xorg.conf.d" "/etc/X11/xorg.conf.d"

run cp -r "${WORK_DIR}/configs/sysctl.d" "/etc/sysctl.d"
run sysctl --system