bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Make sure there is a plan directory
  export PRD_DIR="$BATS_TMP_DIR/plans/feature"
  mkdir -p "$PRD_DIR"

  # Source the ralph-single.zsh before each command
  sourcePrefix="source '$BATS_TEST_DIRNAME/../__lib/ralph-single.zsh'"
}

teardown() { bats_cleanup; }

@test "refuses to run when a session is already active" {
  ralph-is-running() { return 0; }
  bats_mock ralph-is-running

  bats_run_zsh "${sourcePrefix}; ralph-single '$PRD_DIR'"
  [ "$status" -eq 1 ]
}

@test "creates ralph.json before launching Claude" {
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { [ -f "$PRD_DIR/ralph.json" ]; }
  bats_mock ralph-is-running git-directory-root claude

  bats_run_zsh "${sourcePrefix}; ralph-single '$PRD_DIR'"
  [ "$status" -eq 0 ]
}

@test "clears ralph.json after Claude exits (happy path)" {
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { return 0; }
  bats_mock ralph-is-running git-directory-root claude

  bats_run_zsh "${sourcePrefix}; ralph-single '$PRD_DIR'"
  [ "$status" -eq 0 ]
  [ ! -f "$PRD_DIR/ralph.json" ]
}

@test "clears ralph.json after Claude exits with non-zero status" {
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() {
    touch "$BATS_TMP_DIR/claude-called"
    return 1
  }
  bats_mock ralph-is-running git-directory-root claude

  bats_run_zsh "${sourcePrefix}; ralph-single '$PRD_DIR'"
  [ -f "$BATS_TMP_DIR/claude-called" ]
  [ ! -f "$PRD_DIR/ralph.json" ]
}

@test "calls Claude with the correct plan directory argument" {
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { echo "ARGS:$*"; }
  ralph-state() { true; }
  bats_mock ralph-is-running git-directory-root claude ralph-state

  bats_run_zsh "${sourcePrefix}; ralph-single '$PRD_DIR'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"/ralph ${PRD_DIR}"* ]]
}
