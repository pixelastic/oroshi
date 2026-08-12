# CONFIG
# Nova is my first Algolia Laptop, still using it.
# Nova is running Ubuntu 18.04
# BAT theme was called ansi-dark
export BAT_THEME="ansi-dark"

# Dump file to online domain
function dumptmp() {
  rsync -Pharz \
    $1 \
    pixelastic:./local/www/tmp.pixelastic.com/share
  echo "Available on http://tmp.pixelastic.com/share/${1:t}"
}
function ok() {
  # Reload keybindings
  $OROSHI_ROOT/tools/keybindings/xmodmap/deploy               # Custom keys
  $OROSHI_ROOT/tools/ubuntu/18.04/keybindings/deploy           # App bindings
}

function baldur() {
  # okbg
  # cd "/home/tim/.local/share/Steam/steamapps/common/Baldur's Gate II Enhanced Edition/"
  cd "/home/tim/.local/share/Steam/steamapps/common/BGEET/" || return
  wine ./Baldur.exe
  # okbgu
}
# Enable Baldur Keybinding Fixes
function okbg() {
  xmodmap $OROSHI_ROOT/tools/keybindings/xmodmap/config/local/bg.xmodmap
}
# Disable Baldur Keyinding Fixes
function okbgu() {
  xmodmap $OROSHI_ROOT/tools/keybindings/xmodmap/config/local/bg-cancel.xmodmap
}

function nearinfinity() {
  cd "$HOME/.local/share/Steam/steamapps/common/Baldur's Gate Enhanced Edition" || return
  java -jar NearInfinity.jar
}
