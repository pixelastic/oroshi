bats_load_library 'helper'

setup() {
  bats_tmp_dir

  mkdir -p "$BATS_TMP_DIR/fzf"
  printf 'foo▮foo 1.2.3\n'   >  "$BATS_TMP_DIR/fzf/packages-apt"
  printf 'bar▮bar 3.0.0\n' >> "$BATS_TMP_DIR/fzf/packages-apt"
  printf 'foo▮foo 1.2.3\n'   >  "$BATS_TMP_DIR/fzf/packages-apt-installed"
  bats_mock_env "OROSHI_TMP_FOLDER" "$BATS_TMP_DIR"
}

teardown() {
  bats_cleanup
}

# fzf-source

@test "fzf-source: outputs all packages from cache" {
  bats_run_zsh "apt-packages --source"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "foo"* ]]
  [[ "${lines[1]}" == "bar"* ]]
}

@test "fzf-source: with --installed outputs only installed packages" {
  bats_run_zsh "apt-packages --source --installed"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "foo▮foo 1.2.3" ]
  [ "${#lines[@]}" -eq 1 ]
}

# fzf-postprocess

@test "fzf-postprocess: extracts package name from selection" {
  bats_run_zsh "printf 'foo▮foo 1.2.3\n' | apt-packages --postprocess"
  [ "$output" = "foo" ]
}

@test "fzf-postprocess: outputs nothing on empty stdin" {
  bats_run_zsh "printf '' | apt-packages --postprocess"
  [ "$output" = "" ]
}

@test "fzf-postprocess: handles multi-line selection" {
  bats_run_zsh "printf 'foo▮foo 1.2.3\nbar▮bar 3.0.0\n' | apt-packages --postprocess"
  [ "${#lines[@]}" -eq 2 ]
  [[ "$output" == *"foo"* ]]
  [[ "$output" == *"bar"* ]]
}
