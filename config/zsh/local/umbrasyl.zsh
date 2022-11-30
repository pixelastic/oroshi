# Reload keybindings
# Umbrasyl is my temporary Algolia laptop
function ok() {
  # Xmodmap (keys)
  ~/.oroshi/scripts/deploy/xmodmap

  # Ubuntu (window management, apps)
  ~/.oroshi/config/ubuntu/22.04/keybindings/index

  # Xbindkey (media playback)
  ~/.oroshi/scripts/deploy/xbindkeys

  # Autokey (abbreviations, templates)
  gui autokey
}
