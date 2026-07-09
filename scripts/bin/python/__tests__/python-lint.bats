bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "--fix with fixable violations: file is reformatted in place and exits 0" {
  local file="$BATS_TMP_DIR/test.py"
  printf 'x=1\n' > "$file"

  bats_run_zsh "python-lint --fix $file"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$file")" == "x = 1" ]]
}

@test "--fix with unfixable violations: fixable parts applied, exits non-zero, reports remaining" {
  local file="$BATS_TMP_DIR/test.py"
  printf 'x=1\n\ndef foo():\n    return undefined_name\n' > "$file"

  bats_run_zsh "python-lint --fix $file"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"F821"* ]]
  [[ "$(cat "$file")" == *"x = 1"* ]]
}

@test "without --fix: file is not modified and violations are reported" {
  local file="$BATS_TMP_DIR/test.py"
  printf 'import os\n' > "$file"

  bats_run_zsh "python-lint $file"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"F401"* ]]
  [[ "$(cat "$file")" == "import os" ]]
}

@test "multi-file: only second file has violations, exits non-zero" {
  local file1="$BATS_TMP_DIR/clean.py"
  local file2="$BATS_TMP_DIR/dirty.py"
  printf 'x = 1\n' > "$file1"
  printf 'import os\n' > "$file2"

  bats_run_zsh "python-lint $file1 $file2"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"F401"* ]]
}

@test "multi-file --fix: both files are reformatted" {
  local file1="$BATS_TMP_DIR/a.py"
  local file2="$BATS_TMP_DIR/b.py"
  printf 'x=1\n' > "$file1"
  printf 'y=2\n' > "$file2"

  bats_run_zsh "python-lint --fix $file1 $file2"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$file1")" == "x = 1" ]]
  [[ "$(cat "$file2")" == "y = 2" ]]
}
