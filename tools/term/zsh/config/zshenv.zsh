# Anything defined in this file will be accessible in:
# - Interactive shells (just like zshrc)
# - zsh scripts

# If in a oroshi worktree, use this as the root, so it inherit from all local
# scripts and functions
export OROSHI_WORKTREES_DIR="${OROSHI_WORKTREES_DIR:-$HOME/local/www/worktrees}"
if [[ "$PWD" == "$OROSHI_WORKTREES_DIR/"* ]]; then
  OROSHI_ROOT="$(git rev-parse --show-toplevel)"
fi

# Root of the oroshi repo — overridable so tests in worktrees resolve scripts locally
export OROSHI_ROOT="${OROSHI_ROOT:-$HOME/.oroshi}"
# Reference to the zsh config folder, so our `source` calls are easier to write
export ZSH_CONFIG_PATH="$OROSHI_ROOT/tools/term/zsh/config"
# Reference to the autoload functions folder
export OROSHI_ZSH_AUTOLOAD="$ZSH_CONFIG_PATH/functions/autoload"
# Reference to the path used to store runtime config
# Note: This can be overwritten in tests
export OROSHI_TMP_FOLDER="${OROSHI_TMP_FOLDER:-$HOME/local/tmp/oroshi}"

# Also make the HOSTNAME globally available. Some tools (like Kitty) can use ENV
# variables in their config, but can't call binaries, so having the HOSTNAME
# available allow me to define per-host config easily.
export HOSTNAME="$(hostname)"

# This will disable the automated loading of compinit in /etc/zsh/zshrc
skip_global_compinit=1

# Define the $PATH, with unique values
# Note: the `typeset -aU path` line can't be included in a sourced function
# See: https://comp.unix.shell.narkive.com/a2BHsUYm/zsh-s-typeset-u-path-wipes-out-path-path
typeset -aU path fpath
source $ZSH_CONFIG_PATH/path.zsh
oroshi-reload-path

# Manually loading all real functions saved in ./functions/*.zsh
local functionDirectory=$ZSH_CONFIG_PATH/functions
for item in ${functionDirectory}/*.zsh; do
  source $item
done

# Autoload all other functions saved in ./functions/autoload/**/*
oroshi-reload-fpath
