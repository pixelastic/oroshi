bats_load_library 'helper'

RALPH_SCRIPT="$BATS_TEST_DIRNAME/../ralph"

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"
  export GIT_REPO="$TMP_DIRECTORY/my-repo"
  export PRD_DIR="$TMP_DIRECTORY/prd-dir"
  export RALPH_WATCHER_INTERVAL=0.1

  git init "$GIT_REPO"
  cd "$GIT_REPO"
  git config user.email "test@test.com"
  git config user.name "Test"
  git commit --allow-empty -m "init"

  mkdir -p "$PRD_DIR"
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "ralph --max 3 runs exactly 3 iterations and creates 3 commits" {
  echo '[{"id":"1","status":"open"},{"id":"2","status":"open"},{"id":"3","status":"open"}]' \
    > "$PRD_DIR/prd.json"

  claude() { echo "change $$" >> "$GIT_REPO/output.txt"; }
  git-commit-message() { echo "test commit"; }
  mock claude git-commit-message

  cd "$GIT_REPO"
  run_zsh_script "$RALPH_SCRIPT" --max 3 "$PRD_DIR"
  [ "$status" -eq 0 ]

  local commits
  commits="$(git log --oneline | wc -l)"
  [ "$commits" -eq 4 ]
}

@test "ralph --max 10 exits early when prd is complete after 1 iteration" {
  echo '[{"id":"1","status":"complete"}]' > "$PRD_DIR/prd.json"

  claude() {
    echo "change $$" >> "$GIT_REPO/output.txt"
    touch "$PRD_DIR/.ralph-done"
    touch "$PRD_DIR/.ralph-prd-done"
  }
  git-commit-message() { echo "test commit"; }
  mock claude git-commit-message

  cd "$GIT_REPO"
  run_zsh_script "$RALPH_SCRIPT" --max 10 "$PRD_DIR"
  [ "$status" -eq 0 ]

  local commits
  commits="$(git log --oneline | wc -l)"
  [ "$commits" -eq 2 ]
}

@test "ralph --max loop stops cleanly on Ctrl+C with no commit" {
  echo '[{"id":"1","status":"open"}]' > "$PRD_DIR/prd.json"

  claude() { return 130; }
  git-commit-message() { echo "test commit"; }
  mock claude git-commit-message

  cd "$GIT_REPO"
  run_zsh_script "$RALPH_SCRIPT" --max 5 "$PRD_DIR"
  [ "$status" -eq 0 ]

  local commits
  commits="$(git log --oneline | wc -l)"
  [ "$commits" -eq 1 ]
}

@test "inactivity monitor plays sound once when inotifywait times out" {
  echo '[{"id":"1","status":"open"}]' > "$PRD_DIR/prd.json"

  inotifywait() { return 2; }
  audio-play-oroshi() {
    echo "$1" >> "$TMP_DIRECTORY/audio.txt"
    touch "$TMP_DIRECTORY/audio_played"
  }
  claude() {
    local i=0
    while [[ ! -f "$TMP_DIRECTORY/audio_played" ]] && [[ $i -lt 100 ]]; do
      sleep 0.01
      i=$((i + 1))
    done
    echo "change" >> "$GIT_REPO/output.txt"
  }
  git-commit-message() { echo "test commit"; }
  mock inotifywait audio-play-oroshi claude git-commit-message

  cd "$GIT_REPO"
  run_zsh_script "$RALPH_SCRIPT" --max 1 "$PRD_DIR"
  [ "$status" -eq 0 ]
  [ -f "$TMP_DIRECTORY/audio.txt" ]
  [ "$(wc -l < "$TMP_DIRECTORY/audio.txt")" -eq 1 ]
  [ "$(cat "$TMP_DIRECTORY/audio.txt")" = "ralph-timeout.mp3" ]
}

@test "inactivity monitor resets after activity and fires again on next timeout" {
  echo '[{"id":"1","status":"open"}]' > "$PRD_DIR/prd.json"

  inotifywait() {
    local n
    n=$(cat "$TMP_DIRECTORY/ino_count" 2>/dev/null || echo 0)
    n=$((n + 1))
    echo "$n" > "$TMP_DIRECTORY/ino_count"
    [[ $n -eq 1 ]] && return 0
    return 2
  }
  audio-play-oroshi() {
    echo "$1" >> "$TMP_DIRECTORY/audio.txt"
    touch "$TMP_DIRECTORY/audio_played"
  }
  claude() {
    local i=0
    while [[ ! -f "$TMP_DIRECTORY/audio_played" ]] && [[ $i -lt 100 ]]; do
      sleep 0.01
      i=$((i + 1))
    done
    echo "change" >> "$GIT_REPO/output.txt"
  }
  git-commit-message() { echo "test commit"; }
  mock inotifywait audio-play-oroshi claude git-commit-message

  cd "$GIT_REPO"
  run_zsh_script "$RALPH_SCRIPT" --max 1 "$PRD_DIR"
  [ "$status" -eq 0 ]
  [ -f "$TMP_DIRECTORY/audio.txt" ]
  [ "$(wc -l < "$TMP_DIRECTORY/audio.txt")" -eq 1 ]
  [ "$(cat "$TMP_DIRECTORY/audio.txt")" = "ralph-timeout.mp3" ]
}

@test "no inactivity monitor started in single-run mode" {
  echo '[{"id":"1","status":"open"}]' > "$PRD_DIR/prd.json"

  inotifywait() { echo "called" >> "$TMP_DIRECTORY/ino_calls.txt"; return 2; }
  audio-play-oroshi() { echo "$1" >> "$TMP_DIRECTORY/audio.txt"; }
  claude() { echo "change" >> "$GIT_REPO/output.txt"; }
  mock inotifywait audio-play-oroshi claude

  cd "$GIT_REPO"
  run_zsh_script "$RALPH_SCRIPT" "$PRD_DIR"
  [ "$status" -eq 0 ]
  [ ! -f "$TMP_DIRECTORY/ino_calls.txt" ]
}
