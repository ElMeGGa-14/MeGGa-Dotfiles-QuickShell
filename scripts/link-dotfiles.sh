#!/usr/bin/env bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/lib" && pwd)/common.sh"

DOTFILES_DIR="${DOTS_ROOT}/dotfiles"
MODE="link"
FORCE="false"
DRY_RUN="false"

while (($#)); do
  case "$1" in
    --copy) MODE="copy" ;;
    --force) FORCE="true" ;;
    --dry-run) DRY_RUN="true" ;;
    *) die "Opción no reconocida para link-dotfiles: $1" ;;
  esac
  shift
done

backup_target() {
  local target="$1"
  mkdir -p "$DOTS_BACKUP_DIR"
  local rel="${target#"${DOTS_HOME}/"}"
  mkdir -p "${DOTS_BACKUP_DIR}/$(dirname "$rel")"
  mv "$target" "${DOTS_BACKUP_DIR}/${rel}"
}

install_one() {
  local source="$1"
  local rel="${source#"${DOTFILES_DIR}/"}"
  local target="${DOTS_HOME}/${rel}"

  if [[ "$DRY_RUN" == "true" ]]; then
    printf 'would install: ~/%s -> %s\n' "$rel" "$source"
    return
  fi

  mkdir -p "$(dirname "$target")"

  if [[ -L "$target" ]]; then
    local current
    current="$(readlink "$target")"
    if [[ "$current" == "$source" ]]; then
      ok "Ya enlazado: ~/${rel}"
      return
    fi
    if [[ "$FORCE" == "true" ]]; then
      rm "$target"
    else
      backup_target "$target"
    fi
  elif [[ -e "$target" ]]; then
    if [[ "$FORCE" == "true" ]]; then
      rm -rf "$target"
    else
      backup_target "$target"
    fi
  fi

  if [[ "$MODE" == "copy" ]]; then
    cp -a "$source" "$target"
  else
    ln -s "$source" "$target"
  fi
  ok "Instalado: ~/${rel}"
}

[[ -d "$DOTFILES_DIR" ]] || die "No existe ${DOTFILES_DIR}"

if [[ "$DRY_RUN" == "true" ]]; then
  log "Simulando instalación de dotfiles en modo ${MODE}"
else
  log "Instalando dotfiles en modo ${MODE}"
fi
while IFS= read -r -d '' file; do
  install_one "$file"
done < <(find "$DOTFILES_DIR" -type f -print0 | sort -z)

if [[ -d "$DOTS_BACKUP_DIR" ]]; then
  warn "Se hicieron backups en ${DOTS_BACKUP_DIR}"
fi

if [[ "$DRY_RUN" == "true" ]]; then
  ok "Simulación de dotfiles terminada"
else
  ok "Dotfiles instalados"
fi
