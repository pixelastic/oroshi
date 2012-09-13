# HISTORY
# This file contains all options relative to the zsh command history
# =============================================================================
# In which file to save history
HISTFILE=~/.history
# How many lines to save in history
SAVEHIST=10000		# Big history
# Maximum size of the file
HISTSIZE=10000		# Big history
# We want to share history accross all opened terminal windows
setopt SHARE_HISTORY
# We do not want dupes to show in the history
setopt HIST_IGNORE_DUPS
# Empty commands should not appear in the history
setopt HIST_REDUCE_BLANKS
# We want the history to be appended to the existing file, not create a new one
setopt APPEND_HISTORY
# Always print the last command before executing it when using "!!"
setopt HIST_VERIFY
# Log timestamps in history
setopt EXTENDED_HISTORY 
# Commands starting with a space are not loggued in history
setopt HIST_IGNORE_SPACE	# do not log commands starting with a space
