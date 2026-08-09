bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# Marks present
@test "outputs one line per symlink in name▮resolvedPath format" {
  # Create a fake OROSHI_MARKPATH with two symlinks
  local markpath="$BATS_TMP_DIR/marks"
  mkdir -p "$markpath"
  mkdir -p "$BATS_TMP_DIR/targets/projectA"
  mkdir -p "$BATS_TMP_DIR/targets/projectB"
  ln -s "$BATS_TMP_DIR/targets/projectA" "$markpath/alpha"
  ln -s "$BATS_TMP_DIR/targets/projectB" "$markpath/beta"

  OROSHI_MARKPATH="$markpath" bats_run_zsh "mark-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]

  # Check each line has exactly 2 fields separated by ▮
  for line in "${lines[@]}"; do
    local fieldCount="$(echo "$line" | awk -F'▮' '{print NF}')"
    [[ "$fieldCount" -eq 2 ]]
  done

  # Check names and paths are present (sorted output for stable comparison)
  local sorted="$(echo "$output" | sort)"
  [[ "$(echo "$sorted" | head -1)" == "alpha▮$BATS_TMP_DIR/targets/projectA" ]]
  [[ "$(echo "$sorted" | tail -1)" == "beta▮$BATS_TMP_DIR/targets/projectB" ]]
}

# Empty OROSHI_MARKPATH
@test "outputs nothing and exits 0 when OROSHI_MARKPATH is empty" {
  local markpath="$BATS_TMP_DIR/marks"
  mkdir -p "$markpath"

  OROSHI_MARKPATH="$markpath" bats_run_zsh "mark-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

# Nonexistent OROSHI_MARKPATH
@test "outputs nothing and exits 0 when OROSHI_MARKPATH does not exist" {
  OROSHI_MARKPATH="$BATS_TMP_DIR/nonexistent" bats_run_zsh "mark-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
