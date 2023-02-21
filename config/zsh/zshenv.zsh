# Anything defined in this file will be accessible in:
# - Interactive shells (just like zshrc)
# - zsh scripts

# Manually loading all real functions saved in ./functions/*.zsh
local functionDirectory=~/.oroshi/config/zsh/functions
for item in ${functionDirectory}/*.zsh; do
  source $item
done

# Autoload all other functions saved in ./functions/autoload/**/*
oroshi-autoload-functions
