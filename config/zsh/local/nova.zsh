# Custom colors for this hostname
promptColor=(
	hostname	"067"
)

# Directories {{{
alias cdbooks='cd ~/Dropbox/backup/books'
alias cdemu='cd ~/perso/emulation'
alias cdrp='cd ~/Dropbox/backup/roleplay/'
alias cdscenar='cd ~/Dropbox/backup/roleplay/scenarios/'
# }}}

# Music {{{
alias play-coffee='mplayer -ao sdl ~/perso/music/nature/Coffitivity/*.mp3'
alias play-rain='mplayer -ao sdl ~/perso/music/nature/Rain/*.mp3'
alias play-nogg='mplayer -ao sdl ~/perso/music/soundtracks/D/Dopefish/*.mp3'
alias play-soundtrack='mplayer -ao sdl --shuffle ~/perso/music/soundtracks/misc/*.mp3'
alias play-buddha='play-random-dir ~/perso/music/music/B/Buddha\ Bar'
alias play-chill='play-random-dir ~/perso/music/music/A/'
alias play-peuple='play-random-dir ~/perso/music/music/P/Peuple*'
alias play-oakenfold='play-random-dir ~/perso/music/music/P/Paul*'
alias play-fun='mplayer --shuffle ~/perso/music/misc/{fun,nz}/*'
function play-random-dir() {
  cd "$1"

  local randomPath
  randomPath=$(\ls . | shuf -n 1)
  mplayer -ao sdl "./${randomPath}/"**/*.mp3
}
# }}}

# Oroshi {{{
# Reload keybings for this OS
function ok() {
  ~/.oroshi/scripts/deploy/xmodmap
  source ~/.oroshi/private/config/ubuntu/nova/keybindings/windows.sh
  source ~/.oroshi/private/config/ubuntu/nova/keybindings/custom.sh
  source ~/.oroshi/private/config/ubuntu/nova/keybindings/media.sh
}
# }}}

# Dump file to online domain
function dumptmp() {
  rsync -Pharz \
    $1 \
    galactica:./local/www/pixelastic.com/tmp.pixelastic.com
    echo "Available on http://tmp.pixelastic.com/${1:t}"
}
