bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# Project resolution
@test "resolves a project name to its expanded path" {
  mkdir -p "$BATS_TMP_DIR/project"

  project-path() { echo "$BATS_TMP_DIR/project"; }
  bats_mock project-path
  bats_disable_worktree_aware

  bats_run_zsh "cd $BATS_TMP_DIR && mark-jump foo && pwd"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$BATS_TMP_DIR/project" ]]
}

# Mark resolution
@test "resolves a mark name to its symlink target" {
  project-path() { return 1; }
  bats_mock project-path
  bats_disable_worktree_aware

  local markpath="$BATS_TMP_DIR/marks"
  mkdir -p "$markpath" "$BATS_TMP_DIR/target"
  ln -s "$BATS_TMP_DIR/target" "$markpath/bar"

  OROSHI_MARKPATH="$markpath" bats_run_zsh "cd $BATS_TMP_DIR && mark-jump bar && pwd"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$BATS_TMP_DIR/target" ]]
}

# Project takes priority over mark
@test "prefers project over mark when both exist" {
  mkdir -p "$BATS_TMP_DIR/projdir"
  local markpath="$BATS_TMP_DIR/marks"
  mkdir -p "$markpath" "$BATS_TMP_DIR/markdir"
  ln -s "$BATS_TMP_DIR/markdir" "$markpath/baz"

  project-path() { echo "$BATS_TMP_DIR/projdir"; }
  bats_mock project-path
  bats_disable_worktree_aware

  OROSHI_MARKPATH="$markpath" bats_run_zsh "cd $BATS_TMP_DIR && mark-jump baz && pwd"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$BATS_TMP_DIR/projdir" ]]
}

# Unknown name
@test "errors on unknown name" {
  project-path() { return 1; }
  bats_mock project-path
  bats_disable_worktree_aware

  local markpath="$BATS_TMP_DIR/marks"
  mkdir -p "$markpath"

  OROSHI_MARKPATH="$markpath" bats_run_zsh "cd $BATS_TMP_DIR && mark-jump qux"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"No such mark: qux"* ]]
}
