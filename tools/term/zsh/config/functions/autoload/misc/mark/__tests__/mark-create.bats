bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Mock project-name to return nothing (no project match) by default
  project-name() { :; }
  bats_mock project-name

  bats_disable_worktree_aware
}

# Explicit name
@test "creates symlink with explicit name" {
  local markpath="$BATS_TMP_DIR/marks"

  OROSHI_MARKPATH="$markpath" bats_run_zsh "cd $BATS_TMP_DIR && mark-create myname"
  [[ "$status" -eq 0 ]]
  [[ -L "$markpath/myname" ]]
  [[ "$(readlink "$markpath/myname")" == "$BATS_TMP_DIR" ]]
}

# Default name from dirname
@test "uses current dirname when no argument given" {
  local markpath="$BATS_TMP_DIR/marks"
  local targetdir="$BATS_TMP_DIR/somedir"
  mkdir -p "$targetdir"

  OROSHI_MARKPATH="$markpath" bats_run_zsh "cd $targetdir && mark-create"
  [[ "$status" -eq 0 ]]
  [[ -L "$markpath/somedir" ]]
  [[ "$(readlink "$markpath/somedir")" == "$targetdir" ]]
}

# Overwrite existing mark
@test "replaces existing mark" {
  local markpath="$BATS_TMP_DIR/marks"
  mkdir -p "$markpath" "$BATS_TMP_DIR/oldtarget" "$BATS_TMP_DIR/newtarget"
  ln -s "$BATS_TMP_DIR/oldtarget" "$markpath/foo"

  OROSHI_MARKPATH="$markpath" bats_run_zsh "cd $BATS_TMP_DIR/newtarget && mark-create foo"
  [[ "$status" -eq 0 ]]
  [[ "$(readlink "$markpath/foo")" == "$BATS_TMP_DIR/newtarget" ]]
}

# Warns on project match
@test "warns on stderr when directory matches a project path" {
  local markpath="$BATS_TMP_DIR/marks"

  # Mock project-name to return a matching project
  project-name() { echo "myproject"; }
  bats_mock project-name

  OROSHI_MARKPATH="$markpath" bats_run_zsh "cd $BATS_TMP_DIR && mark-create myproject"
  [[ "$status" -eq 0 ]]
  [[ -L "$markpath/myproject" ]]
  [[ "$output" == *"myproject"* ]]
}

# No warning without project match
@test "no warning when directory does not match a project" {
  local markpath="$BATS_TMP_DIR/marks"

  OROSHI_MARKPATH="$markpath" bats_run_zsh "cd $BATS_TMP_DIR && mark-create myname"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
