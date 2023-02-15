# Pick in a list of existing value, where order is not important
# Source: https://github.com/zsh-users/zsh-completions/blob/master/zsh-completions-howto.org#writing-simple-completion-functions-using-_describe

local subcmds=('c:description for c command' 'd:description for d command')
_describe 'command' subcmds

# Pick in a list of values, grouped by types
_alternative 'arguments:custom arg:(a b c)' 'files:filename:_files'

# Define flags, with custom description and completion
_arguments '-f[input file]:filename:_files'
# -s can be added anywhere
# 1: must be first argument
# :: is optional
# "next arg" is the second argument (because no index, but after 1:)
_arguments '-s[sort output]' '1:first arg:_net_interfaces' '::optional arg:_files' ':next arg:(a b c)'
