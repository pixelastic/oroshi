# Environment variables {{{
export EDITOR=nvim              # Default text editor
export BROWSER=/usr/bin/firefox # Default browser
export LANG=en_US.UTF-8         # Default language
export LC_COLLATE=C             # Default sort order (in ls, sort, etc)
export OROSHI_ZSH_PID=$$        # Reference to this zsh pid

# Folder to store files needed for oroshi to run
export OROSHI_TMP_FOLDER=~/local/tmp/oroshi

# Use a different TERM if used locally on the laptop, or remotely on a server
if [[ $KITTY_WINDOW_ID != "" ]]; then
	export TERM="xterm-kitty"
else
	export TERM="xterm-256color"
fi
# }}}
