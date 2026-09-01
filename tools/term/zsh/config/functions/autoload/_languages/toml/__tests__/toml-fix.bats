bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Mock eslint_d so the sourced __lib helper runs but doesn't invoke real tools
  eslint_d() {
    echo "eslint_d $*" >> "$BATS_TMP_DIR/calls"
    return 0
  }
  # Prevent config resolution from traversing the real filesystem
  yarn-root() {
    return 1
  }
  bats_mock eslint_d yarn-root
}

@test "modifies file in-place by default" {
  local file="$BATS_TMP_DIR/test.toml"
  echo 'key = "value"' > "$file"

  bats_run_zsh "toml-fix $file"
  [[ "$status" -eq 0 ]]
  # No stdout output in in-place mode
  [[ "$output" == "" ]]
  # eslint_d called once
  local calls="$(cat "$BATS_TMP_DIR/calls")"
  [[ "$(echo "$calls" | wc -l)" -eq 1 ]]
}

@test "--stdout prints fixed content without modifying original" {
  local file="$BATS_TMP_DIR/test.toml"
  echo 'key = "value"' > "$file"

  bats_run_zsh "toml-fix --stdout $file"
  [[ "$status" -eq 0 ]]
  # Should produce output on stdout (temp file contents)
  [[ "$output" != "" ]]
  # Original file should be unchanged
  [[ "$(cat "$file")" == 'key = "value"' ]]
}

@test "--stdout with multiple files exits 1" {
  local file1="$BATS_TMP_DIR/a.toml"
  local file2="$BATS_TMP_DIR/b.toml"
  echo 'a = 1' > "$file1"
  echo 'b = 2' > "$file2"

  bats_run_zsh "toml-fix --stdout $file1 $file2"
  [[ "$status" -ne 0 ]]
}

@test "expands directories and fixes all .toml files inside" {
  local dir="$BATS_TMP_DIR/src"
  mkdir -p "$dir"
  local file1="$dir/a.toml"
  local file2="$dir/b.toml"
  echo 'a = 1' > "$file1"
  echo 'b = 2' > "$file2"
  # Non-toml file should be skipped by file-expand --filter is-toml
  echo 'hello' > "$dir/readme.txt"

  bats_run_zsh "toml-fix $dir"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]

  # eslint_d should have been called
  [[ -f "$BATS_TMP_DIR/calls" ]]
  local calls="$(cat "$BATS_TMP_DIR/calls")"
  [[ "$(echo "$calls" | wc -l)" -eq 1 ]]
  # Non-toml files should not appear in any call
  [[ "$calls" != *"readme.txt"* ]]
}
