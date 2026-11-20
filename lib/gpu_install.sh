#!/usr/bin/env bash
set -Eeuo pipefail

gpu_install() {
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

    if [[ "$c" == 2 ]]; then
      if apt-cache show nvidia-driver >/dev/null 2>&1; then
        if ask "Install nvidia-driver from configured repositories?" N; then
          apt_install nvidia-driver
        fi
      else
        warn "nvidia-driver unavailable; no APT sources changed."
      fi
    fi
  fi

  if [[ "$GPU" == amd ]] && apt-cache show firmware-amd-graphics >/dev/null 2>&1; then
    if ask "Install AMD firmware if available?" Y; then
      run sudo apt-get install -y firmware-amd-graphics
    fi
  fi

  if [[ "$GPU" == intel ]] && apt-cache show firmware-misc-nonfree >/dev/null 2>&1; then
    if ask "Install Intel firmware if available?" Y; then
      run sudo apt-get install -y firmware-misc-nonfree
    fi
  fi
}
