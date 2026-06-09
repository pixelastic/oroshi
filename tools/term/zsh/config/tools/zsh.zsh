# Highlighting as I type {{{
# shellcheck source=/dev/null
source ~/local/src/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Documentation:
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/highlighters/main/main-highlighter.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)

typeset -A ZSH_HIGHLIGHT_STYLES=(
  # Fallback color
  'default' "fg=$colors[TEXT]"

  # Methods
  'alias' "fg=$colors[FUNCTION]"
  'global-alias' "fg=$colors[FUNCTION]"
  'builtin' "fg=$colors[FUNCTION]"
  'command' "fg=$colors[FUNCTION]"
  'function' "fg=$colors[FUNCTION]"
  'reserved-word' "fg=$colors[FUNCTION]"

  # Arguments
  'double-hyphen-option' "fg=$colors[FLAG]"
  'single-hyphen-option' "fg=$colors[FLAG]"

  # Variables
  'dollar-double-quoted-argument' "fg=$colors[INTERPOLATION_VARIABLE]"
  'assign' "fg=$colors[INTERPOLATION_VARIABLE]"
  'comment' "fg=$colors[INTERPOLATION_VARIABLE]" # $i in "for i in ./*; echo $i; done"

  # $() interpolation
  'command-substitution' "fg=$colors[INTERPOLATION_WRAPPER]"
  'command-substitution-delimiter' "fg=$colors[INTERPOLATION_WRAPPER]"

  # Punctuation
  'back-double-quoted-argument' "fg=$colors[PUNCTUATION]"
  'commandseparator' "fg=$colors[PUNCTUATION]"

  # Path
  'path' "fg=$colors[DIRECTORY]"                      # Existing path
  'path_pathseparator' "fg=$colors[DIRECTORY]"        # / in existing path
  'path_prefix' "fg=$colors[DIRECTORY]"               # Incomplete path
  'path_prefix_pathseparator' "fg=$colors[DIRECTORY]" # / in incomplete path
  'autodirectory' "fg=$colors[DIRECTORY]"

  # Glob
  'globbing' "fg=$colors[GLOB]"

  # Strings (blue)
  'back-quoted-argument' "fg=$colors[STRING]"
  'back-quoted-argument-unclosed' "bg=$colors[STRING],fg=$colors[BLACK]"
  'back-quoted-argument-delimiter' "fg=$colors[STRING]"
  'double-quoted-argument' "fg=$colors[STRING]"
  'double-quoted-argument-unclosed' "bg=$colors[STRING],fg=$colors[BLACK]"
  'single-quoted-argument' "fg=$colors[STRING]"
  'single-quoted-argument-unclosed' "bg=$colors[STRING],fg=$colors[BLACK]"

  # Numbers (bold blue)
  'arithmetic-expansion' "fg=$colors[NUMBER]"

  # Repetition of last command using !
  'history-expansion' "fg=$colors[NEUTRAL]"

  # Errors
  'unknown-token' "fg=$colors[ERROR]"
  'arg0' "fg=$colors[ERROR]" # typing the name of a +x file in the current dir

  # sudo
  'precommand' "fg=$colors[WARNING],bold"

  # &>, 1>, 2> redirection
  'redirection' "fg=$colors[SYMBOL]"

  # ???
  'arithmetic-expansion' "bg=$colors[UNKNOWN]"
  'back-dollar-quoted-argument' "bg=$colors[UNKNOWN]"
  'bracket-error' "bg=$colors[UNKNOWN]"
  'bracket-level-1' "bg=$colors[UNKNOWN]"
  'bracket-level-2' "bg=$colors[UNKNOWN]"
  'bracket-level-3' "bg=$colors[UNKNOWN]"
  'bracket-level-4' "bg=$colors[UNKNOWN]"
  'bracket-level-5' "bg=$colors[UNKNOWN]"
  'cursor' "bg=$colors[UNKNOWN]"
  'cursor-matchingbracket' "bg=$colors[UNKNOWN]"
  'dollar-quoted-argument' "bg=$colors[UNKNOWN]"
  'hashed-command' "bg=$colors[UNKNOWN]"
  'line' "bg=$colors[UNKNOWN]"
  'named-fd' "bg=$colors[UNKNOWN]"
  'numeric-fd' "bg=$colors[UNKNOWN]"
  'path_approx' "bg=$colors[UNKNOWN]"
  'process-substitution' "bg=$colors[UNKNOWN]"
  'process-substitution-delimiter' "bg=$colors[UNKNOWN]"
  'rc-quote' "bg=$colors[UNKNOWN]"
  'root' "bg=$colors[UNKNOWN]"
  'suffix-alias' "bg=$colors[UNKNOWN]"
)
