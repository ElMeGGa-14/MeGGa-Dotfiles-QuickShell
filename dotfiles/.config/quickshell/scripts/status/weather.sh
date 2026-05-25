#!/usr/bin/env bash

set -euo pipefail

config="${XDG_CONFIG_HOME:-$HOME/.config}/edots/config.env"
[[ -f "$config" ]] && source "$config"

location="${EDOTS_WEATHER_LOCATION:-}"
units="${EDOTS_WEATHER_UNITS:-m}"

encoded="${location// /%20}"
url="https://wttr.in/${encoded}?format=%t|%C&${units}"

if ! out="$(curl -fsS --max-time 4 "$url" 2>/dev/null)"; then
  printf 'Clima --\n'
  exit 0
fi

temp="${out%%|*}"
desc="${out#*|}"
desc="${desc%%,*}"
printf '%s %s\n' "$temp" "$desc"
