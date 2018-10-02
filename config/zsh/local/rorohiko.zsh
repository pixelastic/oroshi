# Custom colors for this hostname
promptColor=(
	hostname	"248"
)

# Directories {{{
alias cdbooks='cd ~/Dropbox/backup/books'
alias cdrp='cd ~/Dropbox/backup/roleplay/'
alias cdscenar='cd ~/Dropbox/backup/roleplay/scenarios/'
# }}}

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
