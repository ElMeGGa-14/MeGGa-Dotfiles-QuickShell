# edots shell bootstrap

[[ -f /etc/bash.bashrc ]] && source /etc/bash.bashrc

export EDITOR="${EDITOR:-nano}"
export VISUAL="${VISUAL:-$EDITOR}"
export PATH="$HOME/.local/bin:$PATH"

alias ll='ls -lah --color=auto'
alias gs='git status --short'
alias dots='cd "$HOME/dotfiles" 2>/dev/null || cd "$HOME"'

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi
