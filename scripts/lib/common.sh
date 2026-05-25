#!/usr/bin/env bash

set -euo pipefail

DOTS_NAME="edots"
DOTS_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
DOTS_HOME="${HOME}"
DOTS_BACKUP_DIR="${DOTS_HOME}/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

color_reset=$'\033[0m'
color_blue=$'\033[1;34m'
color_green=$'\033[1;32m'
color_yellow=$'\033[1;33m'
color_red=$'\033[1;31m'

log() {
  printf '%s::%s %s\n' "${color_blue}" "${color_reset}" "$*"
}

ok() {
  printf '%sOK%s %s\n' "${color_green}" "${color_reset}" "$*"
}

warn() {
  printf '%sWARN%s %s\n' "${color_yellow}" "${color_reset}" "$*" >&2
}

die() {
  printf '%sERROR%s %s\n' "${color_red}" "${color_reset}" "$*" >&2
  exit 1
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

confirm() {
  local prompt="${1:-Continuar?}"
  local answer
  read -r -p "${prompt} [y/N] " answer
  [[ "${answer}" == "y" || "${answer}" == "Y" || "${answer}" == "yes" || "${answer}" == "YES" ]]
}

strip_package_file() {
  local file="$1"
  sed -e 's/#.*//' -e 's/[[:space:]]*$//' -e '/^[[:space:]]*$/d' "$file"
}
