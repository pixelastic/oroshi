# Highlighting as I type {{{
# shellcheck source=/dev/null
source ~/local/src/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Documentation:
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/highlighters/main/main-highlighter.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)

colors-load-definitions

typeset -A ZSH_HIGHLIGHT_STYLES=(
  # Fallback color
  'default' "fg=$COLORS[text]"

  # Methods
  'alias' "fg=$COLORS[function]"
  'global-alias' "fg=$COLORS[function]"
  'builtin' "fg=$COLORS[function]"
  'command' "fg=$COLORS[function]"
  'function' "fg=$COLORS[function]"
  'reserved-word' "fg=$COLORS[function]"

  # Arguments
  'double-hyphen-option' "fg=$COLORS[flag]"
  'single-hyphen-option' "fg=$COLORS[flag]"

  # Variables
  'dollar-double-quoted-argument' "fg=$COLORS[interpolation-variable]"
  'assign' "fg=$COLORS[interpolation-variable]"
  'comment' "fg=$COLORS[interpolation-variable]" # $i in "for i in ./*; echo $i; done"

  # $() interpolation
  'command-substitution' "fg=$COLORS[interpolation-wrapper]"
  'command-substitution-delimiter' "fg=$COLORS[interpolation-wrapper]"

  # Punctuation
  'back-double-quoted-argument' "fg=$COLORS[punctuation]"
  'commandseparator' "fg=$COLORS[punctuation]"

  # Path
  'path' "fg=$COLORS[directory]"                      # Existing path
  'path_pathseparator' "fg=$COLORS[directory]"        # / in existing path
  'path_prefix' "fg=$COLORS[directory]"               # Incomplete path
  'path_prefix_pathseparator' "fg=$COLORS[directory]" # / in incomplete path
  'autodirectory' "fg=$COLORS[directory]"

  # Glob
  'globbing' "fg=$COLORS[glob]"

  # Strings (blue)
  'back-quoted-argument' "fg=$COLORS[string]"
  'back-quoted-argument-unclosed' "bg=$COLORS[string],fg=$COLORS[black]"
  'back-quoted-argument-delimiter' "fg=$COLORS[string]"
  'double-quoted-argument' "fg=$COLORS[string]"
  'double-quoted-argument-unclosed' "bg=$COLORS[string],fg=$COLORS[black]"
  'single-quoted-argument' "fg=$COLORS[string]"
  'single-quoted-argument-unclosed' "bg=$COLORS[string],fg=$COLORS[black]"

  # Numbers (bold blue)
  'arithmetic-expansion' "fg=$COLORS[number]"

  # Repetition of last command using !
  'history-expansion' "fg=$COLORS[neutral]"

  # Errors
  'unknown-token' "fg=$COLORS[error]"
  'arg0' "fg=$COLORS[error]" # typing the name of a +x file in the current dir

  # sudo
  'precommand' "fg=$COLORS[warning],bold"

  # &>, 1>, 2> redirection
  'redirection' "fg=$COLORS[symbol]"

  # ???
  'arithmetic-expansion' "bg=$COLORS[unknown]"
  'back-dollar-quoted-argument' "bg=$COLORS[unknown]"
  'bracket-error' "bg=$COLORS[unknown]"
  'bracket-level-1' "bg=$COLORS[unknown]"
  'bracket-level-2' "bg=$COLORS[unknown]"
  'bracket-level-3' "bg=$COLORS[unknown]"
  'bracket-level-4' "bg=$COLORS[unknown]"
  'bracket-level-5' "bg=$COLORS[unknown]"
  'cursor' "bg=$COLORS[unknown]"
  'cursor-matchingbracket' "bg=$COLORS[unknown]"
  'dollar-quoted-argument' "bg=$COLORS[unknown]"
  'hashed-command' "bg=$COLORS[unknown]"
  'line' "bg=$COLORS[unknown]"
  'named-fd' "bg=$COLORS[unknown]"
  'numeric-fd' "bg=$COLORS[unknown]"
  'path_approx' "bg=$COLORS[unknown]"
  'process-substitution' "bg=$COLORS[unknown]"
  'process-substitution-delimiter' "bg=$COLORS[unknown]"
  'rc-quote' "bg=$COLORS[unknown]"
  'root' "bg=$COLORS[unknown]"
  'suffix-alias' "bg=$COLORS[unknown]"
)
