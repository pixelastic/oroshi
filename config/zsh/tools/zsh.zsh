# Highlighting as I type {{{
source $ZSH_CONFIG_PATH/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Documentation:
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/highlighters/main/main-highlighter.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)

# shfmt, not made for zsh, reformats associative array keys that contains
# dashes, with spaces between the dashes. It's because in bash, keys must be
# enclosed in strings, and dashes are minus signs for arithmetic expressions.
# In bash, keys are interpreted as variables, unless they are quotes.
# In zsh, keys are interpreted as strings, unless they are prefixed with a $

# The only way to work around that is to not use keys with dashes. I can do that
# with my own code, but here, I'm configuring existing keys of zsh, so I can't
# rename them.
#
# The workaround might be to define the keys as variables, but I'll need them
# stored somewhere before...
typeset -A ZSH_HIGHLIGHT_STYLES=(
	# Fallback color
	'default' "fg=$COLOR_ALIAS_TEXT"

	# Methods
	'alias' "fg=$COLOR_ALIAS_FUNCTION"
	'builtin' "fg=$COLOR_ALIAS_FUNCTION"
	'command' "fg=$COLOR_ALIAS_FUNCTION"
	'function' "fg=$COLOR_ALIAS_FUNCTION"
	'reserved-word' "fg=$COLOR_ALIAS_FUNCTION"

	# Path
	'path' "fg=$COLOR_ALIAS_DIRECTORY"

	# Glob
	'globbing' "fg=$COLOR_ALIAS_GLOB"

	# Arguments
	'double-hyphen-option' "fg=$COLOR_ALIAS_FLAG"
	'single-hyphen-option' "fg=$COLOR_ALIAS_FLAG"

	# Strings (blue)
	'back-quoted-argument' "fg=$COLOR_ALIAS_INTERPOLATION_STRING"
	'double-quoted-argument' "fg=$COLOR_ALIAS_STRING"
	'single-quoted-argument' "fg=$COLOR_ALIAS_STRING"

	# Numbers (bold blue)
	'arithmetic-expansion' "fg=$COLOR_ALIAS_NUMBER"

	# Punctuation
	'back-double-quoted-argument' "fg=$COLOR_ALIAS_PUNCTUATION"
	'commandseparator' "fg=$COLOR_ALIAS_PUNCTUATION"

	# Repetition of last command using !
	'history-expansion' "fg=$COLOR_NEUTRAL"

	# Variables
	'dollar-double-quoted-argument' "fg=$COLOR_ALIAS_INTERPOLATION_VARIABLE"
	'assign' "fg=$COLOR_ALIAS_INTERPOLATION_VARIABLE"

	# Errors
	'unknown-token' "fg=$COLOR_ALIAS_ERROR"

	# While typing, but doesn't match anything yet
	'path_approx' "fg=$COLOR_ALIAS_COMMENT"
	'path_prefix' "fg=$COLOR_ALIAS_COMMENT"

	# sudo
	'precommand' "fg=$COLOR_ALIAS_WARNING,bold"

	# ???
	'arg0' "fg=$COLOR_ALIAS_UNKNOWN"
	'arithmetic-expansion' "fg=$COLOR_ALIAS_UNKNOWN"
	'autodirectory' "fg=$COLOR_ALIAS_UNKNOWN"
	'back-dollar-quoted-argument' "fg=$COLOR_ALIAS_UNKNOWN"
	'back-quoted-argument-delimiter' "fg=$COLOR_ALIAS_UNKNOWN"
	'back-quoted-argument-unclosed' "fg=$COLOR_ALIAS_UNKNOWN"
	'bracket-error' "fg=$COLOR_ALIAS_UNKNOWN"
	'bracket-level-1' "fg=$COLOR_ALIAS_UNKNOWN"
	'bracket-level-2' "fg=$COLOR_ALIAS_UNKNOWN"
	'bracket-level-3' "fg=$COLOR_ALIAS_UNKNOWN"
	'bracket-level-4' "fg=$COLOR_ALIAS_UNKNOWN"
	'bracket-level-5' "fg=$COLOR_ALIAS_UNKNOWN"
	'command-substitution' "fg=$COLOR_ALIAS_UNKNOWN"
	'command-substitution-delimiter' "fg=$COLOR_ALIAS_UNKNOWN"
	'comment' "fg=$COLOR_ALIAS_UNKNOWN"
	'cursor' "fg=$COLOR_ALIAS_UNKNOWN"
	'cursor-matchingbracket' "fg=$COLOR_ALIAS_UNKNOWN"
	'dollar-quoted-argument' "fg=$COLOR_ALIAS_UNKNOWN"
	'double-quoted-argument-unclosed' "fg=$COLOR_ALIAS_UNKNOWN"
	'global-alias' "fg=$COLOR_ALIAS_UNKNOWN"
	'hashed-command' "fg=$COLOR_ALIAS_UNKNOWN"
	'line' "fg=$COLOR_ALIAS_UNKNOWN"
	'named-fd' "fg=$COLOR_ALIAS_UNKNOWN"
	'numeric-fd' "fg=$COLOR_ALIAS_UNKNOWN"
	'path-prefix' "fg=$COLOR_ALIAS_UNKNOWN"
	'path_pathseparator' "fg=$COLOR_ALIAS_UNKNOWN"
	'path_prefix_pathseparator' "fg=$COLOR_ALIAS_UNKNOWN"
	'process-substitution' "fg=$COLOR_ALIAS_UNKNOWN"
	'process-substitution-delimiter' "fg=$COLOR_ALIAS_UNKNOWN"
	'rc-quote' "fg=$COLOR_ALIAS_UNKNOWN"
	'redirection' "fg=$COLOR_ALIAS_UNKNOWN"
	'root' "fg=$COLOR_ALIAS_UNKNOWN"
	'single-quoted-argument-unclosed' "fg=$COLOR_ALIAS_UNKNOWN"
	'suffix-alias' "fg=$COLOR_ALIAS_UNKNOWN"
)
