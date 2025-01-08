# Make keyboard work as expected
export TERM=xterm-256color
bindkey "[3~" delete-char       # Delete
bindkey "" backward-delete-char # Backspace

# Basic completion system
autoload -Uz compinit
compinit
# Enable menu selection for completions
zstyle ':completion:*' menu select

# Colors
autoload -U colors && colors
export CLICOLOR=1
export COLOR_RED=1
export COLOR_GREEN=2
export COLOR_YELLOW=3
export COLOR_PURPLE=21
export COLOR_BLUE=94
export LS_COLORS="di=38;5;${COLOR_GREEN}:ow=38;5;${COLOR_GREEN}:ex=4;38;5;${COLOR_PURPLE}:ln=34;4;${COLOR_BLUE}"
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Aliases
alias v='vi'
alias ls='ls -lhN --color=auto'
alias la='ls -lahN --color=auto'
alias ..='cd ..'

# Basic history settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Host-specific settings
local hostname="$(hostname)"
local promptPrefix="[%m]"
if [[ $hostname == "rg353v" ]]; then
	promptPrefix="%{[38;5;${COLOR_BLUE}m%}●%{[00m%}"
	promptPrefix+="%{[38;5;${COLOR_GREEN}m%}●%{[00m%}"
	promptPrefix+="%{[38;5;${COLOR_RED}m%}●%{[00m%}"
	promptPrefix+="%{[38;5;${COLOR_YELLOW}m%}●%{[00m%}"

	cd "/roms2/"
fi

# Basic prompt
PS1="${promptPrefix} %{[38;5;2m%}%~/%{[00m%} "
