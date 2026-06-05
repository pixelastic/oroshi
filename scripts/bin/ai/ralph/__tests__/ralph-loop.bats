bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  export GIT_REPO="$BATS_GIT_DIR"
  export PRD_DIR="$BATS_TMP_DIR/prd-dir"
  export RALPH_WATCHER_INTERVAL=0.1
  export RALPH_TTY=/dev/null

  local script="$BATS_TEST_DIRNAME/../__lib/ralph-loop.zsh"
  printf "source '%s'\n" "$script" >"$BATS_TMP_DIR/mock.zsh"

  CURRENT="$BATS_TMP_DIR/caller.zsh"
  printf 'ralph-loop "$@"\n' >"$CURRENT"

  mkdir -p "$PRD_DIR"
}

teardown() {
  bats_cleanup
}

@test "runs exactly N iterations when --max N is given" {
  echo '[{"id":"1","done":false,"blocked_by":[]}]' >"$PRD_DIR/state.json"

  git-directory-root() { echo "$GIT_REPO"; }
  claude() { echo "change $$" >>"$GIT_REPO/output.txt"; }
  git-commit-message() { echo "test commit"; }
  claude-terminal-fix() { true; }
  bats_mock git-directory-root claude git-commit-message claude-terminal-fix

  bats_run_zsh "$CURRENT" "$PRD_DIR" 3
  [ "$status" -eq 0 ]

  local commits
  commits="$(git -C "$GIT_REPO" log --oneline | wc -l)"
  [ "$commits" -eq 4 ]
}

@test "exits early when prd_done is set after an iteration" {
  echo '[{"id":"1","done":true,"blocked_by":[]}]' >"$PRD_DIR/state.json"

  git-directory-root() { echo "$GIT_REPO"; }
  claude() {
    echo "change $$" >>"$GIT_REPO/output.txt"
    ralph-state "$PRD_DIR" set 'done' true
    ralph-state "$PRD_DIR" set prd_done true
  }
  git-commit-message() { echo "test commit"; }
  claude-terminal-fix() { true; }
  bats_mock git-directory-root claude git-commit-message claude-terminal-fix

  bats_run_zsh "$CURRENT" "$PRD_DIR" 10
  [ "$status" -eq 0 ]

  local commits
  commits="$(git -C "$GIT_REPO" log --oneline | wc -l)"
  [ "$commits" -eq 2 ]
}

@test "stops cleanly on Ctrl+C with no commit" {
  echo '[{"id":"1","done":false,"blocked_by":[]}]' >"$PRD_DIR/state.json"

  git-directory-root() { echo "$GIT_REPO"; }
  claude() { return 130; }
  git-commit-message() { echo "test commit"; }
  claude-terminal-fix() { true; }
  bats_mock git-directory-root claude git-commit-message claude-terminal-fix

  bats_run_zsh "$CURRENT" "$PRD_DIR" 5
  [ "$status" -eq 0 ]

  local commits
  commits="$(git -C "$GIT_REPO" log --oneline | wc -l)"
  [ "$commits" -eq 1 ]
}

@test "ralph.json exists during each iteration and is cleared after all iterations complete" {
  echo '[{"id":"1","done":false,"blocked_by":[]},{"id":"2","done":false,"blocked_by":[]}]' >"$PRD_DIR/state.json"

  git-directory-root() { echo "$GIT_REPO"; }
  claude() {
    [ -f "$PRD_DIR/ralph.json" ] || return 1
    echo "change $$" >>"$GIT_REPO/output.txt"
  }
  git-commit-message() { echo "test commit"; }
  claude-terminal-fix() { true; }
  bats_mock git-directory-root claude git-commit-message claude-terminal-fix

  bats_run_zsh "$CURRENT" "$PRD_DIR" 2
  [ "$status" -eq 0 ]
  [ ! -f "$PRD_DIR/ralph.json" ]
}
