#!/usr/bin/env bash

set -euo pipefail

config="${XDG_CONFIG_HOME:-$HOME/.config}/edots/config.env"
[[ -f "$config" ]] && source "$config"

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/edots"
state_file="${state_dir}/network-speed"
mkdir -p "$state_dir"

iface="${EDOTS_NET_INTERFACE:-}"
if [[ -z "$iface" ]]; then
  iface="$(ip route get 1.1.1.1 2>/dev/null | awk '{for (i=1; i<=NF; i++) if ($i == "dev") {print $(i+1); exit}}')"
fi

if [[ -z "$iface" || ! -r "/sys/class/net/${iface}/statistics/rx_bytes" ]]; then
  printf 'NET --\n'
  exit 0
fi

rx="$(cat "/sys/class/net/${iface}/statistics/rx_bytes")"
tx="$(cat "/sys/class/net/${iface}/statistics/tx_bytes")"
now="$(date +%s)"

format_rate() {
  local bytes="$1"
  awk -v b="$bytes" 'BEGIN {
    if (b < 1024) printf "%.0f B/s", b;
    else if (b < 1048576) printf "%.1f KB/s", b / 1024;
    else printf "%.1f MB/s", b / 1048576;
  }'
}

if [[ -f "$state_file" ]]; then
  read -r prev_iface prev_rx prev_tx prev_now < "$state_file" || true
else
  prev_iface=""
  prev_rx="$rx"
  prev_tx="$tx"
  prev_now="$now"
fi

if [[ "$prev_iface" != "$iface" ]]; then
  prev_rx="$rx"
  prev_tx="$tx"
  prev_now="$now"
fi

dt=$((now - prev_now))
((dt <= 0)) && dt=1

down=$(((rx - prev_rx) / dt))
up=$(((tx - prev_tx) / dt))
((down < 0)) && down=0
((up < 0)) && up=0

printf '%s %s  %s %s\n' "DL" "$(format_rate "$down")" "UP" "$(format_rate "$up")"
printf '%s %s %s %s\n' "$iface" "$rx" "$tx" "$now" > "$state_file"
