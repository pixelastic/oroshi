# Reload keybindings
# Vorugal is the X1 Carbon 12th generation
function ok() {
  # Reload the custom keyboard
  $OROSHI_ROOT/tools/keybindings/xkb/deploy

  # Reload Gnome keybindings
  $OROSHI_ROOT/tools/ubuntu/24.04/keybindings/basic
  $OROSHI_ROOT/tools/ubuntu/24.04/keybindings/windows
  $OROSHI_ROOT/tools/ubuntu/24.04/keybindings/workspaces
  $OROSHI_ROOT/tools/ubuntu/24.04/keybindings/custom

}

alias loial=~/local/www/projects/loial/local/display

function dumptmp() {
  rsync -Pharz \
    $1 \
    pixelastic:./local/www/tmp.pixelastic.com/share
  echo "Available on http://tmp.pixelastic.com/share/${1:t}"
}
