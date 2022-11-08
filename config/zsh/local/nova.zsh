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
  ~/.oroshi/scripts/deploy/xmodmap # Custom keys
  ~/.oroshi/config/ubuntu/18.04/keybindings.sh # App bindings
  ~/.oroshi/scripts/deploy/xbindkeys # Screen and sound
}


function baldur() {
  # okbg
  # ~/.oroshi/scripts/deploy/xbindkeys
  # cd "/home/tim/.local/share/Steam/steamapps/common/Baldur's Gate II Enhanced Edition/"
  cd "/home/tim/.local/share/Steam/steamapps/common/BGEET/"
  wine ./Baldur.exe
  # okbgu
}
# Enable Baldur Keybinding Fixes
function okbg() {
  xmodmap ~/.oroshi/config/xmodmap/local/bg.xmodmap
  ~/.oroshi/scripts/deploy/xbindkeys
}
# Disable Baldur Keyinding Fixes
function okbgu() {
  xmodmap ~/.oroshi/config/xmodmap/local/bg-cancel.xmodmap
  ~/.oroshi/scripts/deploy/xbindkeys
}

function nearinfinity() {
  cd "~/.local/share/Steam/steamapps/common/Baldur's Gate Enhanced Edition"
  java -jar NearInfinity.jar
}
