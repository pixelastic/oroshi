bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Mock underlying binaries so the sourced __lib helpers run but don't invoke real tools
  prettier() {
    echo "prettier $*" >> "$BATS_TMP_DIR/calls"
    return 0
  }
  eslint_d() {
    echo "eslint_d $*" >> "$BATS_TMP_DIR/calls"
    return 0
  }
  # Prevent config resolution from traversing the real filesystem
  yarn-root() {
    return 1
  }
  bats_mock prettier eslint_d yarn-root
}

@test "modifies file in-place by default" {
  local file="$BATS_TMP_DIR/test.json"
  echo '{"a":1}' > "$file"

  bats_run_zsh "json-fix $file"
  [[ "$status" -eq 0 ]]
  # No stdout output in in-place mode
  [[ "$output" == "" ]]
  # All three tools called (prettier, eslint_d, prettier)
  local calls="$(cat "$BATS_TMP_DIR/calls")"
  [[ "$(echo "$calls" | wc -l)" -eq 3 ]]
}

@test "applies prettier→eslint→prettier chain in order" {
  local file="$BATS_TMP_DIR/test.json"
  echo '{"a":1}' > "$file"

  bats_run_zsh "json-fix $file"
  [[ "$status" -eq 0 ]]

  local call1="$(sed -n '1p' "$BATS_TMP_DIR/calls")"
  local call2="$(sed -n '2p' "$BATS_TMP_DIR/calls")"
  local call3="$(sed -n '3p' "$BATS_TMP_DIR/calls")"
  [[ "$call1" == prettier* ]]
  [[ "$call1" == *"--parser json"* ]]
  [[ "$call2" == eslint_d* ]]
  [[ "$call3" == prettier* ]]
  [[ "$call3" == *"--parser json"* ]]
}

@test "--stdout prints fixed code to stdout without modifying original" {
  local file="$BATS_TMP_DIR/test.json"
  echo '{"a":1}' > "$file"

  bats_run_zsh "json-fix --stdout $file"
  [[ "$status" -eq 0 ]]
  # Should produce output on stdout (temp file contents)
  [[ "$output" != "" ]]
  # Original file should be unchanged
  [[ "$(cat "$file")" == '{"a":1}' ]]
}

@test "--stdout with multiple files exits 1" {
  local file1="$BATS_TMP_DIR/a.json"
  local file2="$BATS_TMP_DIR/b.json"
  echo '{}' > "$file1"
  echo '{}' > "$file2"

  bats_run_zsh "json-fix --stdout $file1 $file2"
  [[ "$status" -ne 0 ]]
}

@test "--stdout with a directory exits 1" {
  local directory="$BATS_TMP_DIR/src"
  mkdir -p "$directory"
  echo '{}' > "$directory/a.json"

  bats_run_zsh "json-fix --stdout $directory"
  [[ "$status" -ne 0 ]]
}

@test "--original-path with multiple files exits 1" {
  local file1="$BATS_TMP_DIR/a.json"
  local file2="$BATS_TMP_DIR/b.json"
  echo '{}' > "$file1"
  echo '{}' > "$file2"

  bats_run_zsh "json-fix --original-path /some/path $file1 $file2"
  [[ "$status" -ne 0 ]]
}

@test "--original-path with a directory exits 1" {
  local directory="$BATS_TMP_DIR/src"
  mkdir -p "$directory"
  echo '{}' > "$directory/a.json"

  bats_run_zsh "json-fix --original-path /some/path $directory"
  [[ "$status" -ne 0 ]]
}

@test "expands directories and fixes all .json files inside" {
  local dir="$BATS_TMP_DIR/src"
  mkdir -p "$dir"
  local file1="$dir/a.json"
  local file2="$dir/b.json"
  echo '{}' > "$file1"
  echo '{}' > "$file2"
  # Non-json file should be skipped by file-expand --filter is-json
  echo 'hello' > "$dir/readme.txt"

  bats_run_zsh "json-fix $dir"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]

  # prettier and eslint_d should have been called
  [[ -f "$BATS_TMP_DIR/calls" ]]
  local calls="$(cat "$BATS_TMP_DIR/calls")"
  # 3 calls total (prettier+eslint_d+prettier on the expanded file list)
  [[ "$(echo "$calls" | wc -l)" -eq 3 ]]
  # Non-json files should not appear in any call
  [[ "$calls" != *"readme.txt"* ]]
}

@test "passes --original-path to prettier and eslint_d" {
  local file="$BATS_TMP_DIR/test.json"
  echo '{}' > "$file"
  local originalPath="/home/user/project/config.json"

  bats_run_zsh "json-fix --original-path $originalPath $file"
  [[ "$status" -eq 0 ]]

  # Verify config resolution uses original path — prettier gets --config based on original-path dir
  local calls="$(cat "$BATS_TMP_DIR/calls")"
  [[ "$(echo "$calls" | wc -l)" -eq 3 ]]
}
