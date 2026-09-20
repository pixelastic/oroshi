bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "calls notion page set with isProcessed=true for given page ID" {
  notion() { echo "$@" > "$BATS_TMP_DIR/notion-args.txt"; }
  bats_mock notion

  bats_run_zsh "phone-pickup-done abc-123"
  [[ "$status" -eq 0 ]]

  local args="$(cat "$BATS_TMP_DIR/notion-args.txt")"
  [[ "$args" == *"page set"* ]]
  [[ "$args" == *"abc-123"* ]]
  [[ "$args" == *"isProcessed=true"* ]]
}

@test "produces no output on success" {
  notion() { :; }
  bats_mock notion

  bats_run_zsh "phone-pickup-done abc-123"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "exits non-zero with error message when called without arguments" {
  bats_run_zsh "phone-pickup-done"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Usage"* ]]
}
