bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '${OROSHI_ROOT}/tools/term/zsh/config/functions/autoload/git/pullrequest/__lib/merge-gate.zsh'"

  # gh records the arguments of each call, and prints the merge state stored in
  # the merge-state file
  gh() {
    echo "$*" >> "$BATS_TMP_DIR/gh-args"
    echo "{\"mergeStateStatus\": \"$(<"$BATS_TMP_DIR/merge-state")\"}"
  }
  bats_mock gh

  echo "CLEAN" > "$BATS_TMP_DIR/merge-state"
}

# Content of gh-args, one line per gh call
gh_args() {
  cat "$BATS_TMP_DIR/gh-args"
}

# Run the gate on a pull request
run_gate() {
  bats_run_zsh "$sourcePrefix && git-pullrequest-merge-gate $*"
}

@test "passes when the state is clean" {
  run_gate 42
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "stops when the state is blocked, and names it" {
  echo "BLOCKED" > "$BATS_TMP_DIR/merge-state"

  run_gate 42
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"blocked"* ]]
}

@test "stops when the state is unstable, behind, dirty or draft" {
  local state
  for state in unstable behind dirty draft; do
    echo "${state:u}" > "$BATS_TMP_DIR/merge-state"

    run_gate 42
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"$state"* ]]
  done
}

@test "points to git-pullrequest-read in the error" {
  echo "UNSTABLE" > "$BATS_TMP_DIR/merge-state"

  run_gate 42
  [[ "$output" == *"git-pullrequest-read 42"* ]]
}

@test "points to git-pullrequest-read of the same repo with --repo" {
  echo "UNSTABLE" > "$BATS_TMP_DIR/merge-state"

  run_gate 42 --repo pixelastic/imoen
  [[ "$output" == *"git-pullrequest-read 42 --repo pixelastic/imoen"* ]]
}

@test "reads the merge state of another repo with --repo" {
  run_gate 42 --repo pixelastic/imoen
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"pr view 42"*"mergeStateStatus"*"--repo pixelastic/imoen"* ]]
}

@test "stops when gh finds no pull request" {
  gh() { return 1; }
  bats_mock gh

  run_gate 999
  [[ "$status" -ne 0 ]]
}
