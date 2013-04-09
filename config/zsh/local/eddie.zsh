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
# }}}

# Synchronize stuff {{{
# Import pictures from camera
alias michel-extract='camera-extract /media/MICHEL/DCIM'
# Import pictures from Galaxy
alias galaxy-extract='camera-extract /media/F101-14E2/DCIM/'
# Import scans from Doxie
alias doxie-extract='camera-extract /media/DOXIE/DCIM/'
# Synchronize dingoo
alias ds='~/Documents/emulation/devices/dingoo/tools/dingoo-sync /media/dingoo'
# Synchronize ebooks
alias es='ebook-sync ~/Documents/books /media/galaxy/books'
# Synchronize pictures on belette
alias photos-sync='photos-sync ~/Documents/Photos/ /media/BELETTE/Photos/Voyage/'
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
