bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "watches the diff since the worktree start commit" {
  git-worktree-start() { echo "a3c72604"; }
  git-file-watch() { echo "$1" > "$BATS_TMP_DIR/ref.txt"; }
  bats_mock git-worktree-start git-file-watch

  bats_run_zsh "git-file-watch-worktree"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/ref.txt")" = "a3c72604" ]]
}

@test "fails without starting the watch when no start commit is found" {
  git-worktree-start() { return 1; }
  git-file-watch() { touch "$BATS_TMP_DIR/watched.txt"; }
  bats_mock git-worktree-start git-file-watch

  bats_run_zsh "git-file-watch-worktree"
  [[ "$status" -eq 1 ]]
  [[ ! -e "$BATS_TMP_DIR/watched.txt" ]]
}
