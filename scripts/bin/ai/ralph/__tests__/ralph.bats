bats_load_library 'helper'

RALPH_SCRIPT="$BATS_TEST_DIRNAME/../ralph"

setup() {
  bats_git_dir 'my-repo'
  export GIT_REPO="$BATS_GIT_DIR"
  export PRD_DIR="$BATS_TMP_DIR/prd-dir"
  export RALPH_WATCHER_INTERVAL=0.1
  export RALPH_TTY=/dev/null

  mkdir -p "$PRD_DIR"
}

teardown() {
  bats_cleanup
}

@test "ralph --max 3 runs exactly 3 iterations and creates 3 commits" {
  echo '[{"id":"1","status":"open"},{"id":"2","status":"open"},{"id":"3","status":"open"}]' \
    > "$PRD_DIR/prd.json"

  claude() { echo "change $$" >> "$GIT_REPO/output.txt"; }
  git-commit-message() { echo "test commit"; }
  bats_mock claude git-commit-message

  cd "$GIT_REPO"
  bats_run_script "$RALPH_SCRIPT" --max 3 "$PRD_DIR"
  [ "$status" -eq 0 ]

  local commits
  commits="$(git log --oneline | wc -l)"
  [ "$commits" -eq 4 ]
}

@test "ralph --max 10 exits early when prd is complete after 1 iteration" {
  echo '[{"id":"1","status":"complete"}]' > "$PRD_DIR/prd.json"

  claude() {
    echo "change $$" >> "$GIT_REPO/output.txt"
    ralph-state set done true
    ralph-state set prd_done true
  }
  git-commit-message() { echo "test commit"; }
  bats_mock claude git-commit-message

  cd "$GIT_REPO"
  bats_run_script "$RALPH_SCRIPT" --max 10 "$PRD_DIR"
  [ "$status" -eq 0 ]

  local commits
  commits="$(git log --oneline | wc -l)"
  [ "$commits" -eq 2 ]
}

@test "ralph --max loop stops cleanly on Ctrl+C with no commit" {
  echo '[{"id":"1","status":"open"}]' > "$PRD_DIR/prd.json"

  claude() { return 130; }
  git-commit-message() { echo "test commit"; }
  bats_mock claude git-commit-message

  cd "$GIT_REPO"
  bats_run_script "$RALPH_SCRIPT" --max 5 "$PRD_DIR"
  [ "$status" -eq 0 ]

  local commits
  commits="$(git log --oneline | wc -l)"
  [ "$commits" -eq 1 ]
}

@test "single-shot mode clears state file after run" {
  echo '[{"id":"1","status":"open"}]' > "$PRD_DIR/prd.json"

  claude() { echo "change" >> "$GIT_REPO/output.txt"; }
  bats_mock claude

  cd "$GIT_REPO"
  bats_run_script "$RALPH_SCRIPT" "$PRD_DIR"
  [ "$status" -eq 0 ]
  [ ! -f "$PRD_DIR/.ralph-state.json" ]
}

@test "loop mode clears state file after all iterations" {
  echo '[{"id":"1","status":"open"},{"id":"2","status":"open"}]' > "$PRD_DIR/prd.json"

  claude() { echo "change $$" >> "$GIT_REPO/output.txt"; }
  git-commit-message() { echo "test commit"; }
  bats_mock claude git-commit-message

  cd "$GIT_REPO"
  bats_run_script "$RALPH_SCRIPT" --max 2 "$PRD_DIR"
  [ "$status" -eq 0 ]
  [ ! -f "$PRD_DIR/.ralph-state.json" ]
}
