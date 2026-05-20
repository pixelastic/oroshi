bats_load_library 'helper'

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"
  export CLAUDE_PRINT_CAPTURE="$TMP_DIRECTORY/claude-print-args"

  # ZDOTDIR: override zsh startup so claude-print (an autoloaded fn) is mocked.
  # Sources the real ~/.zshenv for full oroshi PATH + function setup, then
  # shadows claude-print with a stub that records its argument.
  local zdotdir="$TMP_DIRECTORY/zdotdir"
  mkdir -p "$zdotdir"
  cat > "$zdotdir/.zshenv" <<EOF
source "$HOME/.zshenv"
function claude-print() {
  echo "\$1" > "\$CLAUDE_PRINT_CAPTURE"
}
EOF
  export ZDOTDIR="$zdotdir"

  # bash-level PATH so bats can find the review script via `run review`
  export PATH="${BATS_TEST_DIRNAME}/../ai:$PATH"

  git init "$TMP_DIRECTORY/my-repo"
  cd "$TMP_DIRECTORY/my-repo"
  git config user.email "test@test.com"
  git config user.name "Test User"
  echo "initial content" > tracked.txt
  git add tracked.txt
  git commit --message "init"
}

teardown() {
  unset ZDOTDIR CLAUDE_PRINT_CAPTURE
  rm -rf "$TMP_DIRECTORY"
  rm -f /tmp/review-diff-*.md
}

@test "0-arg: creates /tmp/review-diff-*.md containing the diff and invokes claude-print with filepath" {
  cd "$TMP_DIRECTORY/my-repo"
  echo "modified content" >> tracked.txt

  run review
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
  cd "$TMP_DIRECTORY/my-repo"
  git checkout -b feature-branch
  echo "feature content" > feature.txt
  git add feature.txt
  git commit --message "feat: add feature.txt"

  run review feature-branch
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
  cd "$TMP_DIRECTORY/my-repo"
  local shaA="$(git rev-parse HEAD)"
  git checkout -b feature-branch
  echo "feature content" > feature.txt
  git add feature.txt
  git commit --message "feat: add feature.txt"

  run review "$shaA" feature-branch
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
  cd "$TMP_DIRECTORY/my-repo"

  echo "first change" >> tracked.txt
  run review
  local arg1="$(cat "$CLAUDE_PRINT_CAPTURE")"

  echo "second change" >> tracked.txt
  run review
  local arg2="$(cat "$CLAUDE_PRINT_CAPTURE")"

  [ "$arg1" != "$arg2" ]
}
