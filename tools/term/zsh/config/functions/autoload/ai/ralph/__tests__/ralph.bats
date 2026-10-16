bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export PRD_DIR="$BATS_TMP_DIR/plans/feature"
  mkdir -p "$PRD_DIR"
  export WORKTREE="$BATS_TMP_DIR/worktrees/feature"
  mkdir -p "$WORKTREE"
}

# Mocks plan-directory: only the worktree of the test resolves to the plan directory
mock_plan_directory() {
  plan-directory() { [[ "$1" == "$WORKTREE" ]] && echo "$PRD_DIR"; }
  bats_mock plan-directory
}

@test "refuses to run when a session is already active" {
  ralph-is-running() { return 0; }
  bats_mock ralph-is-running

  mock_plan_directory
  bats_run_zsh "ralph '$WORKTREE'"
  [[ "$status" -eq 1 ]]
}

@test "writes mode single to ralph.json before launching Claude" {
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { [[ "$(jq -c . "$PRD_DIR/ralph.json")" = '{"mode":"single"}' ]]; }
  bats_mock ralph-is-running git-directory-root claude

  mock_plan_directory
  bats_run_zsh "ralph '$WORKTREE'"
  [[ "$status" -eq 0 ]]
}

@test "--auto writes mode auto to ralph.json before launching Claude" {
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { [[ "$(jq -c . "$PRD_DIR/ralph.json")" = '{"mode":"auto"}' ]]; }
  bats_mock ralph-is-running git-directory-root claude

  mock_plan_directory
  bats_run_zsh "ralph --auto '$WORKTREE'"
  [[ "$status" -eq 0 ]]
}

@test "launches Claude in acceptEdits permission mode in single mode" {
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { echo "ARGS:$*"; }
  bats_mock ralph-is-running git-directory-root claude

  mock_plan_directory
  bats_run_zsh "ralph '$WORKTREE'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--permission-mode acceptEdits"* ]]
}

@test "--auto launches Claude in auto permission mode" {
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { echo "ARGS:$*"; }
  bats_mock ralph-is-running git-directory-root claude

  mock_plan_directory
  bats_run_zsh "ralph --auto '$WORKTREE'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--permission-mode auto"* ]]
}

@test "clears ralph.json after Claude exits (happy path)" {
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { return 0; }
  bats_mock ralph-is-running git-directory-root claude

  mock_plan_directory
  bats_run_zsh "ralph '$WORKTREE'"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$PRD_DIR/ralph.json" ]]
}

@test "clears ralph.json and returns the exit code when Claude fails" {
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() {
    touch "$BATS_TMP_DIR/claude-called"
    return 3
  }
  bats_mock ralph-is-running git-directory-root claude

  mock_plan_directory
  bats_run_zsh "ralph '$WORKTREE'"
  [[ "$status" -eq 3 ]]
  [[ -f "$BATS_TMP_DIR/claude-called" ]]
  [[ ! -f "$PRD_DIR/ralph.json" ]]
}

@test "calls Claude with the plan directory argument" {
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { echo "ARGS:$*"; }
  bats_mock ralph-is-running git-directory-root claude

  mock_plan_directory
  bats_run_zsh "ralph '$WORKTREE'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"/ralph ${PRD_DIR}"* ]]
}

@test "no arg → uses the current worktree to find the plan directory" {
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { echo "ARGS:$*"; }
  bats_mock ralph-is-running git-directory-root claude
  bats_disable_worktree_aware

  mock_plan_directory
  bats_run_zsh "cd $WORKTREE && ralph"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"/ralph ${PRD_DIR}"* ]]
}

@test "fails without launching Claude when the worktree has no plan" {
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { touch "$BATS_TMP_DIR/claude-called"; }
  plan-directory() { return 1; }
  bats_mock ralph-is-running git-directory-root claude plan-directory

  bats_run_zsh "ralph '$WORKTREE'"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"no plan directory"* ]]
  [[ ! -f "$BATS_TMP_DIR/claude-called" ]]
}

@test "--auto on a finished plan runs nothing and succeeds" {
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  plan-progress() { echo "3▮3"; }
  claude() { touch "$BATS_TMP_DIR/claude-called"; }
  bats_mock ralph-is-running git-directory-root plan-progress claude

  mock_plan_directory
  bats_run_zsh "ralph --auto '$WORKTREE'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"no remaining issue"* ]]
  [[ ! -f "$BATS_TMP_DIR/claude-called" ]]
  [[ ! -f "$PRD_DIR/ralph.json" ]]
}

@test "--auto with remaining issues launches Claude" {
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  plan-progress() { echo "2▮3"; }
  claude() { touch "$BATS_TMP_DIR/claude-called"; }
  bats_mock ralph-is-running git-directory-root plan-progress claude

  mock_plan_directory
  bats_run_zsh "ralph --auto '$WORKTREE'"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/claude-called" ]]
}

@test "--auto with an empty queue after Claude exits stops quietly" {
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  plan-progress() { echo "1▮3"; }
  claude() { return 0; }
  zsh-queue-write() { touch "$BATS_TMP_DIR/queue-written"; }
  kitty-notify() { touch "$BATS_TMP_DIR/notified"; }
  bats_mock ralph-is-running git-directory-root plan-progress claude zsh-queue-write kitty-notify

  mock_plan_directory
  bats_run_zsh "ralph --auto '$WORKTREE'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  [[ ! -f "$BATS_TMP_DIR/queue-written" ]]
  [[ ! -f "$BATS_TMP_DIR/notified" ]]
  [[ ! -f "$PRD_DIR/ralph.json" ]]
}

@test "single mode on a finished plan runs nothing and succeeds" {
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  plan-progress() { echo "3▮3"; }
  claude() { touch "$BATS_TMP_DIR/claude-called"; }
  bats_mock ralph-is-running git-directory-root plan-progress claude

  mock_plan_directory
  bats_run_zsh "ralph '$WORKTREE'"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/claude-called" ]]
}
