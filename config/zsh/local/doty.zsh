# Reload keybindings
# Doty is my Contentsquare laptop
function ok() {
  # Custom keys
  ~/.oroshi/scripts/deploy/xmodmap 

  # App bindings
  ~/.oroshi/config/ubuntu/22.04/keybindings/index 

  # Keybindings that couldn't work with Ubuntu directly
  ~/.oroshi/scripts/deploy/xbindkeys 
}
