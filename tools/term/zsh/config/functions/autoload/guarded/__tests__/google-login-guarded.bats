bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "prints that the command is interactive and cannot run from an agent" {
  bats_run_zsh "google-login-guarded 2>&1"
  [[ "$output" == *"google-login is interactive"* ]]
  [[ "$output" == *"opens a browser"* ]]
  [[ "$output" == *"An agent cannot run it"* ]]
}

@test "tells the agent to ask the user to run google-login" {
  bats_run_zsh "google-login-guarded 2>&1"
  [[ "$output" == *"Ask the user to run google-login in their own shell"* ]]
}

@test "exits with code 1" {
  bats_run_zsh "google-login-guarded"
  [[ "$status" -eq 1 ]]
}

@test "ignores the flags it receives" {
  bats_run_zsh "google-login-guarded --perso 2>&1"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"google-login is interactive"* ]]
}

@test "starts no browser and no login flow" {
  local marker="$BATS_TMP_DIR/started"
  bats_run_zsh "
    google-login() { touch '$marker'; }
    xdg-open() { touch '$marker'; }
    open() { touch '$marker'; }
    google-login-guarded --perso
  "
  [[ "$status" -eq 1 ]]
  [[ ! -e "$marker" ]]
}
