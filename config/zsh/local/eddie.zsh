# Custom colors for this hostname
promptColor=(
	hostname	"133"
)
# Private aliases
source ~/.oroshi/private/config/zsh/local/eddie.zsh

# Synchronize dingoo
alias ds='~/Documents/emulation/devices/dingoo/tools/dingoo-sync /media/dingoo'
# Synchronize ebooks
alias es='ebook-sync ~/Documents/books /media/HTC\ LEGEND/Data/Books'
# Synchronize pictures on belette
alias photos-sync='photos-sync ~/Documents/Photos/ /media/BELETTE/Photos/Voyage/'
# Downloading a website in ~/local/tmp/websites
alias mslurp="cd ~/local/tmp/websites && slurp"
# Prefix a date to a file
alias prd='prefix-date'

# Rikiki
export SERIES=/media/Rikiki/Films/Series/


# RVM config
path=($path	$HOME/.rvm/bin)
if [[ -r $HOME/.rvm/scripts/rvm ]]; then
  source ~/.rvm/scripts/rvm
fi
