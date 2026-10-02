bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env "OROSHI_FOLDER_STATE" "$BATS_TMP_DIR"
  LOCK_DIR="$BATS_TMP_DIR/bin-debounce/my-key"
}

@test "returns 2 and prints error when no key is provided" {
  bats_run_zsh "bin-debounce"
  [[ "$status" -eq 2 ]]
  [[ "$output" == *"key"* ]]
}

@test "returns 0 and creates the lock on first call" {
  bats_run_zsh "bin-debounce my-key"
  [[ "$status" -eq 0 ]]
  [[ -d "$LOCK_DIR" ]]
}

@test "returns 1 when called again right away" {
  bats_run_zsh "bin-debounce my-key"
  bats_run_zsh "bin-debounce my-key"
  [[ "$status" -eq 1 ]]
}

@test "returns 0 for a different key" {
  bats_run_zsh "bin-debounce my-key"
  bats_run_zsh "bin-debounce other-key"
  [[ "$status" -eq 0 ]]
}

@test "returns 0 and refreshes the lock when it is older than the default wait" {
  mkdir -p "$LOCK_DIR"
  touch --date="-3 seconds" "$LOCK_DIR"

  bats_run_zsh "bin-debounce my-key"
  [[ "$status" -eq 0 ]]
  bats_run_zsh "bin-debounce my-key"
  [[ "$status" -eq 1 ]]
}

@test "returns 1 when the lock is younger than --wait" {
  mkdir -p "$LOCK_DIR"
  touch --date="-5 seconds" "$LOCK_DIR"

  bats_run_zsh "bin-debounce my-key --wait 10"
  [[ "$status" -eq 1 ]]
}

@test "returns 0 when the lock is older than --wait" {
  mkdir -p "$LOCK_DIR"
  touch --date="-5 seconds" "$LOCK_DIR"

  bats_run_zsh "bin-debounce my-key --wait 3"
  [[ "$status" -eq 0 ]]
}

@test "only one of several concurrent calls returns 0" {
  local i
  for i in {1..5}; do
    (zsh -c "bin-debounce my-key && touch $BATS_TMP_DIR/ran-$i" || true) &
  done
  wait

  run bash -c "ls $BATS_TMP_DIR | grep -c '^ran-'"
  [[ "$output" = "1" ]]
}
