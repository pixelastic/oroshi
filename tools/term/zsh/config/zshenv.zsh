# Anything defined in this file will be accessible in:
# - Interactive shells (just like zshrc)
# - zsh scripts

# The following paths are overridable by tests
# Root of the oroshi repo
export OROSHI_ROOT="${OROSHI_ROOT:-$HOME/.oroshi}"
# Root of the worktrees directories
export OROSHI_WORKTREES_DIR="${OROSHI_WORKTREES_DIR:-$HOME/local/www/worktrees}"
# Root of where we store runtime config
export OROSHI_TMP_FOLDER="${OROSHI_TMP_FOLDER:-$HOME/local/tmp/oroshi}"

# When moving inside an oroshi worktree, we want to change the OROSHI_ROOT to
# that worktree
export OROSHI_ROOT_DEFAULT="$OROSHI_ROOT"
if [[ "$PWD" == "$OROSHI_WORKTREES_DIR/"* ]]; then
  OROSHI_ROOT="$(git rev-parse --show-toplevel)"
fi
# Reference to the zsh config folder, so our `source` calls are easier to write
export ZSH_CONFIG_PATH="$OROSHI_ROOT/tools/term/zsh/config"
# Reference to the autoload functions folder
export OROSHI_ZSH_AUTOLOAD="$ZSH_CONFIG_PATH/functions/autoload"

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
oroshi-reload-path $OROSHI_ROOT

# Manually loading all real functions saved in ./functions/*.zsh
local functionDirectory=$ZSH_CONFIG_PATH/functions
for item in ${functionDirectory}/*.zsh; do
  source $item
done

# Autoload all other functions saved in ./functions/autoload/**/*
oroshi-reload-fpath $OROSHI_ROOT
