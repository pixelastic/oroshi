# Anything defined in this file will be accessible in:
# - Interactive shells (just like zshrc)
# - zsh scripts

# Reference to the zsh config folder, so our `source` calls are easier to write
export ZSH_CONFIG_PATH=~/.oroshi/config/zsh

# This will disable the automated loading of compinit in /etc/zsh/zshrc
skip_global_compinit=1

# Define the $PATH, with unique values
# Note: the `typeset -aU path` line can't be included in a sourced function
# See: https://comp.unix.shell.narkive.com/a2BHsUYm/zsh-s-typeset-u-path-wipes-out-path-path
typeset -aU path fpath
source $ZSH_CONFIG_PATH/path.zsh

# Manually loading all real functions saved in ./functions/*.zsh
local functionDirectory=$ZSH_CONFIG_PATH/functions
for item in ${functionDirectory}/*.zsh; do
	source $item
done

# Autoload all other functions saved in ./functions/autoload/**/*
oroshi-reload-functions
