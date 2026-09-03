# Keep track of OROSHI_ROOT as we move through worktrees
# Reload path and fpath accordinginly, when moving in and out of oroshi
# worktrees

function oroshi-chpwd() {
  local isInOroshiWorktree="0"
  [[ "$PWD" == "$OROSHI_WORKTREES_DIR/oroshi--"* ]] && isInOroshiWorktree="1"

  # Return early if moving from regular dir to regular dir
  [[ $isInOroshiWorktree == "0" && "$OROSHI_ROOT" == "$HOME/.oroshi" ]] && return 0
  # Return early if moving inside an oroshi worktree
  [[ "$PWD" == "$OROSHI_ROOT" || "$PWD" == "$OROSHI_ROOT/"* ]] && return 0

  local newRoot="$HOME/.oroshi"
  [[ "$isInOroshiWorktree" == "1" ]] && newRoot="$(git-directory-root --force)"

  export OROSHI_ROOT="$newRoot"
  oroshi-reload-path "$OROSHI_ROOT"
  oroshi-reload-fpath "$OROSHI_ROOT"
}
