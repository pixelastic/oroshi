bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# Removes an existing mark symlink
@test "removes a symlink for the given mark name" {
  local markpath="$BATS_TMP_DIR/marks"
  mkdir -p "$markpath"
  ln -s "$BATS_TMP_DIR" "$markpath/foo"

  OROSHI_MARKPATH="$markpath" bats_run_zsh "mark-delete foo"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$markpath/foo" ]]
}

# Errors when no argument given
@test "errors on missing name" {
  OROSHI_MARKPATH="$BATS_TMP_DIR/marks" bats_run_zsh "mark-delete"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"name"* ]]
}

# Errors when mark doesn't exist
@test "errors on nonexistent mark" {
  local markpath="$BATS_TMP_DIR/marks"
  mkdir -p "$markpath"

  OROSHI_MARKPATH="$markpath" bats_run_zsh "mark-delete unknown"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"unknown"* ]]
}
