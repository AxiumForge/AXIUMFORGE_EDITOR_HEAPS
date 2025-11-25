#!/usr/bin/env bash
set -euo pipefail

# Project-local wrapper around the shared AxiumScreenshot helper.
# Uses local defaults suited for this repo.

SHARED="/Users/larsmathiasen/REPO/AxiumScreenshot/screenshot.sh"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  echo "Project screenshot wrapper; delegates to ${SHARED}"
  echo "Defaults: SHOT_DIR=${SHOT_DIR:-/Users/larsmathiasen/REPO/AxiumGST/sc}, SHOT_PREFIX=${SHOT_PREFIX:-heaps}, SHOT_MAX_DIM=${SHOT_MAX_DIM:-1920}"
  echo "All env vars supported by the shared script are forwarded (HEAPS_APP, HEAPS_DISPLAY, HEAPS_ALLOW_DISPLAY_FALLBACK, SHOT_*)."
  exit 0
fi

export SHOT_DIR="${SHOT_DIR:-/Users/larsmathiasen/REPO/AxiumGST/sc}"
export SHOT_PREFIX="${SHOT_PREFIX:-heaps}"
export SHOT_MAX_DIM="${SHOT_MAX_DIM:-1920}"
export HEAPS_APP="${HEAPS_APP:-hl,Heaps,viewer}"

exec "${SHARED}" "$@"
