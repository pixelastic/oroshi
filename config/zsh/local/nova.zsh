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

alias baldur="okbg && wine \"/home/tim/.local/share/Steam/steamapps/common/Baldur's Gate II Enhanced Edition/baldur.exe\" && okbgu"
alias okbg="xmodmap ~/.oroshi/config/xmodmap/local/bg.xmodmap"
alias okbgu="xmodmap ~/.oroshi/config/xmodmap/local/bg-cancel.xmodmap"
