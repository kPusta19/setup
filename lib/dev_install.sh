#!/usr/bin/env bash
set -Eeuo pipefail

dev_install() {
  echo "Development environment installing..."
  DEV_PKGS=(
    build-essential pkg-config libssl-dev lldb-19 git curl # base
    shellcheck shfmt npm                                   # bash
  )
  apt_install "${DEV_PKGS[@]}"

  ## ==================================
  # Rust
  ## ===================================
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
  source "$HOME/.cargo/env"
  run rustup component add rust-analyzer rustfmt clippy

  ## ==================================
  # Golang
  ## ===================================
  ARCH="$(dpkg --print-architecture | sed 's/amd64/amd64/;s/arm64/arm64/')" &&
    VERSION="$(curl -fsSL https://go.dev/VERSION?m=text | head -n1)" &&
    curl -fsSLo /tmp/go.tar.gz "https://go.dev/dl/${VERSION}.linux-${ARCH}.tar.gz" && sudo rm -rf /usr/local/go &&
    sudo tar -C /usr/local -xzf /tmp/go.tar.gz && rm /tmp/go.tar.gz &&
    append_if_missing 'export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"' ~/.bashrc

  run go install golang.org/x/tools/gopls@latest
  run go install golang.org/x/tools/cmd/goimports@latest

  ## ==================================
  # Python
  ## ===================================
  PY_PKGS=(pipx)
  apt_install "${PY_PKGS[@]}"
  run pipx ensurepath
  run pipx install basedpyright
  run pipx install ruff

  ## ==================================
  # JS/TS
  ## ===================================
  JS_TS_PKGS=(nodejs npm)
  # apt_install "${JS_TS_PKGS[@]}"
  LATEST="$(git ls-remote --tags --refs https://github.com/nvm-sh/nvm.git 'v*' |
    awk -F/ '{print $NF}' | sort -V | tail -n1)"
  run curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${LATEST}/install.sh" | bash

  source ~/.bashrc
  run nvm install --lts

  run npm install -g typescript typescript-language-server prettier

  ## ==================================
  # Editor (Helix)
  ## ===================================
  run mkdir -p ~/src && cd ~/src && [ ! -d "helix" ] && git clone https://github.com/helix-editor/helix
  run cd ~/src/helix && cargo install \
    --profile opt \
    --config 'build.rustflags="-C target-cpu=native"' \
    --path helix-term \
    --locked
  append_if_missing 'export HELIX_RUNTIME=~/src/helix/runtime' ~/.bashrc
  run hx --grammar fetch && hx --grammar build
}
