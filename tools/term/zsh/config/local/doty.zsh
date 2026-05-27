# Reload keybindings
# Doty is my Contentsquare laptop
function ok() {
  # Custom keys
  $OROSHI_ROOT/tools/keybindings/xmodmap/deploy

  # App bindings
  $OROSHI_ROOT/tools/ubuntu/22.04/keybindings/deploy

  # Keybindings that couldn't work with Ubuntu directly
  $OROSHI_ROOT/tools/keybindings/xbindkeys/deploy
}
