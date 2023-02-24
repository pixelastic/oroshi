# Styling {{{
function completion-header() {
  local colorBackground=$1
  local colorForeground=${2:-$COLOR_BLACK}
  local content=${3:-%d}
  echo "%K{$colorBackground}%F{$colorForeground}$content%f%F{$COLOR_ALIAS_TERMINAL}%f%k"
}

# Default coloring:
# - Descriptions in gray
# - Files/Folders following LS_COLORS
zstyle ':completion:*:default' list-colors \
  "=(#b)* (--) (*)=38;5;$COLOR_WHITE=38;5;$COLOR_ALIAS_UI=38;5;$COLOR_ALIAS_COMMENT" \
  ${(s.:.)LS_COLORS}

# Headers
zstyle ':completion:*:descriptions' format "$(completion-header $COLOR_ALIAS_HEADER $COLOR_BLACK)"

# Files
zstyle ':completion:*:globbed-files' format "$(completion-header $COLOR_ALIAS_FILE $COLOR_WHITE '  Files ')"

# Directories
zstyle ':completion:*:local-directories' format "$(completion-header $COLOR_ALIAS_DIRECTORY $COLOR_WHITE '  Directories ')"

# Commands
zstyle ':completion:*:commands'  format "$(completion-header $COLOR_ALIAS_FUNCTION $COLOR_BLACK '  Commands ')"
zstyle ':completion:*:functions' format "$(completion-header $COLOR_ALIAS_FUNCTION $COLOR_BLACK ' {} Functions ')"
zstyle ':completion:*:builtins'  format "$(completion-header $COLOR_ALIAS_FUNCTION $COLOR_BLACK '  Zsh Builtins ')"

# Flags
zstyle ':completion:*:options' format "$(completion-header $COLOR_ALIAS_FLAG $COLOR_WHITE ' -- Flags ')"
zstyle ':completion:*:options' list-colors "=(#b)(*) (--) (*)=38;5;$COLOR_WHITE=38;5;$COLOR_ALIAS_FLAG=38;5;$COLOR_ALIAS_UI=38;5;$COLOR_ALIAS_COMMENT"

# Variables
zstyle ':completion:*:parameters' format "$(completion-header $COLOR_ALIAS_VARIABLE $COLOR_WHITE ' $ Variables ')"

# Git
# TODO: Move git compdef and styling together
function () {
  local listColorsGitBranch=(\
    "=(#b)(master*) (--) (*)=38;5;$COLOR_WHITE=38;5;$COLOR_ALIAS_GIT_BRANCH_MASTER=38;5;$COLOR_ALIAS_UI=38;5;$COLOR_ALIAS_COMMENT" \
    "=(#b)(develop*) (--) (*)=38;5;$COLOR_WHITE=38;5;$COLOR_ALIAS_GIT_BRANCH_DEVELOP=38;5;$COLOR_ALIAS_UI=38;5;$COLOR_ALIAS_COMMENT" \
    "=(#b)(dependabot*) (--) (*)=38;5;$COLOR_WHITE=38;5;$COLOR_ALIAS_GIT_BRANCH_DEPENDABOT=38;5;$COLOR_ALIAS_UI=38;5;$COLOR_ALIAS_COMMENT" \
    "=(#b)(*) (--) (*)=38;5;$COLOR_WHITE=38;5;$COLOR_ALIAS_GIT_BRANCH_DEFAULT=38;5;$COLOR_ALIAS_UI=38;5;$COLOR_ALIAS_COMMENT"
  )

  zstyle ':completion:*:*:git-branch-pull:*' list-colors $listColorsGitBranch
  zstyle ':completion:*:*:git-branch-remove-remote:*' list-colors $listColorsGitBranch
  zstyle ':completion:*:*:git-branch-switch:*' list-colors $listColorsGitBranch
  zstyle ':completion:*:*:git-branch-remove:*' list-colors $listColorsGitBranch
}

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
