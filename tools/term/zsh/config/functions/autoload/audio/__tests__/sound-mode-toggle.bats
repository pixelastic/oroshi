bats_load_library 'helper'

setup() {
  STORE_DIR="$HOME/local/tmp/oroshi/sound-mode"
  STORE_FILE="$STORE_DIR/on"
  # Save original state
  ORIGINAL_STATE=""
  [[ -f "$STORE_FILE" ]] && ORIGINAL_STATE="on"
}

teardown() {
  # Restore original state
  if [[ "$ORIGINAL_STATE" == "on" ]]; then
    mkdir -p "$STORE_DIR"
    touch "$STORE_FILE"
  else
    rm -f "$STORE_FILE"
  fi
}

@test "creates store file when sound mode is off" {
  rm -f "$STORE_FILE"

  bats_run_zsh "sound-mode-toggle"
  [[ "$status" -eq 0 ]]
  [[ -f "$STORE_FILE" ]]
}

@test "removes store file when sound mode is on" {
  mkdir -p "$STORE_DIR"
  touch "$STORE_FILE"

  bats_run_zsh "sound-mode-toggle"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$STORE_FILE" ]]
}
