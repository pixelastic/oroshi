# Custom colors for this hostname
promptColor=(
	hostname	"133"
)
# Private aliases
source ~/.oroshi/private/config/zsh/local/eddie.zsh
# Directories {{{
alias cdb='cd ~/Documents/Blog/'
alias cdbooks='cd ~/Documents/books'
alias cdd='cd ~/Documents/documentation/'
alias cdemu='cd ~/Documents/emulation'
alias cdm='cd ~/Documents/Movies/'
alias cdp='cd ~/Photos'
alias cdrp='cd ~/Documents/roleplay/'
alias cdscenar='cd ~/Documents/roleplay/scenarios/'
alias cdsov='cd ~/local/tmp/sov/'
alias cdlbc="~/Dropbox/tim/paperwork/2013-03-06\ -\ Vente\ leboncoin.fr/"
alias cdrop="cd ~/Dropbox/"
alias cdpaper="cd ~/Dropbox/tim/paperwork/"
alias cdperso="cd ~/local/mnt/perso/"
# }}}

# Synchronize stuff {{{
# Import pictures from camera
alias michel-extract='camera-extract /media/MICHEL/'
# Import pictures from Galaxy
alias galaxy-extract='camera-extract /media/F101-14E2/DCIM'
# Synchronize dingoo
alias ds='~/Documents/emulation/devices/dingoo/tools/dingoo-sync /media/dingoo'
# Synchronize ebooks
alias es='ebook-sync ~/Documents/books /media/galaxy/books'
# Synchronize pictures on belette
alias photos-sync='photos-sync ~/Documents/Photos/ /media/BELETTE/Photos/Voyage/'
# Mark a music dir for synchronization
alias mfs="mark-for-sync"
function mfs-sansa() { mark-for-sync $* sansa }
function mfs-sansa-sd() { mark-for-sync $* sansa-sd }
# Synchronize jukebox to sansa-sd
alias sansa-sync-music="music-sync /media/jukebox/music sansa-sd"
alias sansa-sync-misc="music-sync /media/jukebox/misc sansa"
alias sansa-sync-nature="music-sync /media/jukebox/nature sansa"
alias sansa-sync-podcasts="music-sync /media/jukebox/podcasts sansa"
alias sansa-sync-soundtracks="music-sync /media/jukebox/soundtracks sansa-sd"
# }}}

# Games {{{
alias gta='cd ~/local/etc/gta/WINO/ && wine ./Grand\ Theft\ Auto.exe'
alias diablo='cd ~/local/etc/diablorl/ && ./rl'
# }}}

# Mount {{{
alias fbx='sudo mount -t cifs //mafreebox.freebox.fr/Disque\ dur/ /home/tim/local/mnt/freebox -o _netdev,guest,directio,uid=1000,iocharset=utf8,file_mode=0777,dir_mode=0777'
alias ufbx='sudo umount /home/tim/local/mnt/freebox'
alias cdfbx='cd /home/tim/local/mnt/freebox'
# }}}

# Downloading a website in ~/local/tmp/websites
alias mslurp="cd ~/local/tmp/websites && slurp"
# Prefix a date to a file
alias prd='prefix-date'
# Download files from transmission
alias td='transmission-download'

# Rikiki
export SERIES=/media/Rikiki/Films/Series/


# RVM config
path=($path	$HOME/.rvm/bin)
if [[ -r $HOME/.rvm/scripts/rvm ]]; then
  source ~/.rvm/scripts/rvm
fi
