#!/usr/bin/env bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/lib" && pwd)/common.sh"

PACMAN_FILE="${DOTS_ROOT}/packages/arch/pacman.txt"
AUR_FILE="${DOTS_ROOT}/packages/arch/aur.txt"

install_pacman_packages() {
  mapfile -t packages < <(strip_package_file "$PACMAN_FILE")
  if ((${#packages[@]} == 0)); then
    warn "No hay paquetes pacman en ${PACMAN_FILE}"
    return
  fi

  log "Instalando paquetes de Arch con pacman"
  sudo pacman -Syu --needed --noconfirm "${packages[@]}"
}

install_aur_packages() {
  mapfile -t packages < <(strip_package_file "$AUR_FILE")
  if ((${#packages[@]} == 0)); then
    ok "No hay paquetes AUR requeridos"
    return
  fi

  local helper=""
  if has_cmd yay; then
    helper="yay"
  elif has_cmd paru; then
    helper="paru"
  else
    warn "Hay paquetes AUR, pero no encontré yay ni paru. Los omito por ahora."
    warn "Paquetes AUR pendientes: ${packages[*]}"
    return
  fi

  log "Instalando paquetes AUR con ${helper}"
  "${helper}" -S --needed --noconfirm "${packages[@]}"
}

enable_services() {
  log "Activando servicios base"
  sudo systemctl enable --now NetworkManager.service
  sudo systemctl enable --now bluetooth.service || warn "No pude activar bluetooth; revisa bluez si lo necesitas."

  if systemctl --user status >/dev/null 2>&1; then
    systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service || \
      warn "No pude activar todos los servicios de audio de usuario; se intentarán al iniciar sesión."
  else
    warn "systemd --user no está disponible en esta sesión; audio se activará al iniciar sesión gráfica."
  fi
}

[[ -f /etc/arch-release ]] || die "Este instalador de paquetes es para Arch/derivadas."

install_pacman_packages
install_aur_packages
enable_services

ok "Dependencias de Arch listas"
