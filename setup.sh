#!/usr/bin/env bash
set -Eeuo pipefail

# Import common and check instance
source "${WORK_DIR}/lib/common.sh"
source "${WORK_DIR}/lib/gpu_drivers.sh"
preflight

# Install drivers
echo "Installing GPU drivers..."
gpu_install

# Install base packages (XOrg, UI tools, fonts)
echo "Installing base packages..."
BASE_PKGS=(
    xorg xinit # XOrg base
    libinput-tools xserver-xorg-input-libinput # XOrg controls
    bspwm sxhkd polybar dmenu rofi picom dunst # BSPWM setup
)
apt_install "${BASE_PKGS[@]}"

# Install fonts packages
echo "Installing fonts packages..."
FONTS_PKGS=(
    fonts-noto-core fonts-noto-extra fonts-noto-ui-core fonts-noto-color-emoji fonts-noto-mono fonts-noto-cjk
    fonts-dejavu-core
    fonts-jetbrains-mono
    fonts-font-awesome
    fonts-firacode
    fonts-liberation
    fonts-symbola
    fonts-nerd-symbols
)
apt_install "${FONTS_PKGS}"
run fc-cache -f

# Apply configs
echo "Apply configs..."
run sudo cp -r "${WORK_DIR}/configs/etc/." "/etc/"
run sudo sysctl --system

run cp -r "${WORK_DIR}/configs/.xinitrc" ~/.xinitrc
run cp -r "${WORK_DIR}/configs/.config/." ~/.config/
run chmod +x ~/.xinitrc \
    ~/.config/bspwm/bspwmrc \
    ~/.config/sxhkd/sxhkdrc \
    ~/.config/polybar/launch.sh \
    ~/.config/alacritty/generate-theme.sh


