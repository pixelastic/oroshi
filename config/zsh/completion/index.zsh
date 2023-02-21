# Add custom completion functions fo fpath
fpath+=($ZSH_CONFIG_PATH/completion/compdef)

# Generic config
source $ZSH_CONFIG_PATH/completion/misc.zsh
source $ZSH_CONFIG_PATH/completion/styling.zsh

# If the completion cache file is older than 20 hours, we regenerate it
# Source: https://gist.github.com/ctechols/ca1035271ad134841284#gistcomment-2308206
function () {
	setopt local_options
	setopt extendedglob

	autoload -Uz compinit

	# We check if ~/.zcompdump is older than 20 hours, and if so, we regenerate
	# it. This takes about ~1.5s, so we don't want to do that on every shell. Once
	# a day is fine.
	#
	# The relevant modifier is `mh+20`, which means "[m]odification more than [20] [h]ours ago".
	# The `#qN.` is zsh gibberish to "make it work"
	#
	if [[ ! -n ~/.zcompdump(#qN.mh+20) ]]; then
		# This branch triggers both if:
		# - The file has never been generated
		# - The file has been generated and is still warm
		
		# The -C flag will tell zsh to skip its internal freshness checks
		# If the file doesn't exist, it will create it. If it does, it will use it
		compinit -C
	else
		# File is too cold, we need to regenerate it
		compinit
	fi
}

# Custom compdef
source $ZSH_CONFIG_PATH/completion/compdef.zsh

