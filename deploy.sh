#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PI_USER="${DEPLOY_USER:-Schaefer}"
PI_HOST="${DEPLOY_HOST:-raspiserver}"
TARGET_DIR="/var/www/notes/"

echo "[1/2] Building frontend..."
cd "${SCRIPT_DIR}/frontend"
bun run build

echo "[2/2] Syncing dist/ to ${PI_USER}@${PI_HOST}:${TARGET_DIR}..."
rsync -avz --delete "${SCRIPT_DIR}/frontend/dist/" "${PI_USER}@${PI_HOST}:${TARGET_DIR}"

echo "✓ Deploy complete (static via Caddy file_server)."
