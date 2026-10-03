bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "formats a file in place and prints nothing" {
  local file="$BATS_TMP_DIR/messy.py"
  printf 'x   =   1\n' > "$file"

  bats_run_zsh "python-fix $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  [[ "$(cat "$file")" == "x = 1" ]]
}

@test "applies ruff autofixes: removes an unused import" {
  local file="$BATS_TMP_DIR/unused.py"
  printf 'import os\n\nx = 1\n' > "$file"

  bats_run_zsh "python-fix $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  [[ "$(cat "$file")" == "x = 1" ]]
}

@test "accepts several files and fixes each" {
  local file1="$BATS_TMP_DIR/a.py"
  local file2="$BATS_TMP_DIR/b.py"
  printf 'a   =   1\n' > "$file1"
  printf 'b   =   2\n' > "$file2"

  bats_run_zsh "python-fix $file1 $file2"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  [[ "$(cat "$file1")" == "a = 1" ]]
  [[ "$(cat "$file2")" == "b = 2" ]]
}

@test "accepts a directory and fixes its Python files" {
  local dir="$BATS_TMP_DIR/pkg"
  mkdir -p "$dir"
  printf 'a   =   1\n' > "$dir/a.py"
  printf 'b   =   2\n' > "$dir/b.py"

  bats_run_zsh "python-fix $dir"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  [[ "$(cat "$dir/a.py")" == "a = 1" ]]
  [[ "$(cat "$dir/b.py")" == "b = 2" ]]
}

@test "skips non-Python files silently" {
  local file="$BATS_TMP_DIR/notes.txt"
  printf 'x   =   1\n' > "$file"

  bats_run_zsh "python-fix $file 2>&1"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  [[ "$(cat "$file")" == "x   =   1" ]]
}

@test "--stdout prints the fixed code and leaves the file unchanged" {
  local file="$BATS_TMP_DIR/messy.py"
  printf 'import os\n\nx   =   1\n' > "$file"

  bats_run_zsh "python-fix --stdout $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "x = 1" ]]
  [[ "$(cat "$file")" == *"import os"* ]]
}

@test "--original-path resolves config from the original path" {
  local projectDir="$BATS_TMP_DIR/project"
  local scratchDir="$BATS_TMP_DIR/scratch"
  mkdir -p "$projectDir" "$scratchDir"
  printf 'line-length = 40\n' > "$projectDir/ruff.toml"
  # 45 characters: fits the global limit, exceeds the project limit
  local code='x = ["aaaaaaaaaaaaaaaa", "bbbbbbbbbbbbbbbbbb"]'
  printf '%s\n' "$code" > "$scratchDir/temporary.py"

  bats_run_zsh "python-fix --original-path $projectDir/real.py $scratchDir/temporary.py"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  # The temporary copy is rewritten using the project config
  [[ "$(wc --lines < "$scratchDir/temporary.py")" -eq 4 ]]
}

@test "--original-path combined with --stdout leaves the file unchanged" {
  local projectDir="$BATS_TMP_DIR/project"
  local scratchDir="$BATS_TMP_DIR/scratch"
  mkdir -p "$projectDir" "$scratchDir"
  printf 'line-length = 40\n' > "$projectDir/ruff.toml"
  local code='x = ["aaaaaaaaaaaaaaaa", "bbbbbbbbbbbbbbbbbb"]'
  printf '%s\n' "$code" > "$scratchDir/temporary.py"

  bats_run_zsh "python-fix --stdout --original-path $projectDir/real.py $scratchDir/temporary.py"
  [[ "$status" -eq 0 ]]
  [[ "$(printf '%s\n' "$output" | wc --lines)" -eq 4 ]]
  [[ "$(cat "$scratchDir/temporary.py")" == "$code" ]]
}

@test "--stdout with several files: error on stderr, exits 1" {
  local file1="$BATS_TMP_DIR/a.py"
  local file2="$BATS_TMP_DIR/b.py"
  printf 'a   =   1\n' > "$file1"
  printf 'b   =   2\n' > "$file2"

  bats_run_zsh "python-fix --stdout $file1 $file2 2>&1"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"single file"* ]]
  [[ "$(cat "$file1")" == "a   =   1" ]]
}

@test "--original-path with a directory: error on stderr, exits 1" {
  local dir="$BATS_TMP_DIR/pkg"
  mkdir -p "$dir"
  printf 'a   =   1\n' > "$dir/a.py"

  bats_run_zsh "python-fix --original-path $dir/a.py $dir 2>&1"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"single file"* ]]
  [[ "$(cat "$dir/a.py")" == "a   =   1" ]]
}

@test "file ruff cannot parse: error on stderr, exits 1" {
  local file="$BATS_TMP_DIR/broken.py"
  printf 'def (:\n' > "$file"

  bats_run_zsh "python-fix $file 2>&1 >/dev/null"
  [[ "$status" -eq 1 ]]
  [[ "$output" != "" ]]
}

@test "--stdout on a file ruff cannot parse: error on stderr, exits 1" {
  local file="$BATS_TMP_DIR/broken.py"
  printf 'def (:\n' > "$file"

  bats_run_zsh "python-fix --stdout $file 2>&1 >/dev/null"
  [[ "$status" -eq 1 ]]
  [[ "$output" != "" ]]
}

@test "nothing to fix: exits 0 with no output" {
  local file="$BATS_TMP_DIR/clean.py"
  printf 'x = 1\n' > "$file"

  bats_run_zsh "python-fix $file 2>&1"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  [[ "$(cat "$file")" == "x = 1" ]]
}

@test "no matching file: exits 0 with no output" {
  bats_run_zsh "python-fix $BATS_TMP_DIR/missing.py 2>&1"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
