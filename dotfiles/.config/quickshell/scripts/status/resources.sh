#!/usr/bin/env bash

set -euo pipefail

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/edots"
state_file="${state_dir}/cpu"
mkdir -p "$state_dir"

read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
idle_all=$((idle + iowait))
non_idle=$((user + nice + system + irq + softirq + steal))
total=$((idle_all + non_idle))

if [[ -f "$state_file" ]]; then
  read -r prev_total prev_idle < "$state_file" || true
else
  prev_total="$total"
  prev_idle="$idle_all"
fi

total_diff=$((total - prev_total))
idle_diff=$((idle_all - prev_idle))
if ((total_diff > 0)); then
  cpu=$((100 * (total_diff - idle_diff) / total_diff))
else
  cpu=0
fi

printf '%s %s\n' "$total" "$idle_all" > "$state_file"

mem_total="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"
mem_avail="$(awk '/MemAvailable/ {print $2}' /proc/meminfo)"
mem_used=$((mem_total - mem_avail))
mem=$((100 * mem_used / mem_total))

printf 'CPU %s%%  RAM %s%%\n' "$cpu" "$mem"
