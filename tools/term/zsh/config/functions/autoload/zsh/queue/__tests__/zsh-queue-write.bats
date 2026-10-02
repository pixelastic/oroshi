bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env OROSHI_FOLDER_STATE "$BATS_TMP_DIR"
}

@test "queued command can be read back" {
  bats_run_zsh "export KITTY_WINDOW_ID=42; zsh-queue-write 'echo hello' && zsh-queue-read"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "echo hello" ]]
}

@test "second write replaces the first command" {
  bats_run_zsh "export KITTY_WINDOW_ID=42; zsh-queue-write 'echo first' && zsh-queue-write 'echo second' && zsh-queue-read"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "echo second" ]]
}

@test "fails when command is empty" {
  bats_run_zsh "export KITTY_WINDOW_ID=42; zsh-queue-write ''"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Usage"* ]]
}

@test "succeeds without queuing when outside Kitty" {
  bats_run_zsh "unset KITTY_WINDOW_ID; zsh-queue-write 'echo hello'"
  [[ "$status" -eq 0 ]]

  bats_run_zsh "export KITTY_WINDOW_ID=42; zsh-queue-read"
  [[ "$status" -eq 1 ]]
  [[ ! -d "$BATS_TMP_DIR/zsh-queue" ]]
}

@test "command queued for one window is not visible from another" {
  bats_run_zsh "export KITTY_WINDOW_ID=42; zsh-queue-write 'echo hello'"

  bats_run_zsh "export KITTY_WINDOW_ID=43; zsh-queue-read"
  [[ "$status" -eq 1 ]]
  [[ "$output" == "" ]]
}

@test "queued command keeps backslashes verbatim" {
  export QUEUED='printf "a\tb\n"'
  bats_run_zsh 'export KITTY_WINDOW_ID=42; zsh-queue-write "$QUEUED" && zsh-queue-read'
  [[ "$status" -eq 0 ]]
  [[ "$output" == 'printf "a\tb\n"' ]]
}
