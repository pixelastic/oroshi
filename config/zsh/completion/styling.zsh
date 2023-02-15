# Styling {{{
function headerFormat() {
  local colorBackground=$1
  local colorForeground=$2
  local content=${3:-%d}
  echo "%K{$colorBackground}%F{$colorForeground} $content %F{$COLOR_ALIAS_TERMINAL}%f%f%k"
}

# Default style for header descriptions
zstyle ':completion:*:descriptions' format "$(headerFormat $COLOR_ALIAS_HEADER $COLOR_BLACK)"


# Files
zstyle ':completion:*:globbed-files' format "$(headerFormat $COLOR_ALIAS_FILE $COLOR_WHITE ' Files')"
# Re-use LS_COLORS for coloring the files and directories
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# Directories
zstyle ':completion:*:local-directories' format "$(headerFormat $COLOR_ALIAS_DIRECTORY $COLOR_WHITE ' Directories')"

# Commands
zstyle ':completion:*:commands' format "$(headerFormat $COLOR_ALIAS_FUNCTION $COLOR_BLACK ' Commands')"
zstyle ':completion:*:functions' format "$(headerFormat $COLOR_ALIAS_FUNCTION $COLOR_BLACK '{} Functions')"

# Subcommands
zstyle ':completion:*:values' format "$(headerFormat $COLOR_ALIAS_FLAG $COLOR_WHITE)"

# Flags
zstyle ':completion:*:options' format "$(headerFormat $COLOR_ALIAS_FLAG $COLOR_WHITE '-- Flags')"

# Variables
zstyle ':completion:*:parameters' format "$(headerFormat $COLOR_ALIAS_VARIABLE $COLOR_WHITE '$ Variables')"

# Fuzzy-find corrections
zstyle ':completion:*:corrections' format "$(headerFormat $COLOR_ALIAS_MATCH $COLOR_BLACK '~ Fuzzyfind')"

# Original query if no match found
zstyle ':completion:*:original' format "$(headerFormat $COLOR_ALIAS_UI $COLOR_WHITE '✘ Original query')"

# Error messages
zstyle ':completion:*:warnings' format "$(headerFormat $COLOR_ALIAS_ERROR $COLOR_WHITE 'No match found')"
# }}}


# Mi# ---

# Files
# Directories
zstyle ':completion:*:arguments' format "arguments: %d"
zstyle ':completion:*:builtins' format "builtins: %d"
zstyle ':completion:*:directories' format "directories: %d"
zstyle ':completion:*:files' format "files: %d"
zstyle ':completion:*:history-words' format "history-words: %d"
zstyle ':completion:*:host' format "host: %d"
zstyle ':completion:*:manuals' format "manuals: %d"
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:named-directories' format "named-directories: %d"
zstyle ':completion:*:names' format "names: %d"
zstyle ':completion:*:paths' format "paths: %d"
zstyle ':completion:*:path-directories' format "path-directories: %d"
zstyle ':completion:*:processes-names' format "processes-names: %d"
zstyle ':completion:*:suffixes' format "suffixes: %d"
zstyle ':completion:*:urls' format "urls: %d"
