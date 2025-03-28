# In which file to save history
export HISTFILE=~/.history
# How many commands do we keep stored in the file
export SAVEHIST=1000000000
# How many commands to load in our running session history
export HISTSIZE=1000
# Any command is added to the history file as soon as it's entered, and shared
# across sessions
setopt SHARE_HISTORY
# Log timestamps in history
setopt EXTENDED_HISTORY
# Entering the same command several times in a row won't add it several times
setopt HIST_IGNORE_DUPS
# Empty commands should not appear in the history
setopt HIST_REDUCE_BLANKS
# Commands starting with a space are not loggued in history
setopt HIST_IGNORE_SPACE
# Always print the last command before executing it when using "!!"
setopt HIST_VERIFY
