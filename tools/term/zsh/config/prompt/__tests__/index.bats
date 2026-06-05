bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

@test "GIT_DIRECTORY_IS_WORKTREE is 1 inside a linked worktree" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  local script="$BATS_TMP_DIR/git-env-worktree.zsh"
  cat >"$script" <<'ZSCRIPT'
source ~/.oroshi/tools/term/zsh/config/zshenv.zsh
source ~/.oroshi/tools/term/zsh/config/prompt/index.zsh
oroshi-git-env-store
echo "$GIT_DIRECTORY_IS_WORKTREE"
ZSCRIPT
  bats_run_zsh "$script"
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

@test "GIT_DIRECTORY_IS_WORKTREE is 0 in the Git Repo Main" {
  cd "$BATS_GIT_DIR"
  local script="$BATS_TMP_DIR/git-env-main.zsh"
  cat >"$script" <<'ZSCRIPT'
source ~/.oroshi/tools/term/zsh/config/zshenv.zsh
source ~/.oroshi/tools/term/zsh/config/prompt/index.zsh
oroshi-git-env-store
echo "$GIT_DIRECTORY_IS_WORKTREE"
ZSCRIPT
  bats_run_zsh "$script"
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}
