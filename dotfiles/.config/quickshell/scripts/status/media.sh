#!/usr/bin/env bash

set -euo pipefail

if ! command -v playerctl >/dev/null 2>&1; then
  exit 0
fi

status="$(playerctl status 2>/dev/null || true)"
[[ "$status" == "Playing" || "$status" == "Paused" ]] || exit 0

artist="$(playerctl metadata artist 2>/dev/null || true)"
title="$(playerctl metadata title 2>/dev/null || true)"
text="${artist:+${artist} - }${title}"
printf '%s\n' "${text:0:64}"
