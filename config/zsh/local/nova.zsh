# Dump file to online domain
function dumptmp() {
  rsync -Pharz \
    $1 \
    pixelastic:./local/www/tmp.pixelastic.com/share
    echo "Available on http://tmp.pixelastic.com/share/${1:t}"
}

function baldur() {
  okbg
  ~/.oroshi/scripts/deploy/xbindkeys
  cd "/home/tim/.local/share/Steam/steamapps/common/Baldur's Gate II Enhanced Edition/"
  wine ./baldur.exe
  okbgu
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

