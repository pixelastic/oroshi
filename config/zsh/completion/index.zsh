# Add custom completion functions fo fpath
fpath+=($ZSH_CONFIG_PATH/completion/compdef)

# Syntax is
# :completion:<function>:<completer>:<command>:<argument>:<tag>
# - <function> 
# 	is usually empty
# - <completer> 
# 	is the name of the completer (default is "complete") but more
#   can be defined with zstyle (like "extensions" or "approximate"). See "Control
#   Functions" in the doc
# - <command>
#   is the name of the command (like "mv" or "ssh"), or a custom context, like
#   "-redirect-" or "-command". "-command-" means an element in the command
#   position (ie. the first argument). It can be "git-status" for "git status"
# - <argument>
# 	is the position of the argument. It should be either 'argument-1' for the
# 	first argument, or 'option-o-1' for the first argument of -o
# - <tag>
# 	is the "group" in which the suggestion falls, like files
#
# Debug:
# Press Ctrl-X, then h on the commandline to see what complete function are
# called
#
# To read the value of a zstyle element (for example menu), use:
# zstyle -s ':completion:*' menu myVar
# echo $myVar
#
# Source:
# https://thevaluable.dev/zsh-completion-guide-examples/
# http://zv.github.io/a-review-of-zsh-completion-utilities
# https://wikimatze.de/writing-zsh-completion-for-padrino/
# TODO: Write tests
# https://unix.stackexchange.com/questions/668618/how-to-write-automated-tests-for-zsh-completion
# TODO: Hide tags, or re-order them:
# https://serverfault.com/questions/353270/excluding-environment-variables-from-zsh-autocomplete
# TODO: Check zsh-autosuggestion to display a fish-like autosuggestion
# TODO: Change the color of the currently selected suggestion to match what we
# do in fzf
#
# TODO:
# The next line suggests any .log files after a 2> redirect
# I might want to auto-suggest /dev/null as well
# zstyle ':completion:*:*:-redirect-,2>,*:*' file-patterns '*.log'
#
# TODO:
# The next line specify the comletion of dvips -o and only suggests files
# This is a good example of how to provide a specific completion for a specific
# flag
# :completion::complete:dvips:option-o-1:files
#
# TODO:
# The documentation states that it's better to write all :completion:* with
# explicit colons. Apparently, it makes parsing the default context simpler, and
# it will also make it more consistent

# TODO:
# The next line passes custom arbitrary values to specific completions
# This could be useful for when the obvious argument can't be guessed from the
# context, like a git branch -c develop
# zstyle ':completion:*:complete:cp:argument-rest:globbed-files' fake 'foo:this is foo' 'bar:this is bar'
#
# TODO:
# It is possible to display file suggestion in a display similar to ls, with
# modification, filesize, etc
# This might be useful for some commands, when metadata about a file is required
# zstyle ':completion:*' file-list yes
#
# TODO:
# I still haven't figured out how to rename the various tags headers.
# I would also like to re-order them
# And to potentially group several groups under a shared header
#
# TODO: 
# Not sure what the following line does, needs testing
# zstyle ':completion:*' file-patterns '*(-/):directories'
#
# TODO:
# The next line splits the files and directories, and display directories first.
# This might be an interesting default
# zstyle ':completion:*' list-dirs-first true
#
# TODO:
# The next line defines if suggestions with a shared description should be
# grouped on the same line, or on different line.
# Same line is for --flags, to have both the short and long format
# Different line is interesting for docker images or git branches, where
# description can be identical, but we still want them on different branches
# zstyle ':completion:*' list-grouped true
#
# TODO:
# The next line allows to define the width of the suggestions and width of the
# descriptions
# max-matches-width
#
# TODO:
# Changing the color of the highlight of the selected suggestion needs to use
# the "ma" style from the LS_COLORS equivalent
#
# TODO:
# Fix again bat completion. If can't make it work with compdef direct
# configuration, I should resurect the _oroshi_bat script I wrote.
# This forces bat to use only files completion, but we lose completion on
# --flags
# Need to rewrite _bat to not suggest the command
# This (below v) uses both _files and _gnu_generic for completing bat
# I would prefer a syntax that allow me to define the order for bat
# compdef _files bat
# compdef _gnu_generic bat
# This doesn't work as a way to define the completers to use
# zstyle ':completion:*:complete:bat:*:*' globbed-files _files _gnu_generic


# Generic config
source $ZSH_CONFIG_PATH/completion/misc.zsh
source $ZSH_CONFIG_PATH/completion/styling.zsh

# If the completion cache file is older than 20 hours, we regenerate it
# Source: https://gist.github.com/ctechols/ca1035271ad134841284#gistcomment-2308206
function oroshi_completion_compinit() {
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
oroshi_completion_compinit
unfunction oroshi_completion_compinit

# Custom compdef
source $ZSH_CONFIG_PATH/completion/compdef.zsh


