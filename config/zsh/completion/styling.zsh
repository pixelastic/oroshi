# Styling {{{
function completion-header() {
  local colorBackground=$1
  local colorForeground=$2
  local content=${3:- %d }
  echo "%K{$colorBackground}%F{$colorForeground}$content%F{$COLOR_ALIAS_TERMINAL}%f%f%k"
}

# Default style for header descriptions
zstyle ':completion:*:descriptions' format "$(completion-header $COLOR_ALIAS_HEADER $COLOR_BLACK)"


# Files
zstyle ':completion:*:globbed-files' format "$(completion-header $COLOR_ALIAS_FILE $COLOR_WHITE '  Files ')"
# Re-use LS_COLORS for coloring the files and directories
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# Directories
zstyle ':completion:*:local-directories' format "$(completion-header $COLOR_ALIAS_DIRECTORY $COLOR_WHITE '  Directories ')"

# Commands
zstyle ':completion:*:commands' format "$(completion-header $COLOR_ALIAS_FUNCTION $COLOR_BLACK '  Commands ')"
zstyle ':completion:*:functions' format "$(completion-header $COLOR_ALIAS_FUNCTION $COLOR_BLACK ' {} Functions ')"

# Flags
zstyle ':completion:*:options' format "$(completion-header $COLOR_ALIAS_FLAG $COLOR_WHITE ' -- Flags ')"

# Variables
zstyle ':completion:*:parameters' format "$(completion-header $COLOR_ALIAS_VARIABLE $COLOR_WHITE ' $ Variables ')"

# Running processes
zstyle ':completion:*:processes-names' format "$(completion-header $COLOR_ALIAS_PROCESS $COLOR_BLACK '  Running processes ')"

# Original query if no match found
zstyle ':completion:*:original' format "$(completion-header $COLOR_ALIAS_UI $COLOR_WHITE ' ✘ Original query ')"

# Fuzzy-find corrections
zstyle ':completion:*:corrections' format "$(completion-header $COLOR_ALIAS_MATCH $COLOR_BLACK ' ~ Fuzzyfind ')"

# Error messages
zstyle ':completion:*:warnings' format "$(completion-header $COLOR_ALIAS_ERROR $COLOR_WHITE ' No match found ')"
# }}}


# Unknown elements
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
zstyle ':completion:*:suffixes' format "suffixes: %d"
zstyle ':completion:*:urls' format "urls: %d"
# Arbitrary values
zstyle ':completion:*:values' format "$(completion-header $COLOR_ALIAS_UI $COLOR_WHITE)"
