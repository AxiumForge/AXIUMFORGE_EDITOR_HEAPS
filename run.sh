#!/bin/bash
# Run viewer from project root (correct asset paths)
cd "$(dirname "$0")"
hl bin/viewer.hl
