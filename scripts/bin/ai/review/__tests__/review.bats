bats_load_library 'helper'

REVIEW_SCRIPT="$BATS_TEST_DIRNAME/../review"

setup() {
  bats_git_dir 'my-repo'
  cd "$BATS_GIT_DIR"
  echo "initial content" > tracked.txt
  git add tracked.txt
  git commit --quiet --message "add tracked.txt"

  export CLAUDE_PRINT_CAPTURE="$BATS_TMP_DIR/claude-print-args"

  claude-print() { echo "$1" > "$CLAUDE_PRINT_CAPTURE"; }
  bats_mock claude-print
}

teardown() {
  rm -f /tmp/review-diff-*.md
  bats_cleanup
}

@test "0-arg: creates /tmp/review-diff-*.md containing the diff and invokes claude-print with filepath" {
  echo "modified content" >> tracked.txt

  bats_run_script "$REVIEW_SCRIPT"
  [ "$status" -eq 0 ]

  # claude-print was called with "/review <filepath>"
  [ -f "$CLAUDE_PRINT_CAPTURE" ]
  local capturedArg="$(cat "$CLAUDE_PRINT_CAPTURE")"
  [[ "$capturedArg" == "/review /tmp/review-diff-"* ]]
  [[ "$capturedArg" == *".md" ]]

  # the diff file was created and contains the diff output
  local filepath="${capturedArg#/review }"
  [ -f "$filepath" ]
  local content="$(cat "$filepath")"
  [[ "$content" == *"diff --git"* ]]
  [[ "$content" == *"modified content"* ]]
}

@test "1-arg branch: passes arg through to review-diff; diff file contains branch commits" {
  git checkout -b feature-branch
  echo "feature content" > feature.txt
  git add feature.txt
  git commit --quiet --message "feat: add feature.txt"

  bats_run_script "$REVIEW_SCRIPT" feature-branch
  [ "$status" -eq 0 ]

  [ -f "$CLAUDE_PRINT_CAPTURE" ]
  local capturedArg="$(cat "$CLAUDE_PRINT_CAPTURE")"
  local filepath="${capturedArg#/review }"
  [ -f "$filepath" ]
  local content="$(cat "$filepath")"
  [[ "$content" == *"feat: add feature.txt"* ]]
  [[ "$content" == *"diff --git"* ]]
}

@test "2-arg range: passes both args through to review-diff; diff file contains range commits" {
  local shaA="$(git rev-parse HEAD)"
  git checkout -b feature-branch
  echo "feature content" > feature.txt
  git add feature.txt
  git commit --quiet --message "feat: add feature.txt"

  bats_run_script "$REVIEW_SCRIPT" "$shaA" feature-branch
  [ "$status" -eq 0 ]

  [ -f "$CLAUDE_PRINT_CAPTURE" ]
  local capturedArg="$(cat "$CLAUDE_PRINT_CAPTURE")"
  local filepath="${capturedArg#/review }"
  [ -f "$filepath" ]
  local content="$(cat "$filepath")"
  [[ "$content" == *"feat: add feature.txt"* ]]
  [[ "$content" == *"diff --git"* ]]
}

@test "uuid is unique per invocation" {
  echo "first change" >> tracked.txt
  bats_run_script "$REVIEW_SCRIPT"
  local arg1="$(cat "$CLAUDE_PRINT_CAPTURE")"

  echo "second change" >> tracked.txt
  bats_run_script "$REVIEW_SCRIPT"
  local arg2="$(cat "$CLAUDE_PRINT_CAPTURE")"

  [ "$arg1" != "$arg2" ]
}
