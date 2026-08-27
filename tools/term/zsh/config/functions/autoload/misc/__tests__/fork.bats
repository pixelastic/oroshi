bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # prompt-pid and prompt-redraw depend on a live terminal — mock to no-ops
  prompt-pid() { echo "0"; }
  prompt-redraw() { :; }
  bats_mock prompt-pid prompt-redraw
}

@test "returns 1 and prints error when no lockfile argument is provided" {
  bats_run_zsh "fork 'echo hello'"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"lockfile"* ]]
}

@test "returns 0 and does not run the command when lockfile already exists" {
  local lockfile="$BATS_TMP_DIR/lock"
  local side_effect="$BATS_TMP_DIR/side-effect"
  touch "$lockfile"

  bats_run_zsh "fork 'touch $side_effect' $lockfile"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$side_effect" ]]
}

@test "runs the command in the background" {
  local lockfile="$BATS_TMP_DIR/lock"
  local side_effect="$BATS_TMP_DIR/side-effect"

  bats_run_zsh "fork 'touch $side_effect' $lockfile"
  [[ "$status" -eq 0 ]]

  # Poll for the side-effect file created by the background command
  local i=0
  while [[ ! -f "$side_effect" ]] && (( i < 50 )); do
    sleep 0.1
    (( i++ ))
  done
  [[ -f "$side_effect" ]]
}

@test "creates lockfile during execution and removes it after completion" {
  local lockfile="$BATS_TMP_DIR/lock"
  # Command that writes proof the lockfile existed, then sleeps briefly
  local cmd="[[ -f $lockfile ]] && touch $BATS_TMP_DIR/lockfile-seen"

  bats_run_zsh "fork '$cmd' $lockfile"
  [[ "$status" -eq 0 ]]

  # Poll for completion
  local i=0
  while [[ -f "$lockfile" ]] && (( i < 50 )); do
    sleep 0.1
    (( i++ ))
  done

  # Lockfile was present when the command ran
  [[ -f "$BATS_TMP_DIR/lockfile-seen" ]]
  # Lockfile removed after completion
  [[ ! -f "$lockfile" ]]
}
