bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Mock underlying binaries so the sourced __lib helpers run but don't invoke real tools
  prettier() {
    echo "prettier $*" >> "$BATS_TMP_DIR/calls"
    return 0
  }
  # Prevent config resolution from traversing the real filesystem
  yarn-root() {
    return 1
  }
  bats_mock prettier yarn-root
}

@test "modifies file in-place by default" {
  local file="$BATS_TMP_DIR/test.xml"
  echo '<root/>' > "$file"

  bats_run_zsh "xml-fix $file"
  [[ "$status" -eq 0 ]]
  # No stdout output in in-place mode
  [[ "$output" == "" ]]
  # Single-pass: only one prettier call
  local calls="$(cat "$BATS_TMP_DIR/calls")"
  [[ "$(echo "$calls" | wc -l)" -eq 1 ]]
}

@test "calls prettier with --parser xml" {
  local file="$BATS_TMP_DIR/test.xml"
  echo '<root/>' > "$file"

  bats_run_zsh "xml-fix $file"
  [[ "$status" -eq 0 ]]

  local call="$(cat "$BATS_TMP_DIR/calls")"
  [[ "$call" == prettier* ]]
  [[ "$call" == *"--parser xml"* ]]
}

@test "--stdout prints fixed code to stdout without modifying original" {
  local file="$BATS_TMP_DIR/test.xml"
  echo '<root/>' > "$file"

  bats_run_zsh "xml-fix --stdout $file"
  [[ "$status" -eq 0 ]]
  # Should produce output on stdout (temp file contents)
  [[ "$output" != "" ]]
  # Original file should be unchanged
  [[ "$(cat "$file")" == '<root/>' ]]
}

@test "--stdout with multiple files exits 1" {
  local file1="$BATS_TMP_DIR/a.xml"
  local file2="$BATS_TMP_DIR/b.xml"
  echo '<a/>' > "$file1"
  echo '<b/>' > "$file2"

  bats_run_zsh "xml-fix --stdout $file1 $file2"
  [[ "$status" -ne 0 ]]
}

@test "--stdout with a directory exits 1" {
  local directory="$BATS_TMP_DIR/src"
  mkdir -p "$directory"
  echo '<a/>' > "$directory/a.xml"

  bats_run_zsh "xml-fix --stdout $directory"
  [[ "$status" -ne 0 ]]
}

@test "--original-path with multiple files exits 1" {
  local file1="$BATS_TMP_DIR/a.xml"
  local file2="$BATS_TMP_DIR/b.xml"
  echo '<a/>' > "$file1"
  echo '<b/>' > "$file2"

  bats_run_zsh "xml-fix --original-path /some/path $file1 $file2"
  [[ "$status" -ne 0 ]]
}

@test "--original-path with a directory exits 1" {
  local directory="$BATS_TMP_DIR/src"
  mkdir -p "$directory"
  echo '<a/>' > "$directory/a.xml"

  bats_run_zsh "xml-fix --original-path /some/path $directory"
  [[ "$status" -ne 0 ]]
}

@test "expands directories and fixes all .xml files inside" {
  local dir="$BATS_TMP_DIR/src"
  mkdir -p "$dir"
  echo '<a/>' > "$dir/a.xml"
  echo '<b/>' > "$dir/b.xml"
  # Non-xml file should be skipped by file-expand --filter is-xml
  echo 'hello' > "$dir/readme.txt"

  bats_run_zsh "xml-fix $dir"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]

  # prettier should have been called once on the expanded file list
  [[ -f "$BATS_TMP_DIR/calls" ]]
  local calls="$(cat "$BATS_TMP_DIR/calls")"
  [[ "$(echo "$calls" | wc -l)" -eq 1 ]]
  # Non-xml files should not appear in any call
  [[ "$calls" != *"readme.txt"* ]]
}

@test "fixes multiple files" {
  local file1="$BATS_TMP_DIR/a.xml"
  local file2="$BATS_TMP_DIR/b.xml"
  echo '<a/>' > "$file1"
  echo '<b/>' > "$file2"

  bats_run_zsh "xml-fix $file1 $file2"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]

  # prettier called once with both files
  [[ -f "$BATS_TMP_DIR/calls" ]]
  local calls="$(cat "$BATS_TMP_DIR/calls")"
  [[ "$(echo "$calls" | wc -l)" -eq 1 ]]
}

@test "passes --original-path to prettier" {
  local file="$BATS_TMP_DIR/test.xml"
  echo '<root/>' > "$file"
  local originalDir="$BATS_TMP_DIR/project"
  mkdir -p "$originalDir"
  local originalPath="$originalDir/config.xml"

  bats_run_zsh "xml-fix --original-path $originalPath $file"
  [[ "$status" -eq 0 ]]

  local calls="$(cat "$BATS_TMP_DIR/calls")"
  [[ "$(echo "$calls" | wc -l)" -eq 1 ]]
}
