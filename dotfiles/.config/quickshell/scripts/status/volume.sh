#!/usr/bin/env bash

set -euo pipefail

if ! command -v pamixer >/dev/null 2>&1; then
  printf 'VOL --\n'
  exit 0
fi

if pamixer --get-mute 2>/dev/null | grep -q true; then
  printf 'VOL muted\n'
else
  printf 'VOL %s%%\n' "$(pamixer --get-volume 2>/dev/null || printf 0)"
fi
