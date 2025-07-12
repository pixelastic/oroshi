# Reload keybindings
# Vorugal is the X1 Carbon 12th generation
function ok() {
  # Reload the custom keyboard
  ~/.oroshi/scripts/deploy/keybindings/xkb

  # Reload Gnome keybindings
  ~/.oroshi/scripts/deploy/ubuntu/24.04/keybindings/basic
  ~/.oroshi/scripts/deploy/ubuntu/24.04/keybindings/windows
  ~/.oroshi/scripts/deploy/ubuntu/24.04/keybindings/workspaces
  ~/.oroshi/scripts/deploy/ubuntu/24.04/keybindings/custom

}

alias loial=~/local/www/projects/loial/local/display
