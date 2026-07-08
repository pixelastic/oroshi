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
