bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="hookDir='${BATS_TEST_DIRNAME}/..'; source '${BATS_TEST_DIRNAME}/../preToolUse-Bash-solkan.zsh'"
}

@test "exits 0 for an allowlisted simple command" {
  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'git status'"
  [[ "$status" -eq 0 ]]
}

@test "exits 1 for a non-allowlisted simple command" {
  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'wget evil.com'"
  [[ "$status" -eq 1 ]]
}

@test "exits 0 for && compound where all subcommands are allowlisted" {
  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'git status && git log --oneline'"
  [[ "$status" -eq 0 ]]
}

@test "exits 1 for && compound with one non-allowlisted subcommand" {
  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'git status && wget evil.com'"
  [[ "$status" -eq 1 ]]
}

@test "exits 0 for || compound where all subcommands are allowlisted" {
  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'git status || echo fallback'"
  [[ "$status" -eq 0 ]]
}

@test "exits 1 for || compound with one non-allowlisted subcommand" {
  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'git status || wget evil.com'"
  [[ "$status" -eq 1 ]]
}

@test "exits 0 for ; compound where all subcommands are allowlisted" {
  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'git status; echo done'"
  [[ "$status" -eq 0 ]]
}

@test "exits 1 for ; compound with one non-allowlisted subcommand" {
  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'git status; wget evil.com'"
  [[ "$status" -eq 1 ]]
}

@test "exits 0 for pipe where all subcommands are allowlisted" {
  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'git status | grep branch'"
  [[ "$status" -eq 0 ]]
}

@test "exits 1 for pipe with one non-allowlisted subcommand" {
  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'git status | wget evil.com'"
  [[ "$status" -eq 1 ]]
}

# Local allow-list

@test "allows a command that is only in the local allow-list" {
  mkdir -p "$BATS_TMP_DIR/fakerepo/.claude"
  echo '["my-local-cmd"]' > "$BATS_TMP_DIR/fakerepo/.claude/allow-list.json"

  git-directory-root() { echo "$BATS_TMP_DIR/fakerepo"; }
  bats_mock git-directory-root

  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'my-local-cmd'"
  [[ "$status" -eq 0 ]]
}

@test "rejects a command in neither global nor local allow-list" {
  mkdir -p "$BATS_TMP_DIR/fakerepo/.claude"
  echo '["my-local-cmd"]' > "$BATS_TMP_DIR/fakerepo/.claude/allow-list.json"

  git-directory-root() { echo "$BATS_TMP_DIR/fakerepo"; }
  bats_mock git-directory-root

  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'wget evil.com'"
  [[ "$status" -eq 1 ]]
}

@test "allows a global command when local allow-list exists" {
  mkdir -p "$BATS_TMP_DIR/fakerepo/.claude"
  echo '["my-local-cmd"]' > "$BATS_TMP_DIR/fakerepo/.claude/allow-list.json"

  git-directory-root() { echo "$BATS_TMP_DIR/fakerepo"; }
  bats_mock git-directory-root

  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'git status'"
  [[ "$status" -eq 0 ]]
}

# Session allow-list

@test "passes the session allow-list to solkan when the file exists" {
  export CLAUDE_SESSIONS_DIR="$BATS_TMP_DIR/sessions"
  export CLAUDE_SESSION_ID="test"
  mkdir -p "$BATS_TMP_DIR/sessions/test"
  echo '["telnet"]' > "$BATS_TMP_DIR/sessions/test/allow-list.json"

  solkan() { print -r -- "$*"; }
  bats_mock solkan

  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'telnet bad.com'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--allow-list-file $BATS_TMP_DIR/sessions/test/allow-list.json"* ]]
}

@test "does not pass the session allow-list to solkan when the file is absent" {
  export CLAUDE_SESSIONS_DIR="$BATS_TMP_DIR/sessions"
  export CLAUDE_SESSION_ID="test"

  solkan() { print -r -- "$*"; }
  bats_mock solkan

  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'telnet bad.com'"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *"$BATS_TMP_DIR/sessions"* ]]
}

@test "allows a command that is only in the session allow-list" {
  export CLAUDE_SESSIONS_DIR="$BATS_TMP_DIR/sessions"
  export CLAUDE_SESSION_ID="test"
  mkdir -p "$BATS_TMP_DIR/sessions/test"
  echo '["telnet"]' > "$BATS_TMP_DIR/sessions/test/allow-list.json"

  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'telnet bad.com'"
  [[ "$status" -eq 0 ]]
}

# Local rewrite-list

@test "rewrites a command from the local rewrite-list" {
  mkdir -p "$BATS_TMP_DIR/fakerepo/.claude"
  echo '{"my-dangerous": "echo"}' > "$BATS_TMP_DIR/fakerepo/.claude/rewrite-list.json"

  git-directory-root() { echo "$BATS_TMP_DIR/fakerepo"; }
  bats_mock git-directory-root

  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'my-dangerous foo'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *'"rewrite"'* ]]
}

# No local files

@test "works without local files" {
  mkdir -p "$BATS_TMP_DIR/fakerepo"

  git-directory-root() { echo "$BATS_TMP_DIR/fakerepo"; }
  bats_mock git-directory-root

  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'git status'"
  [[ "$status" -eq 0 ]]
}

# Only one local file

@test "allow-list without rewrite-list works" {
  mkdir -p "$BATS_TMP_DIR/fakerepo/.claude"
  echo '["my-local-cmd"]' > "$BATS_TMP_DIR/fakerepo/.claude/allow-list.json"

  git-directory-root() { echo "$BATS_TMP_DIR/fakerepo"; }
  bats_mock git-directory-root

  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'my-local-cmd'"
  [[ "$status" -eq 0 ]]
}

@test "rewrite-list without allow-list works" {
  mkdir -p "$BATS_TMP_DIR/fakerepo/.claude"
  echo '{"my-dangerous": "echo"}' > "$BATS_TMP_DIR/fakerepo/.claude/rewrite-list.json"

  git-directory-root() { echo "$BATS_TMP_DIR/fakerepo"; }
  bats_mock git-directory-root

  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'my-dangerous foo'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *'"rewrite"'* ]]
}
