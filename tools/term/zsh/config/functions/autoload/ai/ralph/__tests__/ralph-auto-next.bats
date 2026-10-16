bats_load_library 'helper'

setup() {
  bats_tmp_dir
  mkdir -p "$BATS_TMP_DIR/prd-dir"
  export PRD_DIR="$BATS_TMP_DIR/prd-dir"
  export CALLS="$BATS_TMP_DIR/calls"
}

# Mocks the collaborators. The commit, ralph and claude log their calls to $CALLS, in order.
mock_collaborators() {
  git-commit-create-all-auto() {
    echo "commit" >>"$CALLS"
    return "${COMMIT_STATUS:-0}"
  }
  ralph() { echo "ralph $*" >>"$CALLS"; }
  plan-directory() { echo "$PRD_DIR"; }
  plan-progress() { echo "${PROGRESS:-1▮3}"; }
  claude() { echo "claude $*" >>"$CALLS"; }
  bats_mock git-commit-create-all-auto ralph plan-directory plan-progress claude
}

@test "runs the review in auto permission mode after the last issue" {
  mock_collaborators
  export PROGRESS="3▮3"
  bats_run_zsh "ralph-auto-next $PRD_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$(tail -n 1 "$CALLS")" == "claude --permission-mode auto /ralph-review $PRD_DIR" ]]
}

@test "does not run ralph --auto after the last issue" {
  mock_collaborators
  export PROGRESS="3▮3"
  bats_run_zsh "ralph-auto-next $PRD_DIR"
  [[ "$(cat "$CALLS")" != *"ralph --auto"* ]]
}

@test "stops after the commit when the plan has no progress" {
  mock_collaborators
  plan-progress() { return 1; }
  bats_mock plan-progress
  bats_run_zsh "ralph-auto-next $PRD_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$CALLS")" == "commit" ]]
}

@test "does not run the review while issues remain" {
  mock_collaborators
  export PROGRESS="1▮3"
  bats_run_zsh "ralph-auto-next $PRD_DIR"
  [[ "$(cat "$CALLS")" != *"claude"* ]]
}

@test "runs the commit, then ralph --auto with the given directory" {
  mock_collaborators
  bats_run_zsh "ralph-auto-next $PRD_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$CALLS")" == $'commit\nralph --auto '"$PRD_DIR" ]]
}

@test "does not run ralph --auto when the commit fails" {
  mock_collaborators
  export COMMIT_STATUS=1
  bats_run_zsh "ralph-auto-next $PRD_DIR"
  [[ "$(cat "$CALLS")" == "commit" ]]
}

@test "returns a non-zero status when the commit fails" {
  mock_collaborators
  export COMMIT_STATUS=1
  bats_run_zsh "ralph-auto-next $PRD_DIR"
  [[ "$status" -ne 0 ]]
}

@test "falls back to the current directory when no argument is given" {
  mock_collaborators
  bats_disable_worktree_aware
  bats_run_zsh "cd $PRD_DIR && ralph-auto-next"
  [[ "$status" -eq 0 ]]
  [[ "$(tail -n 1 "$CALLS")" == "ralph --auto $PRD_DIR" ]]
}

# exec from the queue hook kills the Kitty window before the new shell runs anything
@test "never runs exec" {
  run grep --extended-regexp '(^|[;&|])[[:space:]]*exec[[:space:]]' "$BATS_TEST_DIRNAME/../ralph-auto-next"
  [[ "$status" -ne 0 ]]
}
