bats_load_library 'helper'

setup() {
  bats_tmp_dir
  mkdir -p "$BATS_TMP_DIR/plans/plan-a/issues"
  mkdir -p "$BATS_TMP_DIR/plans/plan-b"

  fzf-var-read() { echo "$BATS_TMP_DIR/plans"; }
  bats_mock fzf-var-read

  fzf-fs-shared-zsh-filters() { echo ""; }
  bats_mock fzf-fs-shared-zsh-filters

  simplify-path() { REPLY="$2"; }
  bats_mock simplify-path
}

teardown() {
  bats_cleanup
}

@test "shows only direct subdirectories, not nested ones" {
  bats_run_function fzf-fs-directories-ralph-source
  [ "$status" -eq 0 ]
  [[ "$output" == *"plan-a"* ]]
  [[ "$output" != *"issues"* ]]
}
