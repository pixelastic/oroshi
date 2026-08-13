bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "exits 1 when plan directory doesn't exist" {
  bats_run_zsh "plan-end /nonexistent/path"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"plan directory"* ]]
}

@test "calls git-file-add with plan directory" {
  local planDirectory="$BATS_TMP_DIR/plans/my-plan"
  mkdir -p "$planDirectory"

  git-file-add() { echo "$1" > "$BATS_TMP_DIR/added.txt"; }
  git-commit-message() { echo "plan(my-plan): do stuff"; }
  git-commit-create() { :; }
  claude-stop() { :; }
  bats_mock git-file-add git-commit-message git-commit-create claude-stop

  bats_run_zsh "plan-end $planDirectory"
  [[ "$(cat "$BATS_TMP_DIR/added.txt")" == "$planDirectory" ]]
}

@test "calls git-commit-message for the commit message" {
  local planDirectory="$BATS_TMP_DIR/plans/my-plan"
  mkdir -p "$planDirectory"

  git-file-add() { :; }
  git-commit-message() {
    echo "generated-message" > "$BATS_TMP_DIR/message-called.txt"
    echo "generated-message"
  }
  git-commit-create() { :; }
  claude-stop() { :; }
  bats_mock git-file-add git-commit-message git-commit-create claude-stop

  bats_run_zsh "plan-end $planDirectory"
  [[ -f "$BATS_TMP_DIR/message-called.txt" ]]
}

@test "creates a commit with generated message" {
  local planDirectory="$BATS_TMP_DIR/plans/my-plan"
  mkdir -p "$planDirectory"

  git-file-add() { :; }
  git-commit-message() { echo "plan(my-plan): do stuff"; }
  git-commit-create() { echo "$1" > "$BATS_TMP_DIR/committed.txt"; }
  claude-stop() { :; }
  bats_mock git-file-add git-commit-message git-commit-create claude-stop

  bats_run_zsh "plan-end $planDirectory"
  [[ "$(cat "$BATS_TMP_DIR/committed.txt")" == "plan(my-plan): do stuff" ]]
}
