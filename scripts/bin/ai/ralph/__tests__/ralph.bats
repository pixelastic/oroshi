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

  inotifywait() { return 0; }
  claude() { echo "change $$" >> "$GIT_REPO/output.txt"; }
  git-commit-message() { echo "test commit"; }
  bats_mock inotifywait claude git-commit-message

  cd "$GIT_REPO"
  bats_run_script "$RALPH_SCRIPT" --max 3 "$PRD_DIR"
  [ "$status" -eq 0 ]

  local commits
  commits="$(git log --oneline | wc -l)"
  [ "$commits" -eq 4 ]
}

@test "ralph --max 10 exits early when prd is complete after 1 iteration" {
  echo '[{"id":"1","status":"complete"}]' > "$PRD_DIR/prd.json"

  inotifywait() { return 0; }
  claude() {
    echo "change $$" >> "$GIT_REPO/output.txt"
    ralph-state set done true
    ralph-state set prd_done true
  }
  git-commit-message() { echo "test commit"; }
  bats_mock inotifywait claude git-commit-message

  cd "$GIT_REPO"
  bats_run_script "$RALPH_SCRIPT" --max 10 "$PRD_DIR"
  [ "$status" -eq 0 ]

  local commits
  commits="$(git log --oneline | wc -l)"
  [ "$commits" -eq 2 ]
}

@test "ralph --max loop stops cleanly on Ctrl+C with no commit" {
  echo '[{"id":"1","status":"open"}]' > "$PRD_DIR/prd.json"

  inotifywait() { return 0; }
  claude() { return 130; }
  git-commit-message() { echo "test commit"; }
  bats_mock inotifywait claude git-commit-message

  cd "$GIT_REPO"
  bats_run_script "$RALPH_SCRIPT" --max 5 "$PRD_DIR"
  [ "$status" -eq 0 ]

  local commits
  commits="$(git log --oneline | wc -l)"
  [ "$commits" -eq 1 ]
}

@test "inactivity monitor plays sound once when inotifywait times out" {
  echo '[{"id":"1","status":"open"}]' > "$PRD_DIR/prd.json"

  inotifywait() { return 2; }
  audio-play-oroshi() {
    echo "$1" >> "$BATS_TMP_DIR/audio.txt"
    touch "$BATS_TMP_DIR/audio_played"
  }
  claude() {
    local i=0
    while [[ ! -f "$BATS_TMP_DIR/audio_played" ]] && [[ $i -lt 100 ]]; do
      sleep 0.01
      i=$((i + 1))
    done
    echo "change" >> "$GIT_REPO/output.txt"
  }
  git-commit-message() { echo "test commit"; }
  bats_mock inotifywait audio-play-oroshi claude git-commit-message

  cd "$GIT_REPO"
  bats_run_script "$RALPH_SCRIPT" --max 1 "$PRD_DIR"
  [ "$status" -eq 0 ]
  [ -f "$BATS_TMP_DIR/audio.txt" ]
  [ "$(wc -l < "$BATS_TMP_DIR/audio.txt")" -eq 1 ]
  [ "$(cat "$BATS_TMP_DIR/audio.txt")" = "ralph-timeout.mp3" ]
}

@test "inactivity monitor resets after activity and fires again on next timeout" {
  echo '[{"id":"1","status":"open"}]' > "$PRD_DIR/prd.json"

  inotifywait() {
    local n
    n=$(cat "$BATS_TMP_DIR/ino_count" 2>/dev/null || echo 0)
    n=$((n + 1))
    echo "$n" > "$BATS_TMP_DIR/ino_count"
    [[ $n -eq 1 ]] && return 0
    return 2
  }
  audio-play-oroshi() {
    echo "$1" >> "$BATS_TMP_DIR/audio.txt"
    touch "$BATS_TMP_DIR/audio_played"
  }
  claude() {
    local i=0
    while [[ ! -f "$BATS_TMP_DIR/audio_played" ]] && [[ $i -lt 100 ]]; do
      sleep 0.01
      i=$((i + 1))
    done
    echo "change" >> "$GIT_REPO/output.txt"
  }
  git-commit-message() { echo "test commit"; }
  bats_mock inotifywait audio-play-oroshi claude git-commit-message

  cd "$GIT_REPO"
  bats_run_script "$RALPH_SCRIPT" --max 1 "$PRD_DIR"
  [ "$status" -eq 0 ]
  [ -f "$BATS_TMP_DIR/audio.txt" ]
  [ "$(wc -l < "$BATS_TMP_DIR/audio.txt")" -eq 1 ]
  [ "$(cat "$BATS_TMP_DIR/audio.txt")" = "ralph-timeout.mp3" ]
}

@test "no inactivity monitor started in single-run mode" {
  echo '[{"id":"1","status":"open"}]' > "$PRD_DIR/prd.json"

  inotifywait() { echo "called" >> "$BATS_TMP_DIR/ino_calls.txt"; return 2; }
  audio-play-oroshi() { echo "$1" >> "$BATS_TMP_DIR/audio.txt"; }
  claude() { echo "change" >> "$GIT_REPO/output.txt"; }
  bats_mock inotifywait audio-play-oroshi claude

  cd "$GIT_REPO"
  bats_run_script "$RALPH_SCRIPT" "$PRD_DIR"
  [ "$status" -eq 0 ]
  [ ! -f "$BATS_TMP_DIR/ino_calls.txt" ]
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

  inotifywait() { return 0; }
  claude() { echo "change $$" >> "$GIT_REPO/output.txt"; }
  git-commit-message() { echo "test commit"; }
  bats_mock inotifywait claude git-commit-message

  cd "$GIT_REPO"
  bats_run_script "$RALPH_SCRIPT" --max 2 "$PRD_DIR"
  [ "$status" -eq 0 ]
  [ ! -f "$PRD_DIR/.ralph-state.json" ]
}
