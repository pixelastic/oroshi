# Highlighting as I type {{{
require 'plugins/zsh-syntax-highlighting/zsh-syntax-highlighting'
# Documentation: 
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/highlighters/main/main-highlighter.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)
# Methods
ZSH_HIGHLIGHT_STYLES[alias]="fg=$COLOR_ALIAS_FUNCTION"
ZSH_HIGHLIGHT_STYLES[builtin]="fg=$COLOR_ALIAS_FUNCTION"
ZSH_HIGHLIGHT_STYLES[command]="fg=$COLOR_ALIAS_FUNCTION"
ZSH_HIGHLIGHT_STYLES[function]="fg=$COLOR_ALIAS_FUNCTION"
ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=$COLOR_ALIAS_FUNCTION"
# Path
ZSH_HIGHLIGHT_STYLES[path]="fg=$COLOR_ALIAS_DIRECTORY"
# Glob
ZSH_HIGHLIGHT_STYLES[globbing]="fg=$COLOR_ALIAS_GLOB"
# Arguments
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=$COLOR_ALIAS_FLAG"
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=$COLOR_ALIAS_FLAG"
# Strings (blue)
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]="fg=$COLOR_ALIAS_INTERPOLATION_STRING"
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=$COLOR_ALIAS_STRING"
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=$COLOR_ALIAS_STRING"
# Numbers (bold blue)
ZSH_HIGHLIGHT_STYLES[arithmetic-expansion]="fg=$COLOR_ALIAS_NUMBER"
# Punctuation
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]="fg=$COLOR_ALIAS_PUNCTUATION"
ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=$COLOR_ALIAS_PUNCTUATION"
# Repetition of last command using !
ZSH_HIGHLIGHT_STYLES[history-expansion]="fg=$COLOR_NEUTRAL"
# Variables
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]="fg=$COLOR_ALIAS_INTERPOLATION_VARIABLE"
ZSH_HIGHLIGHT_STYLES[assign]="fg=$COLOR_ALIAS_INTERPOLATION_VARIABLE"
# Errors
ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=$COLOR_ALIAS_ERROR"
# sudo
ZSH_HIGHLIGHT_STYLES[precommand]="fg=$COLOR_ALIAS_WARNING,bold"


# Even if the following styles are documented, I could not make them work last
# time I tried
ZSH_HIGHLIGHT_STYLES[arg0]="fg=$COLOR_ALIAS_UNKNOWN"
ZSH_HIGHLIGHT_STYLES[arithmetic-expansion]="fg=$COLOR_ALIAS_UNKNOWN"
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]="fg=$COLOR_ALIAS_UNKNOWN"
ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]="fg=$COLOR_ALIAS_UNKNOWN"
ZSH_HIGHLIGHT_STYLES[path-prefix]="fg=$COLOR_ALIAS_UNKNOWN"
ZSH_HIGHLIGHT_STYLES[redirection]="fg=$COLOR_ALIAS_UNKNOWN"
ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]="fg=$COLOR_ALIAS_UNKNOWN"
ZSH_HIGHLIGHT_STYLES[suffix-alias]="fg=$COLOR_ALIAS_UNKNOWN"
ZSH_HIGHLIGHT_STYLES[comment]="fg=$COLOR_ALIAS_UNKNOWN"
ZSH_HIGHLIGHT_STYLES[global-alias]="fg=$COLOR_ALIAS_UNKNOWN"
ZSH_HIGHLIGHT_STYLES[default]="fg=$$COLOR_ALIAS_UNKNOWN"
ZSH_HIGHLIGHT_STYLES[autodirectory]="fg=$COLOR_ALIAS_UNKNOWN"
ZSH_HIGHLIGHT_STYLES[path_pathseparator]="fg=$COLOR_ALIAS_UNKNOWN"
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]="fg=$COLOR_ALIAS_UNKNOWN"
ZSH_HIGHLIGHT_STYLES[command-substitution]="fg=$COLOR_ALIAS_UNKNOWN"
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]="fg=$COLOR_ALIAS_UNKNOWN"
ZSH_HIGHLIGHT_STYLES[process-substitution]="fg=$COLOR_ALIAS_UNKNOWN"
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]="fg=$COLOR_ALIAS_UNKNOWN"
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]="fg=$COLOR_ALIAS_UNKNOWN"
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=$COLOR_ALIAS_UNKNOWN"
ZSH_HIGHLIGHT_STYLES[rc-quote]="fg=$COLOR_ALIAS_UNKNOWN"
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]="fg=$COLOR_ALIAS_UNKNOWN"
ZSH_HIGHLIGHT_STYLES[named-fd]="fg=$COLOR_ALIAS_UNKNOWN"
ZSH_HIGHLIGHT_STYLES[numeric-fd]="fg=$COLOR_ALIAS_UNKNOWN"
# }}}
