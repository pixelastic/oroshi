# Parse arguments (argsf, argsp)

# ====
# https://xpmo.gitlab.io/post/using-zparseopts/
# https://linux.die.net/man/1/zshmodules
zmodload zsh/zutil
# -E : Don't stop on unknown flags
# -D : $@ is updated by removing all found flags
# a:=      : Short argument, like -s "xxx"
# -arg:=   : Long argument, like --separator "xxx"
# f=       : Short flag, like -f
# -force=  : Long flag, like --force
zparseopts -E -D \
	s:=flagSeparator \
	-separator:=flagSeparator \
	f=flagForce \
	-force=flagForce

# shellcheck disable=SC2154
local separator=${flagSeparator[2]}
local isForce=${#flagForce}

# ===
