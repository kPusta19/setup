#!/usr/bin/env bash
set -Eeuo pipefail

## ===========================================================
# Import common and check instance
## ===========================================================
source "${WORK_DIR}/lib/common.sh"
source "${WORK_DIR}/lib/gpu_install.sh"
source "${WORK_DIR}/lib/dev_install.sh"
preflight

## ===========================================================
# Install drivers
## ===========================================================
echo "Installing GPU drivers..."
gpu_install

## ===========================================================
# Install base packages (XOrg, UI tools, fonts)
## ===========================================================
echo "Installing base packages..."
BASE_PKGS=(
  xorg xinit                                              # XOrg base
  libinput-tools xserver-xorg-input-libinput              # XOrg controls
  bspwm sxhkd polybar dmenu rofi picom dunst starship feh # BSPWM setup
)
apt_install "${BASE_PKGS[@]}"
append_if_missing 'eval "$(starship init bash)"' ~/.bashrc

## ===========================================================
# Install fonts packages
## ===========================================================
echo "Installing fonts packages..."
FONTS_PKGS=(
  fonts-noto-core fonts-noto-extra fonts-noto-ui-core fonts-noto-color-emoji fonts-noto-mono fonts-noto-cjk
  fonts-dejavu-core
  fonts-jetbrains-mono
  fonts-font-awesome
  fonts-firacode
  fonts-liberation
  fonts-symbola
)
apt_install "${FONTS_PKGS[@]}"
run fc-cache -f

## ===========================================================
# Install theme packages
## ===========================================================
echo "Installing theme packages..."
THEME_PKGS=(
  libglib2.0-bin
  sassc gtk2-engines-murrine
  gsettings-desktop-schemas
  dconf-cli
  adwaita-icon-theme
  gnome-themes-extra
  xdg-desktop-portal
  xdg-desktop-portal-gtk
  x11-xserver-utils xsettingsd pkg-config libxcursor-dev
  wget tar
)
apt_install "${THEME_PKGS[@]}"

run mkdir -p ~/src && cd ~/src && [ ! -d "Gruvbox-GTK-Theme" ] && git clone https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme.git
run cd ~/src/Gruvbox-GTK-Theme/themes && ./install.sh -c dark -s standard --tweaks soft -t default -l

run gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
run gsettings set org.gnome.desktop.interface gtk-theme 'Gruvbox-Dark-Soft'

run mkdir -p ~/.local/share/icons && cd /tmp
run wget https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Classic.tar.xz
run tar -xf Bibata-Modern-Classic.tar.xz -C ~/.local/share/icons/
sudo ln -sfn \
  "$HOME/.local/share/icons/Bibata-Modern-Classic" \
  /usr/share/icons/Bibata-Modern-Classic

## ===========================================================
# Install audio packages
## ===========================================================
AUDIO_PKGS=(
  pipewire pipewire-audio pipewire-pulse pipewire-alsa
  wireplumber
  libspa-0.2-bluetooth
  pavucontrol
  pamixer
  playerctl
)
apt_install "${AUDIO_PKGS[@]}"
systemctl --user enable --now pipewire.socket
systemctl --user enable --now pipewire-pulse.socket
systemctl --user enable --now wireplumber.service

## ===========================================================
# Install browser packages
## ===========================================================
BROWSER_PKGS=(
  firefox-esr
)
apt_install "${BROWSER_PKGS[@]}"

## ===========================================================
# Install development environment
## ===========================================================
if ask "Install development environment?" N; then
  dev_install
fi

## ===========================================================
# Apply configs
## ===========================================================
echo "Apply configs..."
run sudo cp -r "${WORK_DIR}/configs/etc/." "/etc/"
run sudo sysctl --system

run cp -r "${WORK_DIR}/configs/.xinitrc" ~/.xinitrc
run cp -r "${WORK_DIR}/configs/.xprofile" ~/.xprofile
run cp -r "${WORK_DIR}/configs/.Xresources" ~/.Xresources

run cp -r "${WORK_DIR}/configs/.config/." ~/.config/
run chmod +x ~/.xinitrc \
  ~/.config/bspwm/bspwmrc \
  ~/.config/sxhkd/sxhkdrc \
  ~/.config/polybar/launch.sh \
  ~/.config/alacritty/generate-theme.sh

run xrdb -merge ~/.Xresources
