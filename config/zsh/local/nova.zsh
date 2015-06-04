# Custom colors for this hostname
promptColor=(
	hostname	"067"
)

# Directories {{{
alias cdbooks='cd ~/perso/books'
alias cdemu='cd ~/perso/emulation'
alias cdrp='cd ~/perso/roleplay/'
alias cdscenar='cd ~/perso/roleplay/scenarios/'
# }}}

# Music {{{
alias play-coffee='mplayer ~/perso/music/nature/Coffitivity/*.mp3'
alias play-rain='mplayer ~/perso/music/nature/Rain/*.mp3'
alias play-nogg='mplayer ~/perso/music/soundtracks/D/Dopefish/*.mp3'
alias play-soundtrack='mplayer ~/perso/music/misc/*.mp3'
alias play-buddha='play-random-dir ~/perso/music/music/B/Buddha\ Bar'
alias play-peuple='play-random-dir ~/perso/music/music/P/Peuple*'
function play-random-dir() {
  cd "$1"

  local randomPath
  randomPath=$(\ls . | shuf -n 1)
  mplayer "./${randomPath}/"**/*.mp3
}
# }}}

# Oroshi {{{
# Reload keybings for this OS
function ok() {
  for file in ~/.oroshi/config/ubuntu/15.04/keybindings/*.sh; do
    source $file
  done
}
# }}}

# Dump file to online domain
function dumptmp() {
  rsync -Pharz \
    $1 \
    galactica:./local/www/pixelastic.com/tmp.pixelastic.com
    echo "Available on http://tmp.pixelastic.com/${1:t}"
}

alias hipchat-dnd='watch -n 300 ~/local/tmp/hipchat/dnd'
alias bloomberg-sync='rcp --exclude=.gitignore --exclude=json --exclude=sitemaps --exclude=_cache ./* scrapper:bloomberg'
