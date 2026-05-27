# Load z if installed
# https://github.com/agkozak/zsh-z
function oroshi_tools_z() {
	local zPath=~/local/etc/zsh-z/zsh-z.plugin.zsh
	[[ -r $zPath ]] || return
	source $zPath

	# Save home directory as "~" instead of full path
	export ZSHZ_TILDE="1"
}
oroshi_tools_z
unfunction oroshi_tools_z
