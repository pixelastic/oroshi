# Anything defined in this file will be accessible in:
# - Interactive shells (just like zshrc)
# - zsh scripts

export ZSH_CONFIG_PATH=~/.oroshi/config/zsh

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
oroshi-autoload-functions
