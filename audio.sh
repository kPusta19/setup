#!/usr/bin/env bash
set -Eeuo pipefail
REPO="${BSPWM_REPO:-kPusta19/setup}"
BRANCH="${BSPWM_BRANCH:-main}"
MODULE="audio"
URL="https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
for c in curl tar; do command -v "$c" >/dev/null || { echo "Missing dependency: $c" >&2; exit 1; }; done
curl -fLsS --retry 3 --connect-timeout 15 "$URL" -o "$TMP/repo.tar.gz"
tar -xzf "$TMP/repo.tar.gz" -C "$TMP"
DIR="$(find "$TMP" -mindepth 1 -maxdepth 1 -type d | head -n1)"
[[ -f "$DIR/modules/$MODULE/install.sh" ]] || { echo "Module not found: $MODULE" >&2; exit 1; }
exec bash "$DIR/modules/$MODULE/install.sh" "$@"
