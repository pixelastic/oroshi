bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# --- Files ---

@test "sets file permissions to 664" {
  touch "$BATS_TMP_DIR/foo.txt"
  chmod 000 "$BATS_TMP_DIR/foo.txt"
  bats_run_zsh "chmod-default $BATS_TMP_DIR/foo.txt"
  [[ "$status" -eq 0 ]]
  local perms
  perms="$(stat -c '%a' "$BATS_TMP_DIR/foo.txt")"
  [[ "$perms" == "664" ]]
}

# --- Directories ---

@test "sets directory permissions to 775" {
  mkdir "$BATS_TMP_DIR/mydir"
  chmod 000 "$BATS_TMP_DIR/mydir"
  bats_run_zsh "chmod-default $BATS_TMP_DIR/mydir"
  [[ "$status" -eq 0 ]]
  local perms
  perms="$(stat -c '%a' "$BATS_TMP_DIR/mydir")"
  [[ "$perms" == "775" ]]
}

# --- Multiple targets ---

@test "handles multiple targets" {
  touch "$BATS_TMP_DIR/a.txt" "$BATS_TMP_DIR/b.txt"
  chmod 000 "$BATS_TMP_DIR/a.txt" "$BATS_TMP_DIR/b.txt"
  bats_run_zsh "chmod-default $BATS_TMP_DIR/a.txt $BATS_TMP_DIR/b.txt"
  [[ "$status" -eq 0 ]]
  [[ "$(stat -c '%a' "$BATS_TMP_DIR/a.txt")" == "664" ]]
  [[ "$(stat -c '%a' "$BATS_TMP_DIR/b.txt")" == "664" ]]
}

# --- Recursive ---

@test "recursively chmods with -r flag" {
  mkdir -p "$BATS_TMP_DIR/parent/child"
  touch "$BATS_TMP_DIR/parent/file.txt"
  touch "$BATS_TMP_DIR/parent/child/nested.txt"
  # chmod leaf-first to avoid permission lockout
  chmod 600 "$BATS_TMP_DIR/parent/child/nested.txt"
  chmod 600 "$BATS_TMP_DIR/parent/file.txt"
  chmod 700 "$BATS_TMP_DIR/parent/child"
  chmod 700 "$BATS_TMP_DIR/parent"
  bats_run_zsh "chmod-default -r $BATS_TMP_DIR/parent"
  [[ "$status" -eq 0 ]]
  [[ "$(stat -c '%a' "$BATS_TMP_DIR/parent")" == "775" ]]
  [[ "$(stat -c '%a' "$BATS_TMP_DIR/parent/child")" == "775" ]]
  [[ "$(stat -c '%a' "$BATS_TMP_DIR/parent/file.txt")" == "664" ]]
  [[ "$(stat -c '%a' "$BATS_TMP_DIR/parent/child/nested.txt")" == "664" ]]
}

# --- Non-recursive by default ---

@test "does not recurse without -r flag" {
  mkdir -p "$BATS_TMP_DIR/parent"
  touch "$BATS_TMP_DIR/parent/file.txt"
  chmod 600 "$BATS_TMP_DIR/parent/file.txt"
  chmod 700 "$BATS_TMP_DIR/parent"
  bats_run_zsh "chmod-default $BATS_TMP_DIR/parent"
  [[ "$status" -eq 0 ]]
  [[ "$(stat -c '%a' "$BATS_TMP_DIR/parent")" == "775" ]]
  # Inner file should be untouched
  [[ "$(stat -c '%a' "$BATS_TMP_DIR/parent/file.txt")" == "600" ]]
}

# --- Non-existent paths ---

@test "silently skips non-existent paths" {
  bats_run_zsh "chmod-default $BATS_TMP_DIR/does-not-exist"
  [[ "$status" -eq 0 ]]
}
