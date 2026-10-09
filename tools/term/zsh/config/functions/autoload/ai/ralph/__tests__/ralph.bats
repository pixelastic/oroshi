bats_load_library 'helper'

setup() {
  bats_tmp_dir
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
