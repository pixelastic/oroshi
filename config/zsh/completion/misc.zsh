# To read the value of a zstyle element (for example menu), use:
# zstyle -s ':completion:*' menu myVar
# echo $myVar


# Search for completion in the whole filename, not just on the start
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'

# Menu {{{
# Configure the menu to use for suggestions:
# - select: displays a menu with highlightable elements, when pressing tab
# - yes: forces selecting the first element on tab completion
zstyle ':completion:*' menu select
# Group suggestions by type
zstyle ':completion:*' group-name ''
# Use // to separate the description
zstyle ':completion:*' list-separator '//'
# Display results in lines instead of columns
setopt LIST_ROWS_FIRST
# }}}

# Globs {{{
# Wait 10s before rm ./*
setopt RM_STAR_WAIT
# }}}

# Files {{{
# Hidden files should be suggested
setopt GLOB_DOTS
# Do not add symbols after file names to indicate their type (*, @ or /)
unsetopt LIST_TYPES
# }}}

