bats_load_library 'helper'

setup() {
  bats_tmp_dir
  unset CLAUDE_SESSIONS_DIR
  unset CLAUDE_SESSION_ID
}

@test "prints the session dir in the default location" {
  bats_run_zsh "claude-session-dir abc-123"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "/tmp/oroshi/claude/sessions/abc-123" ]]
}

@test "prints the session dir inside CLAUDE_SESSIONS_DIR when set" {
  export CLAUDE_SESSIONS_DIR="$BATS_TMP_DIR/sessions"

  bats_run_zsh "claude-session-dir abc-123"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$BATS_TMP_DIR/sessions/abc-123" ]]
}

@test "resolves a relative CLAUDE_SESSIONS_DIR to an absolute path" {
  export CLAUDE_SESSIONS_DIR="relative/sessions"

  bats_run_zsh "cd '$BATS_TMP_DIR'; claude-session-dir abc-123"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$BATS_TMP_DIR/relative/sessions/abc-123" ]]
}

@test "defaults the session id to CLAUDE_SESSION_ID" {
  export CLAUDE_SESSION_ID="from-env"

  bats_run_zsh "claude-session-dir"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "/tmp/oroshi/claude/sessions/from-env" ]]
}

@test "prefers the session id argument over CLAUDE_SESSION_ID" {
  export CLAUDE_SESSION_ID="from-env"

  bats_run_zsh "claude-session-dir abc-123"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "/tmp/oroshi/claude/sessions/abc-123" ]]
}

@test "prints nothing when the session id is empty" {
  bats_run_zsh "claude-session-dir ''"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "prints nothing when the session id is missing and CLAUDE_SESSION_ID is unset" {
  bats_run_zsh "claude-session-dir"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "does not create the session dir" {
  export CLAUDE_SESSIONS_DIR="$BATS_TMP_DIR/sessions"

  bats_run_zsh "claude-session-dir abc-123"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_TMP_DIR/sessions" ]]
}
