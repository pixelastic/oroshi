bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Create a directory structure for testing
  mkdir -p "$BATS_TMP_DIR/project/src"
  mkdir -p "$BATS_TMP_DIR/project/lib"
  echo "a" > "$BATS_TMP_DIR/project/src/main.go"
  echo "b" > "$BATS_TMP_DIR/project/src/util.go"
  echo "c" > "$BATS_TMP_DIR/project/lib/helper.sh"
  echo "d" > "$BATS_TMP_DIR/standalone.txt"

  # Empty directory
  mkdir -p "$BATS_TMP_DIR/empty"
}

# --- Basic expansion ---

@test "expands a directory to all files inside it recursively" {
  bats_run_zsh "file-expand $BATS_TMP_DIR/project"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"$BATS_TMP_DIR/project/src/main.go"* ]]
  [[ "$output" == *"$BATS_TMP_DIR/project/src/util.go"* ]]
  [[ "$output" == *"$BATS_TMP_DIR/project/lib/helper.sh"* ]]
}

@test "passes individual files through unchanged" {
  bats_run_zsh "file-expand $BATS_TMP_DIR/standalone.txt"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$BATS_TMP_DIR/standalone.txt" ]]
}

@test "mixed files and directories works correctly" {
  bats_run_zsh "file-expand $BATS_TMP_DIR/standalone.txt $BATS_TMP_DIR/project/src"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"$BATS_TMP_DIR/standalone.txt"* ]]
  [[ "$output" == *"$BATS_TMP_DIR/project/src/main.go"* ]]
  [[ "$output" == *"$BATS_TMP_DIR/project/src/util.go"* ]]
}

@test "output paths are absolute" {
  bats_run_zsh "file-expand $BATS_TMP_DIR/standalone.txt"
  [[ "$status" -eq 0 ]]
  # Every line starts with /
  while IFS= read -r line; do
    [[ "$line" == /* ]]
  done <<< "$output"
}

# --- Filtering ---

@test "--filter keeps only files where command returns 0" {
  # Create a filter that only accepts .go files
  cat > "$BATS_TMP_DIR/is-go" << 'SCRIPT'
#!/usr/bin/env zsh
[[ "$1" == *.go ]]
SCRIPT
  chmod +x "$BATS_TMP_DIR/is-go"

  bats_run_zsh "file-expand --filter $BATS_TMP_DIR/is-go $BATS_TMP_DIR/project"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"main.go"* ]]
  [[ "$output" == *"util.go"* ]]
  [[ "$output" != *"helper.sh"* ]]
}

@test "--filter silently drops files where command returns non-zero" {
  # Create a filter that rejects everything
  cat > "$BATS_TMP_DIR/reject-all" << 'SCRIPT'
#!/usr/bin/env zsh
exit 1
SCRIPT
  chmod +x "$BATS_TMP_DIR/reject-all"

  bats_run_zsh "file-expand --filter $BATS_TMP_DIR/reject-all $BATS_TMP_DIR/project"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "without --filter all files pass through" {
  bats_run_zsh "file-expand $BATS_TMP_DIR/project"
  [[ "$status" -eq 0 ]]
  local lineCount=$(echo "$output" | wc -l)
  [[ "$lineCount" -eq 3 ]]
}

# --- Mapping ---

@test "--map transforms each path through the command" {
  # Create a mapper that appends .bak
  cat > "$BATS_TMP_DIR/add-bak" << 'SCRIPT'
#!/usr/bin/env zsh
echo "${1}.bak"
SCRIPT
  chmod +x "$BATS_TMP_DIR/add-bak"

  bats_run_zsh "file-expand --map $BATS_TMP_DIR/add-bak $BATS_TMP_DIR/standalone.txt"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$BATS_TMP_DIR/standalone.txt.bak" ]]
}

@test "--map silently skips files where command fails" {
  # Create a mapper that fails on .sh files
  cat > "$BATS_TMP_DIR/fail-on-sh" << 'SCRIPT'
#!/usr/bin/env zsh
[[ "$1" != *.sh ]] && echo "$1" || exit 1
SCRIPT
  chmod +x "$BATS_TMP_DIR/fail-on-sh"

  bats_run_zsh "file-expand --map $BATS_TMP_DIR/fail-on-sh $BATS_TMP_DIR/project"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"main.go"* ]]
  [[ "$output" != *"helper.sh"* ]]
}

@test "--map deduplicates output" {
  # Create a mapper that maps everything to the same path
  cat > "$BATS_TMP_DIR/to-same" << 'SCRIPT'
#!/usr/bin/env zsh
echo "/tmp/same.txt"
SCRIPT
  chmod +x "$BATS_TMP_DIR/to-same"

  bats_run_zsh "file-expand --map $BATS_TMP_DIR/to-same $BATS_TMP_DIR/project"
  [[ "$status" -eq 0 ]]
  local lineCount=$(echo "$output" | wc -l)
  [[ "$lineCount" -eq 1 ]]
}

@test "without --map paths pass through unchanged" {
  bats_run_zsh "file-expand $BATS_TMP_DIR/standalone.txt"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$BATS_TMP_DIR/standalone.txt" ]]
}

# --- Edge cases ---

@test "no arguments produces no output" {
  bats_run_zsh "file-expand"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "empty directory produces no output" {
  bats_run_zsh "file-expand $BATS_TMP_DIR/empty"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
