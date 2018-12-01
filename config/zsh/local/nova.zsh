# Oroshi {{{
# Reload keybings for this OS
function ok() {
  ~/.oroshi/scripts/deploy/xmodmap
  ~/.oroshi/scripts/deploy/xbindkeys
  source ~/.oroshi/config/ubuntu/18.04/windows.sh
}
# }}}

# Dump file to online domain
function dumptmp() {
  rsync -Pharz \
    $1 \
    pixelastic:./local/www/tmp.pixelastic.com/share
    echo "Available on http://tmp.pixelastic.com/share/${1:t}"
}

function baldur() {
  okbg
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

