#!/usr/bin/env bash
set -euo pipefail

# ── Config ──────────────────────────────────────────────────────────
TARGET_HOST="${DEPLOY_HOST:-raspiserver}"
TARGET_USER="${DEPLOY_USER:-Schaefer}"
TARGET_PATH="${DEPLOY_PATH:-Projects/01_main/notes}"
SERVICE="${DEPLOY_SERVICE:-notes}"
# ────────────────────────────────────────────────────────────────────

REMOTE="${TARGET_USER}@${TARGET_HOST}"
REMOTE_DIR="${REMOTE}:${TARGET_PATH}"
SSH="ssh ${REMOTE}"

echo "=== 1) Build frontend ==="
( cd frontend && bun run build )

echo "=== 2) Build backend (aarch64, ReleaseSmall) ==="
( cd backend && zig build -Dtarget=aarch64-linux-gnu -Doptimize=ReleaseSmall )

echo "=== 3) Create staging directory on target ==="
$SSH "mkdir -p ${TARGET_PATH}/.deploy-staging"

echo "=== 4) Upload frontend dist → staging ==="
rsync -avz --delete frontend/dist/ "${REMOTE_DIR}/.deploy-staging/dist/"

echo "=== 5) Upload backend binary → staging ==="
scp backend/zig-out/bin/notes-server "${REMOTE_DIR}/.deploy-staging/notes-server"

echo "=== 6) Atomic swap + restart ==="
$SSH '
    set -e
    BASE="$HOME/'"${TARGET_PATH}"'"

    # Stop service
    sudo systemctl stop '"${SERVICE}"' 2>/dev/null || true

    # Swap dist
    if [ -d "${BASE}/dist" ]; then
        rm -rf "${BASE}/dist.old" 2>/dev/null || true
        mv "${BASE}/dist" "${BASE}/dist.old"
    fi
    mv "${BASE}/.deploy-staging/dist" "${BASE}/dist"

    # Swap binary
    if [ -f "${BASE}/notes-server" ]; then
        mv "${BASE}/notes-server" "${BASE}/notes-server.old" 2>/dev/null || true
    fi
    mv "${BASE}/.deploy-staging/notes-server" "${BASE}/notes-server"
    chmod +x "${BASE}/notes-server"

    # Cleanup
    rm -rf "${BASE}/.deploy-staging" "${BASE}/dist.old" "${BASE}/notes-server.old" 2>/dev/null || true

    # Start service
    sudo systemctl start '"${SERVICE}"'

    echo "Deploy complete → http://'"${TARGET_HOST}"':8014"
'

echo "=== Done ==="