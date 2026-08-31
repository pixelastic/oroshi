bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Default: no claude processes
  process-find() { :; }
  process-kill() { echo "$@" >> "$BATS_TMP_DIR/killed-pids.txt"; }
  bats_mock process-find process-kill
}

# --- No processes ---

@test "returns 0 when no claude processes exist" {
  bats_run_zsh "claude-stop-in '$BATS_TMP_DIR'"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/killed-pids.txt" ]]
}

# --- No matching processes ---

@test "returns 0 when no claude processes match the target path" {
  process-find() {
    echo "100"
    echo "200"
  }
  process-cwd() { echo "/some/other/path"; }
  bats_mock process-find process-cwd

  bats_run_zsh "claude-stop-in '$BATS_TMP_DIR'"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/killed-pids.txt" ]]
}

# --- Matching processes ---

@test "SIGTERMs claude process whose CWD matches the target path" {
  process-find() { echo "100"; }
  process-cwd() { echo "$BATS_TMP_DIR"; }
  bats_mock process-find process-cwd

  bats_run_zsh "claude-stop-in '$BATS_TMP_DIR'"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/killed-pids.txt")" == *"100"* ]]
}

@test "SIGTERMs claude process in a subdirectory of the target" {
  process-find() { echo "100"; }
  process-cwd() { echo "$BATS_TMP_DIR/subdir"; }
  bats_mock process-find process-cwd

  bats_run_zsh "claude-stop-in '$BATS_TMP_DIR'"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/killed-pids.txt")" == *"100"* ]]
}

@test "does not kill claude processes in unrelated directories" {
  process-find() {
    echo "100"
    echo "200"
  }
  process-cwd() {
    # PID 100: unrelated path, PID 200: matching path
    if [[ "$1" == "100" ]]; then
      echo "/unrelated/path"
    else
      echo "$BATS_TMP_DIR"
    fi
  }
  bats_mock process-find process-cwd

  bats_run_zsh "claude-stop-in '$BATS_TMP_DIR'"
  [[ "$status" -eq 0 ]]
  local killArgs="$(cat "$BATS_TMP_DIR/killed-pids.txt")"
  [[ "$killArgs" != *"100"* ]]
  [[ "$killArgs" == *"200"* ]]
}

@test "stops multiple matching processes" {
  process-find() {
    echo "100"
    echo "200"
  }
  process-cwd() { echo "$BATS_TMP_DIR"; }
  bats_mock process-find process-cwd

  bats_run_zsh "claude-stop-in '$BATS_TMP_DIR'"
  [[ "$status" -eq 0 ]]
  local killArgs="$(cat "$BATS_TMP_DIR/killed-pids.txt")"
  [[ "$killArgs" == *"100"* ]]
  [[ "$killArgs" == *"200"* ]]
}

# --- Missing argument ---

@test "returns 1 when no path argument given" {
  bats_run_zsh "claude-stop-in"
  [[ "$status" -eq 1 ]]
}
