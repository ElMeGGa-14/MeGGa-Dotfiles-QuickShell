#!/usr/bin/env bash

set -euo pipefail

bat=""
for path in /sys/class/power_supply/BAT*; do
  [[ -d "$path" ]] && bat="$path" && break
done

if [[ -z "$bat" ]]; then
  printf 'AC\n'
  exit 0
fi

capacity="$(cat "$bat/capacity" 2>/dev/null || printf '0')"
status="$(cat "$bat/status" 2>/dev/null || printf 'Unknown')"
case "$status" in
  Charging) label="CHG" ;;
  Discharging) label="BAT" ;;
  Full) label="FULL" ;;
  *) label="BAT" ;;
esac

printf '%s %s%%\n' "$label" "$capacity"
