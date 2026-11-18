#!/usr/bin/env bash
set -Eeuo pipefail
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
echo "1) UI  2) Audio  3) Bluetooth  4) All"
read -r -p "Select [1-4]: " n
case "$n" in
1) exec bash "$DIR/modules/ui/install.sh";;
2) exec bash "$DIR/modules/audio/install.sh";;
3) exec bash "$DIR/modules/bluetooth/install.sh";;
4) bash "$DIR/modules/ui/install.sh"; bash "$DIR/modules/audio/install.sh"; exec bash "$DIR/modules/bluetooth/install.sh";;
*) echo "Invalid selection" >&2; exit 2;;
esac
