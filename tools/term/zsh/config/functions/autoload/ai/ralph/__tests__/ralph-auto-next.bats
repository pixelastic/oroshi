bats_load_library 'helper'

setup() {
  bats_tmp_dir
  mkdir -p "$BATS_TMP_DIR/prd-dir"
  export PRD_DIR="$BATS_TMP_DIR/prd-dir"
  export CALLS="$BATS_TMP_DIR/calls"
  export DIRTY_ARGS="$BATS_TMP_DIR/dirty-args"
  export PLAN_ARGS="$BATS_TMP_DIR/plan-args"
}

# Mocks the collaborators. The commit, ralph and claude log their calls to $CALLS, in order.
mock_collaborators() {
  git-commit-create-all-auto() {
    echo "commit" >>"$CALLS"
    return "${COMMIT_STATUS:-0}"
  }
  ralph() { echo "ralph $*" >>"$CALLS"; }
  plan-directory() {
    echo "$*" >"$PLAN_ARGS"
    echo "$PRD_DIR"
  }
  plan-progress() { echo "${PROGRESS:-1▮3}"; }
  claude() { echo "claude $*" >>"$CALLS"; }
  git-directory-dirty-count() {
    echo "$*" >"$DIRTY_ARGS"
    echo "${DIRTY_COUNT:-1}"
  }
  bats_mock git-commit-create-all-auto ralph plan-directory plan-progress claude git-directory-dirty-count
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

@test "skips the commit and still runs ralph --auto when nothing is dirty" {
  mock_collaborators
  export DIRTY_COUNT=0
  bats_run_zsh "ralph-auto-next $PRD_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$CALLS")" == "ralph --auto $PRD_DIR" ]]
}

@test "skips the commit and runs the review after the last issue when nothing is dirty" {
  mock_collaborators
  export DIRTY_COUNT=0 PROGRESS="3▮3"
  bats_run_zsh "ralph-auto-next $PRD_DIR"
  [[ "$(cat "$CALLS")" == "claude --permission-mode auto /ralph-review $PRD_DIR" ]]
}

@test "commits when several files are dirty" {
  mock_collaborators
  export DIRTY_COUNT=5
  bats_run_zsh "ralph-auto-next $PRD_DIR"
  [[ "$(cat "$CALLS")" == $'commit\nralph --auto '"$PRD_DIR" ]]
}

@test "checks the dirty count of the absolute worktree path" {
  mock_collaborators
  bats_disable_worktree_aware
  bats_run_zsh "cd $BATS_TMP_DIR && ralph-auto-next prd-dir"
  [[ "$(cat "$DIRTY_ARGS")" == "$PRD_DIR" ]]
}

@test "looks up the plan of the absolute worktree path" {
  mock_collaborators
  bats_disable_worktree_aware
  bats_run_zsh "cd $BATS_TMP_DIR && ralph-auto-next prd-dir"
  [[ "$(cat "$PLAN_ARGS")" == "$PRD_DIR" ]]
}

@test "runs ralph --auto with the absolute worktree path" {
  mock_collaborators
  bats_disable_worktree_aware
  bats_run_zsh "cd $BATS_TMP_DIR && ralph-auto-next prd-dir"
  [[ "$(tail -n 1 "$CALLS")" == "ralph --auto $PRD_DIR" ]]
}

@test "stops without running anything when nothing is dirty and the plan has no progress" {
  mock_collaborators
  export DIRTY_COUNT=0
  plan-progress() { return 1; }
  bats_mock plan-progress
  bats_run_zsh "ralph-auto-next $PRD_DIR"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$CALLS" ]]
}

@test "returns the status of ralph --auto" {
  mock_collaborators
  ralph() { return 7; }
  bats_mock ralph
  bats_run_zsh "ralph-auto-next $PRD_DIR"
  [[ "$status" -eq 7 ]]
}

@test "returns the status of the review after the last issue" {
  mock_collaborators
  export PROGRESS="3▮3"
  claude() { return 9; }
  bats_mock claude
  bats_run_zsh "ralph-auto-next $PRD_DIR"
  [[ "$status" -eq 9 ]]
}

@test "does not run the review when the commit fails after the last issue" {
  mock_collaborators
  export COMMIT_STATUS=1 PROGRESS="3▮3"
  bats_run_zsh "ralph-auto-next $PRD_DIR"
  [[ "$(cat "$CALLS")" == "commit" ]]
}

# exec from the queue hook kills the Kitty window before the new shell runs anything
@test "never runs exec" {
  run grep --extended-regexp '(^|[;&|])[[:space:]]*exec[[:space:]]' "$BATS_TEST_DIRNAME/../ralph-auto-next"
  [[ "$status" -ne 0 ]]
}
