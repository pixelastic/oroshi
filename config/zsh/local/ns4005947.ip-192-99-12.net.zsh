# Custom colors for this hostname
promptColor=(
	hostname	"130"
)

# RVM config
if [[ -r $HOME/.rvm/scripts/rvm ]]; then
	path=($path	$HOME/.rvm/bin)
	source ~/.rvm/scripts/rvm
fi
