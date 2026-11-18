#!/usr/bin/env bash
set -Eeuo pipefail

# Import common and check instance
source "${WORK_DIR}/lib/common.sh"
source "${WORK_DIR}/lib/gpu_drivers.sh"
preflight

# Install drivers

gpu_install

# Install base packages (XOrg, UI tools, fonts)
BASE_PKGS=(
    xorg xinit # XOrg base
    libinput xserver-xorg-input-libinput # XOrg controls
)
apt_install "${BASE_PKGS[@]}"

# Apply configs
cp -r "${WORK_DIR}/configs/.xinitrc" "~/xinitrc"
cp -r "${WORK_DIR}/configs/.config" "~/.config"

cp -r "${WORK_DIR}/configs/xorg.conf.d" "/etc/X11/xorg.conf.d"