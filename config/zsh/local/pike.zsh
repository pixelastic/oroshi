# CONFIG
# Nova is running Ubuntu 20.04
# BAT theme was called ansi-dark
export BAT_THEME="ansi-dark"

function ok() {
  ~/.oroshi/scripts/deploy/xmodmap # Custom keys
  ~/.oroshi/config/ubuntu/20.04/keybindings/index.zsh # App bindings
  ~/.oroshi/scripts/deploy/xbindkeys # Screen and sound
}

