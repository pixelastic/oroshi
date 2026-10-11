bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # The ralph log is a trace for debugging, tests keep it empty
  ralph-log() { :; }
  bats_mock ralph-log
  export PRD_DIR="$BATS_TMP_DIR/plans/feature"
  mkdir -p "$PRD_DIR"
}

@test "refuses to run when a session is already active" {
  ralph-is-running() { return 0; }
  bats_mock ralph-is-running

  bats_run_zsh "ralph '$PRD_DIR'"
  [[ "$status" -eq 1 ]]
}

@test "writes mode single to ralph.json before launching Claude" {
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { [[ "$(jq -c . "$PRD_DIR/ralph.json")" = '{"mode":"single"}' ]]; }
  bats_mock ralph-is-running git-directory-root claude

  bats_run_zsh "ralph '$PRD_DIR'"
  [[ "$status" -eq 0 ]]
}

@test "--auto writes mode auto to ralph.json before launching Claude" {
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { [[ "$(jq -c . "$PRD_DIR/ralph.json")" = '{"mode":"auto"}' ]]; }
  bats_mock ralph-is-running git-directory-root claude

  bats_run_zsh "ralph --auto '$PRD_DIR'"
  [[ "$status" -eq 0 ]]
}

@test "launches Claude in acceptEdits permission mode in single mode" {
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { echo "ARGS:$*"; }
  bats_mock ralph-is-running git-directory-root claude

  bats_run_zsh "ralph '$PRD_DIR'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--permission-mode acceptEdits"* ]]
}

@test "--auto launches Claude in auto permission mode" {
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { echo "ARGS:$*"; }
  bats_mock ralph-is-running git-directory-root claude

  bats_run_zsh "ralph --auto '$PRD_DIR'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--permission-mode auto"* ]]
}

@test "clears ralph.json after Claude exits (happy path)" {
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { return 0; }
  bats_mock ralph-is-running git-directory-root claude

  bats_run_zsh "ralph '$PRD_DIR'"
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

  bats_run_zsh "ralph '$PRD_DIR'"
  [[ "$status" -eq 3 ]]
  [[ -f "$BATS_TMP_DIR/claude-called" ]]
  [[ ! -f "$PRD_DIR/ralph.json" ]]
}

@test "calls Claude with the plan directory argument" {
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { echo "ARGS:$*"; }
  bats_mock ralph-is-running git-directory-root claude

  bats_run_zsh "ralph '$PRD_DIR'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"/ralph ${PRD_DIR}"* ]]
}

@test "no arg + worktree has plan → auto-detects plans dir" {
  local planDir="$BATS_TMP_DIR/plans/feat_my-feature"
  mkdir -p "$planDir"
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { echo "ARGS:$*"; }
  plan-directory() { echo "$BATS_TMP_DIR/plans/feat_my-feature"; }
  bats_mock ralph-is-running git-directory-root claude plan-directory

  bats_run_zsh "cd $BATS_TMP_DIR && ralph"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"/ralph ${planDir}"* ]]
}

@test "no arg + cwd inside plan subdir → path not doubled" {
  local planDir="$BATS_TMP_DIR/plans/feat_my-feature"
  mkdir -p "$planDir"
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { echo "ARGS:$*"; }
  plan-directory() { echo "$BATS_TMP_DIR/plans/feat_my-feature"; }
  bats_mock ralph-is-running git-directory-root claude plan-directory

  bats_run_zsh "cd $planDir && ralph"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"/ralph ${planDir}"* ]]
}

@test "no arg + no worktree plan → fallback to cwd" {
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { echo "ARGS:$*"; }
  plan-directory() { return 1; }
  bats_mock ralph-is-running git-directory-root claude plan-directory

  bats_run_zsh "cd $BATS_TMP_DIR && ralph"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"/ralph ${BATS_TMP_DIR}"* ]]
}

@test "--auto on a finished plan runs nothing and succeeds" {
  ralph-is-running() { return 1; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  plan-progress() { echo "3▮3"; }
  claude() { touch "$BATS_TMP_DIR/claude-called"; }
  bats_mock ralph-is-running git-directory-root plan-progress claude

  bats_run_zsh "ralph --auto '$PRD_DIR'"
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

  bats_run_zsh "ralph --auto '$PRD_DIR'"
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

  bats_run_zsh "ralph --auto '$PRD_DIR'"
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

  bats_run_zsh "ralph '$PRD_DIR'"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/claude-called" ]]
}
