bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Mock xml-fix: capture all calls with their arguments
  xml-fix() {
    echo "$*" >> "$BATS_TMP_DIR/calls"
    return 0
  }
  bats_mock xml-fix
  bats_disable_worktree_aware
}

@test "formats an SVG file in place" {
  local file="$BATS_TMP_DIR/test.svg"
  echo '<svg/>' > "$file"

  bats_run_zsh "svg-fix $file"
  [[ "$status" -eq 0 ]]

  local call="$(cat "$BATS_TMP_DIR/calls")"
  [[ "$call" == *"--filter is-svg"* ]]
  [[ "$call" == *"$file"* ]]
}

@test "formats multiple SVG files in place" {
  local file1="$BATS_TMP_DIR/a.svg"
  local file2="$BATS_TMP_DIR/b.svg"
  echo '<svg/>' > "$file1"
  echo '<svg/>' > "$file2"

  bats_run_zsh "svg-fix $file1 $file2"
  [[ "$status" -eq 0 ]]

  local call="$(cat "$BATS_TMP_DIR/calls")"
  [[ "$call" == *"$file1"* ]]
  [[ "$call" == *"$file2"* ]]
}

@test "expands a directory and formats all SVG files" {
  local dir="$BATS_TMP_DIR/src"
  mkdir -p "$dir"
  echo '<svg/>' > "$dir/a.svg"

  bats_run_zsh "svg-fix $dir"
  [[ "$status" -eq 0 ]]

  local call="$(cat "$BATS_TMP_DIR/calls")"
  [[ "$call" == *"--filter is-svg"* ]]
  [[ "$call" == *"$dir"* ]]
}

@test "outputs fixed content to stdout with --stdout" {
  local file="$BATS_TMP_DIR/test.svg"
  echo '<svg/>' > "$file"

  bats_run_zsh "svg-fix --stdout $file"
  [[ "$status" -eq 0 ]]

  local call="$(cat "$BATS_TMP_DIR/calls")"
  [[ "$call" == *"--stdout"* ]]
  [[ "$call" == *"--filter is-svg"* ]]
}

@test "resolves config from real path with --original-path" {
  local file="$BATS_TMP_DIR/test.svg"
  echo '<svg/>' > "$file"
  local originalPath="/real/path.svg"

  bats_run_zsh "svg-fix --original-path $originalPath $file"
  [[ "$status" -eq 0 ]]

  local call="$(cat "$BATS_TMP_DIR/calls")"
  [[ "$call" == *"--original-path $originalPath"* ]]
  [[ "$call" == *"--filter is-svg"* ]]
}

@test "does not modify non-SVG files in a directory" {
  local dir="$BATS_TMP_DIR/src"
  mkdir -p "$dir"
  echo '<svg/>' > "$dir/a.svg"
  echo 'hello' > "$dir/readme.txt"

  bats_run_zsh "svg-fix $dir"
  [[ "$status" -eq 0 ]]

  local call="$(cat "$BATS_TMP_DIR/calls")"
  # xml-fix receives --filter is-svg, so non-SVG files are filtered by xml-fix
  [[ "$call" == *"--filter is-svg"* ]]
}
