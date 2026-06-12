# This file is globally available as ~/.zshenv, even in oroshi worktrees.
# So its responsibility is to guess if OROSHI_ROOT should be the main oroshi
# repo, or one of its worktrees, and then load all other config from there.

# Where are all worktrees located?
export OROSHI_WORKTREES_DIR="${MOCK_OROSHI_WORKTREES_DIR:-$HOME/local/www/worktrees}"

# Where is the oroshi repo currently used?
export OROSHI_ROOT="$HOME/.oroshi"
export OROSHI_ROOT_DEFAULT="$OROSHI_ROOT"

# Switch to the worktree if we're in an oroshi worktree
if [[ "$PWD" == "$OROSHI_WORKTREES_DIR/oroshi--"* ]]; then
  export OROSHI_ROOT="$(git rev-parse --show-toplevel)"
fi

# Source other config from that root
source $OROSHI_ROOT/tools/term/zsh/config/zshenv-guest.zsh
