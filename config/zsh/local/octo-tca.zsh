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

# Synchronize stuff {{{
alias belette-sync-ebooks="ebook-sync ~/perso/books /media/tca/BELETTE/Books"
alias belette-sync-notes="update-dir ~/perso/notes /media/tca/BELETTE/notes"
alias belette-sync-roleplay="update-dir ~/perso/roleplay /media/tca/BELETTE/roleplay"
alias belette-sync-comics="update-dir /media/tca/armor/comics /media/tca/BELETTE/Comics"
alias doxie-extract="doxie-extract /media/tca/DOXIE/DCIM/ ~/perso/pictures/tmp/"
alias dingoo-sync="~/perso/emulation/devices/dingoo/tools/dingoo-sync /media/tca/dingoo"
alias gcw-sync="~/perso/emulation/devices/gcw/tools/gcw-sync gcwzero"
alias wii-sync="~/perso/emulation/devices/wii/tools/wii-sync /media/tca/WII"
alias fairphone-extract="camera-extract /media/tca/FAIRPHONE/DCIM ~/perso/pictures/fairphone"
alias fairphone-sync-audio="update-dir ~/Dropbox/perso/config/audio /media/tca/FAIRPHONE/media/audio"
alias fairphone-sync-ebooks="ebook-sync ~/perso/books /media/tca/FAIRPHONE/books"
alias fairphone-sync-notes="update-dir ~/perso/notes/ /media/tca/FAIRPHONE/notes"
alias fairphone-sync-roleplay="update-dir ~/perso/roleplay /media/tca/FAIRPHONE/roleplay"
alias michel-extract="camera-extract /media/tca/MICHEL/ ~/perso/pictures"
alias sansa-sync-misc="music-sync ~/local/mnt/serenity/music/misc /media/tca/0123-4567 sansa"
alias sansa-sync-music="music-sync ~/local/mnt/serenity/music/music /media/tca/SANSA-SD sansa-sd"
alias sansa-sync-nature="music-sync ~/local/mnt/serenity/music/nature /media/tca/0123-4567 sansa"
alias sansa-sync-podcasts="music-sync ~/local/mnt/serenity/music/podcasts /media/tca/0123-4567 sansa"
alias sansa-sync-soundtracks="music-sync ~/local/mnt/serenity/music/soundtracks /media/tca/SANSA-SD sansa-sd"
alias serenity-sync-pictures="picture-sync ~/perso/pictures/ ~/local/mnt/serenity/perso/"
alias dropbox-sync-pictures="mv ~/Dropbox/perso/misc/pictures/fairphone/* ~/perso/pictures/tmp/"
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
