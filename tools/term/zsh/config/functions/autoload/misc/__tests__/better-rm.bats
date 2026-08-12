bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# --- Single file ---

@test "deletes a single file" {
  touch "$BATS_TMP_DIR/foo.txt"
  bats_run_zsh "better-rm $BATS_TMP_DIR/foo.txt"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_TMP_DIR/foo.txt" ]]
}

# --- Glob ---

@test "deletes multiple files via glob" {
  touch "$BATS_TMP_DIR/a.txt" "$BATS_TMP_DIR/b.txt" "$BATS_TMP_DIR/c.txt"
  bats_run_zsh "better-rm $BATS_TMP_DIR/a.txt $BATS_TMP_DIR/b.txt $BATS_TMP_DIR/c.txt"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_TMP_DIR/a.txt" ]]
  [[ ! -e "$BATS_TMP_DIR/b.txt" ]]
  [[ ! -e "$BATS_TMP_DIR/c.txt" ]]
}

# --- Flag compatibility ---

@test "ignores -f flag" {
  touch "$BATS_TMP_DIR/foo.txt"
  bats_run_zsh "better-rm -f $BATS_TMP_DIR/foo.txt"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_TMP_DIR/foo.txt" ]]
}

@test "ignores -r flag" {
  touch "$BATS_TMP_DIR/foo.txt"
  bats_run_zsh "better-rm -r $BATS_TMP_DIR/foo.txt"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_TMP_DIR/foo.txt" ]]
}

@test "ignores -rf combined flag" {
  touch "$BATS_TMP_DIR/foo.txt"
  bats_run_zsh "better-rm -rf $BATS_TMP_DIR/foo.txt"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_TMP_DIR/foo.txt" ]]
}
