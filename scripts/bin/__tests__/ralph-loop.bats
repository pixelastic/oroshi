load 'helper'

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"
  mkdir -p "$TMP_DIRECTORY/stub-bin"
  export GIT_REPO="$TMP_DIRECTORY/my-repo"
  export PRD_DIR="$TMP_DIRECTORY/prd-dir"
  export RALPH_WATCHER_INTERVAL=0.1

  git init "$GIT_REPO"
  cd "$GIT_REPO"
  git config user.email "test@test.com"
  git config user.name "Test"
  git commit --allow-empty -m "init"

  mkdir -p "$PRD_DIR"

  # Stub: git-commit-message → fixed message (absolute path, bypasses .zshenv PATH)
  cat > "$TMP_DIRECTORY/stub-bin/git-commit-message" << 'EOF'
#!/bin/sh
echo "test commit"
EOF
  chmod +x "$TMP_DIRECTORY/stub-bin/git-commit-message"

  # Point ralph to stubs via env vars (PATH-based stubs don't survive .zshenv rebuild)
  export RALPH_GIT_COMMIT_MESSAGE="$TMP_DIRECTORY/stub-bin/git-commit-message"

  export PATH="$BATS_TEST_DIRNAME/../claude/ralph:$PATH"
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "ralph --max 3 runs exactly 3 iterations and creates 3 commits" {
  echo '[{"id":"1","status":"open"},{"id":"2","status":"open"},{"id":"3","status":"open"},{"id":"4","status":"open"},{"id":"5","status":"open"}]' \
    > "$PRD_DIR/prd.json"

  # Stub claude: appends unique line each call (so git sees changes) and exits 0
  cat > "$TMP_DIRECTORY/stub-bin/claude" << 'EOF'
#!/bin/sh
echo "change $$" >> "$GIT_REPO/output.txt"
EOF
  chmod +x "$TMP_DIRECTORY/stub-bin/claude"
  export RALPH_CLAUDE_CMD="$TMP_DIRECTORY/stub-bin/claude"

  cd "$GIT_REPO"
  run ralph --max 3 "$PRD_DIR"
  [ "$status" -eq 0 ]

  local commits
  commits="$(git log --oneline | wc -l)"
  [ "$commits" -eq 4 ]
}

@test "ralph --max 10 exits early when prd is complete after 1 iteration" {
  echo '[{"id":"1","status":"complete"}]' > "$PRD_DIR/prd.json"

  # Stub claude: appends change and writes sentinel files directly
  cat > "$TMP_DIRECTORY/stub-bin/claude" << 'EOF'
#!/bin/sh
echo "change $$" >> "$GIT_REPO/output.txt"
touch "$PRD_DIR/.ralph-done"
touch "$PRD_DIR/.ralph-prd-done"
EOF
  chmod +x "$TMP_DIRECTORY/stub-bin/claude"
  export RALPH_CLAUDE_CMD="$TMP_DIRECTORY/stub-bin/claude"

  cd "$GIT_REPO"
  run ralph --max 10 "$PRD_DIR"
  [ "$status" -eq 0 ]

  local commits
  commits="$(git log --oneline | wc -l)"
  [ "$commits" -eq 2 ]
}

@test "ralph --max loop stops cleanly on Ctrl+C with no commit" {
  echo '[{"id":"1","status":"open"}]' > "$PRD_DIR/prd.json"

  # Stub claude: exits 130 (SIGINT simulation)
  cat > "$TMP_DIRECTORY/stub-bin/claude" << 'EOF'
#!/bin/sh
exit 130
EOF
  chmod +x "$TMP_DIRECTORY/stub-bin/claude"
  export RALPH_CLAUDE_CMD="$TMP_DIRECTORY/stub-bin/claude"

  cd "$GIT_REPO"
  run ralph --max 5 "$PRD_DIR"
  [ "$status" -eq 0 ]

  local commits
  commits="$(git log --oneline | wc -l)"
  [ "$commits" -eq 1 ]
}
