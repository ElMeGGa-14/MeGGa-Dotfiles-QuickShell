#!/usr/bin/env bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/scripts/lib" && pwd)/common.sh"

SKIP_PACKAGES="false"
MODE="link"
FORCE="false"
DRY_RUN="false"

usage() {
  cat <<'EOF'
Uso: ./install.sh [opciones]

Opciones:
  --skip-packages  Solo instala/enlaza dotfiles; no toca pacman.
  --copy           Copia archivos en vez de enlazarlos.
  --force          Reemplaza archivos existentes sin backup.
  --dry-run        Muestra qué se instalaría sin cambiar archivos ni paquetes.
  -h, --help       Muestra esta ayuda.

Instalación recomendada desde TTY:
  git clone https://github.com/TU_USUARIO/TU_REPO.git ~/dotfiles
  cd ~/dotfiles
  ./install.sh
  Hyprland
EOF
}

while (($#)); do
  case "$1" in
    --skip-packages) SKIP_PACKAGES="true" ;;
    --copy) MODE="copy" ;;
    --force) FORCE="true" ;;
    --dry-run) DRY_RUN="true" ;;
    -h|--help) usage; exit 0 ;;
    *) die "Opción no reconocida: $1" ;;
  esac
  shift
done

log "Preparando ${DOTS_NAME} desde ${DOTS_ROOT}"

if [[ "$DRY_RUN" == "true" ]]; then
  warn "Dry-run activo: no instalaré paquetes."
elif [[ "$SKIP_PACKAGES" != "true" ]]; then
  if [[ -f /etc/arch-release ]]; then
    "${DOTS_ROOT}/scripts/install-packages-arch.sh"
  else
    warn "Por ahora solo instalé dependencias automáticamente en Arch/derivadas."
    warn "Usa packages/arch/pacman.txt como referencia para otra distro."
  fi
fi

link_args=()
[[ "$MODE" == "copy" ]] && link_args+=(--copy)
[[ "$FORCE" == "true" ]] && link_args+=(--force)
[[ "$DRY_RUN" == "true" ]] && link_args+=(--dry-run)
"${DOTS_ROOT}/scripts/link-dotfiles.sh" "${link_args[@]}"

if has_cmd xdg-user-dirs-update; then
  xdg-user-dirs-update || true
fi

if [[ "$DRY_RUN" == "true" ]]; then
  ok "Simulación terminada"
else
  ok "Instalación terminada"
  printf '\nSiguiente paso: inicia Hyprland o recarga tu sesión actual.\n'
  printf 'Dentro de Hyprland puedes recargar con: hyprctl reload && qs -d\n'
fi
