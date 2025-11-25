#!/usr/bin/env bash
set -euo pipefail

# Bound screenshot helper for the Heaps app window only.
# Default process name is "Heaps"; override with HEAPS_APP env var.

APP_NAME="${HEAPS_APP:-Heaps}"
OUT_DIR="/Users/larsmathiasen/REPO/AXIUMFORGE_EDITOR_HEAPS/sc" # forced output dir
STAMP="$(date +"%Y%m%d-%H%M%S")"
OUT_FILE="${OUT_DIR}/heaps-${STAMP}.png"

mkdir -p "${OUT_DIR}"

if ! pgrep -x "${APP_NAME}" >/dev/null 2>&1; then
  echo "Process not running: ${APP_NAME}" >&2
  exit 1
fi

# Grab the first window id of the Heaps process
WIN_ID="$(osascript -e 'tell application "System Events" to get the id of first window of process "'"${APP_NAME}"'"' 2>/dev/null || true)"
if [[ -z "${WIN_ID}" ]]; then
  echo "No window id found for process: ${APP_NAME}" >&2
  exit 1
fi

echo "Capturing window ${WIN_ID} from process ${APP_NAME} -> ${OUT_FILE}"
screencapture -x -l "${WIN_ID}" "${OUT_FILE}"
echo "Saved screenshot: ${OUT_FILE}"
