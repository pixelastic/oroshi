bats_load_library 'helper'

setup() {
  bats_tmp_dir

  git init --initial-branch=main --quiet "$BATS_TMP_DIR/repo"
  git -C "$BATS_TMP_DIR/repo" config user.email "bats@oroshi"
  git -C "$BATS_TMP_DIR/repo" config user.name "Bats"
  git -C "$BATS_TMP_DIR/repo" commit --allow-empty --quiet --message="init commit"

  export BATS_GIT_DIR="$BATS_TMP_DIR/repo"
  cd "$BATS_GIT_DIR"
}

teardown() {
  bats_cleanup
}

@test "returns branch:message for each branch" {
  bats_run_function complete-git-branches-local
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "main:init commit" ]
}
