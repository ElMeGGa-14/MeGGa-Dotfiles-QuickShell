# edots: Hyprland + Quickshell starter

Dotfiles iniciales para una instalación limpia de Arch/derivadas con Hyprland y Quickshell.

La idea no es que esto sea "la configuración final", sino una base bonita, funcional y fácil de editar: barra con workspaces, hora, clima, red, CPU/RAM, volumen, batería, system tray, calendario, panel rápido y menú de energía.

## Instalación rápida

Desde una TTY limpia:

```bash
git clone https://github.com/TU_USUARIO/TU_REPO.git ~/dotfiles
cd ~/dotfiles
./install.sh
Hyprland
```

Desde una sesión Hyprland ya existente:

```bash
cd ~/dotfiles
./install.sh --skip-packages
hyprctl reload
qs -d
```

Para revisar sin tocar tu sistema:

```bash
./install.sh --dry-run
```

El instalador enlaza los archivos hacia tu `$HOME`. Si ya existe una config, la mueve a `~/.dotfiles-backup/FECHA/`.

## Estructura

```text
dotfiles/
  .config/hypr/          Hyprland, keybinds, autostart, lock, idle, wallpaper
  .config/quickshell/    Barra, dashboard, calendario y scripts de estado
  .config/edots/         Variables fáciles de cambiar
  .config/kitty/         Terminal
  .config/fuzzel/        Launcher
  .config/mako/          Notificaciones
  .local/bin/            Scripts: screenshot, clipboard, wallpaper
packages/arch/           Dependencias pacman/AUR
scripts/                 Instalador y enlace de dotfiles
```

## Primeras cosas que editaría

- `dotfiles/.config/edots/config.env`: ciudad del clima e interfaz de red fija si la quieres.
- `dotfiles/.config/hypr/conf/monitors.conf`: resolución, escala y posición de monitores.
- `dotfiles/.config/hypr/conf/input.conf`: teclado `us,latam` y cambio con `Alt+Shift`.
- `dotfiles/.config/quickshell/shell.qml`: colores, módulos y comportamiento de la barra.

## Atajos principales

| Atajo | Acción |
| --- | --- |
| `Super + Enter` | Terminal |
| `Super + Space` | Launcher |
| `Super + C` | Dashboard/calendario |
| `Super + Q` | Cerrar ventana |
| `Super + Shift + Q` | Menú de energía |
| `Super + V` | Historial de portapapeles |
| `Print` | Captura de área |
| `Super + Print` | Captura completa |
| `Super + 1..0` | Cambiar workspace |
| `Super + Shift + 1..0` | Mover ventana a workspace |

## Comandos útiles

```bash
hyprctl reload
qs -d
qs ipc call shell toggleDashboard
qs ipc call shell togglePower
edots-screenshot edit
edots-wallpaper ~/Pictures/wallpaper.png
```

## Notas

- El soporte automático de dependencias está pensado para Arch Linux y derivadas.
- Quickshell se instala desde `extra` en Arch moderno, así que esta base no depende de AUR.
- Para subirlo a GitHub, renombra el repo como quieras y cambia la URL del `git clone` en este README.
