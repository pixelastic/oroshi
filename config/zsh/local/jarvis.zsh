# Custom colors for this hostname
promptColor=(
	hostname	"067"
)

# Oroshi {{{
# Reload keybings for this OS
function ok() {
  ~/.oroshi/scripts/deploy/xmodmap
  source ~/.oroshi/private/config/ubuntu/jarvis/keybindings/windows.sh
  source ~/.oroshi/private/config/ubuntu/jarvis/keybindings/custom.sh
  source ~/.oroshi/private/config/ubuntu/jarvis/keybindings/media.sh
}
# }}}
