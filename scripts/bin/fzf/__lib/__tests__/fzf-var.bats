bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../fzf-var.zsh'"
  bats_mock_env "OROSHI_TMP_FOLDER" "$BATS_TMP_DIR/tmp"
  bats_mock_env "KITTY_WINDOW_ID" "42"
}

@test "fzf-var-write saves value to disk" {
  bats_run_zsh "${sourcePrefix}; fzf-var-write mykey myvalue"
  [ "$status" -eq 0 ]
  local saved
  saved="$(cat "$BATS_TMP_DIR/tmp/fzf/var/42/mykey")"
  [ "$saved" = "myvalue" ]
}

@test "fzf-var-read returns saved value" {
  mkdir -p "$BATS_TMP_DIR/tmp/fzf/var/42"
  echo "stored" > "$BATS_TMP_DIR/tmp/fzf/var/42/mykey"
  bats_run_zsh "${sourcePrefix}; fzf-var-read mykey"
  [ "$status" -eq 0 ]
  [ "$output" = "stored" ]
}

@test "fzf-var-read returns default when key not found" {
  bats_run_zsh "${sourcePrefix}; fzf-var-read missing fallback"
  [ "$status" -eq 0 ]
  [ "$output" = "fallback" ]
}

@test "fzf-var-read returns empty when key missing and no default" {
  bats_run_zsh "${sourcePrefix}; fzf-var-read missing"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
