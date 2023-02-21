# Anything defined in this file will be accessible in:
# - Interactive shells (just like zshrc)
# - zsh scripts

# Define the $PATH, with unique values
# Note: the `typeset -aU path` line can't be included in a sourced function
# See: https://comp.unix.shell.narkive.com/a2BHsUYm/zsh-s-typeset-u-path-wipes-out-path-path
typeset -aU path
source ~/.oroshi/config/zsh/path.zsh

# Manually loading all real functions saved in ./functions/*.zsh
local functionDirectory=~/.oroshi/config/zsh/functions
for item in ${functionDirectory}/*.zsh; do
  source $item
done

# Autoload all other functions saved in ./functions/autoload/**/*
oroshi-autoload-functions
