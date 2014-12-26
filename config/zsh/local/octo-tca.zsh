# Custom colors for this hostname
promptColor=(
	hostname	"071"
)

# Directories {{{
alias cdpaper="cd ~/Dropbox/perso/paperwork/"
alias cdbooks='cd ~/perso/books'
alias cdemu='cd ~/perso/emulation'
alias cdrp='cd ~/perso/roleplay/'
alias cdscenar='cd ~/perso/roleplay/scenarios/'
alias cdkiss="/var/www/java/kissihm/kissihm/src/main/webapp/resources/"
alias cdmeetups="cd /home/tca/perso/notes/meetups/"
# }}}

# Dump file to online domain
function dumptmp() {
  rsync -Pharz \
    $1 \
    galactica:./local/www/pixelastic.com/tmp.pixelastic.com
    echo "Available on http://tmp.pixelastic.com/${1:t}"
}
#
#
# Proxy {{{
function proxyup() {
  npm config set registry "http://npm.dev:4873/"
}
function proxydown() {
  npm config delete registry
}
# }}}
