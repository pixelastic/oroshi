bats_load_library 'helper'

setup() {
  bats_tmp_dir
  FIXTURE_DIRECTORY="$(cd "${BATS_TEST_DIRNAME}" && pwd)"
}

@test "file argument: formatted content to stdout, original file unchanged" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# clean file\n' > "$file"
  local before="$(cat "$file")"
  bats_run_zsh "zsh-fix $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "# clean file" ]]
  [[ "$(cat "$file")" == "$before" ]]
}

@test "--in-place: file modified in place, nothing to stdout" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# clean file\n' > "$file"
  bats_run_zsh "zsh-fix --in-place $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  [[ "$(cat "$file")" == "# clean file" ]]
}

@test "stdin: formatted content to stdout" {
  bats_run_zsh "printf '# clean file\n' | zsh-fix"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "# clean file" ]]
}

@test "fixture: unformatted input produces expected formatted output" {
  bats_run_zsh "zsh-fix $FIXTURE_DIRECTORY/fixture-unformatted.txt"
  [[ "$status" -eq 0 ]]
  local expected="$(cat "$FIXTURE_DIRECTORY/fixture-formatted.txt")"
  [[ "$output" == "$expected" ]]
}
