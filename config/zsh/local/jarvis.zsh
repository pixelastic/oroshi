# Custom colors for this hostname
promptColor=(
	hostname	"067"
)

# Oroshi {{{
# Reload keybings for this OS
function ok() {
  ~/.oroshi/scripts/deploy/xmodmap
  source ~/.oroshi/config/ubuntu/15.04/keybindings/windows.sh
  source ~/.oroshi/config/ubuntu/15.04/keybindings/custom.sh
  source ~/.oroshi/config/ubuntu/15.04/keybindings/media.sh
}
# }}}
