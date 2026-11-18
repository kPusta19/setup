#!/usr/bin/env bash
set -Eeuo pipefail

REPO_OWNER="kPusta19"
REPO_NAME="setup"
REPO_REF="main"

# Use current directory if the script started from the cloned repository
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"

if [[ -n "$SCRIPT_DIR" && -f "${SCRIPT_DIR}/lib/common.sh" ]]; then
    WORK_DIR="$SCRIPT_DIR"
else
    # Use temp dir and download repository archive if script started via 'curl | bash'
    for cmd in curl tar; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo "Missed '$cmd' util" >&2
            exit 1
        fi
    done

    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT

    ARCHIVE_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/${REPO_REF}.tar.gz"
    echo "Downloading ${REPO_OWNER}/${REPO_NAME} (${REPO_REF})..."

    curl -fsSL "$ARCHIVE_URL" | tar -xz -C "$TMP_DIR"
    WORK_DIR="${TMP_DIR}/${REPO_NAME}-${REPO_REF}"
    stat ${WORK_DIR}
fi

export WORK_DIR
bash "${WORK_DIR}/setup.sh" </dev/tty

