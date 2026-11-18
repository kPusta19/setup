#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/../../lib/common.sh"
parse_args "$@" || { echo "Usage: ui.sh [--dry-run] [--yes] [--verbose]"; exit 0; }
preflight

GPU_INFO="$(lspci -nnk 2>/dev/null | grep -Ei -A3 'VGA compatible controller|3D controller|Display controller' || true)"
printf 'Detected graphics hardware:\\n%s\\n' "${GPU_INFO:-Not detected}"
GPU=unknown
grep -qi NVIDIA <<<"$GPU_INFO" && GPU=nvidia
grep -qi Intel <<<"$GPU_INFO" && [[ "$GPU" == unknown ]] && GPU=intel
grep -Eqi 'AMD|ATI' <<<"$GPU_INFO" && [[ "$GPU" == unknown ]] && GPU=amd
info "Graphics profile: $GPU"

if [[ "$GPU" == nvidia ]]; then
 warn "NVIDIA detected; existing driver is preserved."
 c="$(choose 'NVIDIA driver:' 1 'Keep current driver' 'Install Debian nvidia-driver' 'Do not install NVIDIA packages')"
 if [[ "$c" == 2 ]]; then if apt-cache show nvidia-driver >/dev/null 2>&1; then ask "Install nvidia-driver from configured repositories?" N && apt_install nvidia-driver; else warn "nvidia-driver unavailable; no APT sources changed."; fi; fi
fi

PKGS=(xorg xserver-xorg xinit x11-xserver-utils bspwm sxhkd polybar rofi dunst picom thunar alacritty feh fonts-dejavu fonts-font-awesome dbus-x11 libinput-tools xserver-xorg-input-libinput mesa-utils curl git unzip zsh)
[[ "$GPU" != intel && "$GPU" != amd ]] || PKGS+=(mesa-vulkan-drivers)
info "Installing UI only; audio and Bluetooth are separate."
apt_install "${PKGS[@]}"
if [[ "$GPU" == amd ]] && apt-cache show firmware-amd-graphics >/dev/null 2>&1; then ask "Install AMD firmware if available?" Y && run sudo apt-get install -y firmware-amd-graphics; fi
if [[ "$GPU" == intel ]] && apt-cache show firmware-misc-nonfree >/dev/null 2>&1; then ask "Install Intel firmware if available?" Y && run sudo apt-get install -y firmware-misc-nonfree; fi

TP=""; command -v libinput >/dev/null && TP="$(libinput list-devices 2>/dev/null | awk 'BEGIN{RS=""} /Touchpad/{print}' || true)"
if [[ -n "$TP" ]] && ask "Configure touchpad?" Y; then
 printf '%s\\n' "$TP"
 s="$(choose 'Scroll direction:' 1 'Traditional' 'Natural')"
 m="$(choose 'Scroll method:' 1 'Two-finger' 'Edge' 'Disabled')"
 t="$(choose 'Tap to click:' 1 'Enabled' 'Disabled')"
 c="$(choose 'Click method:' 1 'Clickfinger' 'Button areas')"
 natural=false; [[ "$s" == 2 ]] && natural=true
 method=twofinger; [[ "$m" == 2 ]] && method=edge; [[ "$m" == 3 ]] && method=none
 tapping=true; [[ "$t" == 2 ]] && tapping=false
 click=clickfinger; [[ "$c" == 2 ]] && click=buttonareas
 tmp="$(mktemp)"
 cat >"$tmp" <<EOF
Section "InputClass"
 Identifier "libinput touchpad"
 MatchIsTouchpad "on"
 Driver "libinput"
 Option "Tapping" "$tapping"
 Option "ClickMethod" "$click"
 Option "NaturalScrolling" "$natural"
 Option "ScrollMethod" "$method"
 Option "DisableWhileTyping" "true"
EndSection
EOF
 if ((DRY_RUN)); then cat "$tmp"; else sudo install -d -m 0755 /etc/X11/xorg.conf.d; [[ ! -e /etc/X11/xorg.conf.d/30-touchpad.conf ]] || sudo cp -a /etc/X11/xorg.conf.d/30-touchpad.conf "/etc/X11/xorg.conf.d/30-touchpad.conf.bak.$(date +%s)"; sudo install -m 0644 "$tmp" /etc/X11/xorg.conf.d/30-touchpad.conf; fi
 rm -f "$tmp"
else warn "No touchpad detected or configuration skipped."; fi

BACKUP="$HOME/.config/.backup/setup-$(date +%Y%m%d-%H%M%S)"; mkdir -p "$HOME/.config" "$BACKUP"
for name in bspwm sxhkd picom polybar rofi dunst; do
 src="$SETUP_ROOT/config/$name"; [[ -d "$src" ]] || continue
 while IFS= read -r -d '' f; do
  rel="${f#"$src/"}"; dest="$HOME/.config/$name/$rel"
  if [[ -e "$dest" ]]; then mkdir -p "$BACKUP/$name/$(dirname "$rel")"; ((DRY_RUN)) || cp -a "$dest" "$BACKUP/$name/$rel"; warn "Backed up $dest"; fi
  if ((DRY_RUN)); then echo "Would install $f -> $dest"; else mkdir -p "$(dirname "$dest")"; install -m 0644 "$f" "$dest"; fi
 done < <(find "$src" -type f ! -name launch.sh ! -name bspwmrc -print0)
done
if (( ! DRY_RUN )); then install -m 0755 "$SETUP_ROOT/config/bspwm/bspwmrc" "$HOME/.config/bspwm/bspwmrc"; install -m 0755 "$SETUP_ROOT/config/polybar/launch.sh" "$HOME/.config/polybar/launch.sh"; fi
if [[ ! -e "$HOME/.xinitrc" ]]; then
 if ((DRY_RUN)); then echo "Would create ~/.xinitrc"; else printf '%s\\n' '#!/bin/sh' 'if command -v dbus-launch >/dev/null 2>&1; then' ' exec dbus-launch --exit-with-session bspwm' 'fi' 'exec bspwm' >"$HOME/.xinitrc"; chmod +x "$HOME/.xinitrc"; fi
else warn "Existing ~/.xinitrc preserved."; fi
if (( ! DRY_RUN )) && command -v glxinfo >/dev/null; then glxinfo -B 2>/dev/null | grep -E 'OpenGL vendor|OpenGL renderer|OpenGL version' || true; fi
echo "UI module complete. Start with: startx"
