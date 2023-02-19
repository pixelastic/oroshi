# Syntax is
# :completion:<function>:<completer>:<command>:<argument>:<tag>
#
# Source:
# https://thevaluable.dev/zsh-completion-guide-examples/

# Order of completions
zstyle ':completion:*' completer _extensions _complete
# Search for completion in the whole filename, not just on the start
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'

# Menu {{{
# Use a menu to select the completion
zstyle ':completion:*' menu select
# Group suggestions by type
zstyle ':completion:*' group-name ''
# Display results in lines instead of columns
setopt LIST_ROWS_FIRST
# Auto-select the first element of the menu
setopt MENU_COMPLETE
# }}}

# Globs {{{
# Wait 10s before rm ./*
setopt RM_STAR_WAIT
# }}}

# Files {{{
# Hidden files should be suggested
setopt GLOB_DOTS
# }}}
