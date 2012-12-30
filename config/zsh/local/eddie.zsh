# Custom colors for this hostname
promptColor=(
	hostname	"133"
)

# Dingoo
alias dingoo='~/Dingux/tools/dingoo-mount && cd ~/local/mnt/dingoo'
alias udingoo='sudo umount ~/local/mnt/dingoo'
alias dinguxdeploy='~/Dingux/tools/dingux-deploy'
alias dingoodeploy='~/Dingux/tools/dingoo-deploy'
alias ds='~/Documents/emulation/devices/dingoo/tools/scripts/dingoo-sync'

# Games
alias gba='gvba'

# Rikiki
export SERIES=/media/Rikiki/Films/Series/

# Alias for downloading a website directly in the correct folder
alias mslurp="cd ~/local/tmp/websites && slurp"

# Extract photos
alias recettes='blog-extract infos/recettes.txt recipe'

# RVM config
path=($path	$HOME/.rvm/bin)
if [[ -r $HOME/.rvm/scripts/rvm ]]; then
  source ~/.rvm/scripts/rvm
fi
