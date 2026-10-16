bats_load_library 'helper'

setup() {
  bats_tmp_dir
  hooksDir="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  sourcePrefix="source '${hooksDir}/lib/solkan.zsh'"
}

# solkanLists

@test "solkanLists passes the global allow-list and rewrite-list" {
  bats_run_zsh "${sourcePrefix}; solkanLists /some/dir"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--allow-list-file"$'\n'"${hooksDir}/allow-list.json"* ]]
  [[ "$output" == *"--rewrite-list-file"$'\n'"${hooksDir}/rewrite-list.json"* ]]
}

@test "solkanLists passes the auto allow-list after the global one when ralph-mode prints auto" {
  ralph-mode() { print auto; }
  bats_mock ralph-mode

  bats_run_zsh "${sourcePrefix}; solkanLists /some/dir"
  [[ "$output" == *"/allow-list.json"*"/allow-list-auto.json"* ]]
}

@test "solkanLists skips the auto allow-list when ralph-mode prints single" {
  ralph-mode() { print single; }
  bats_mock ralph-mode

  bats_run_zsh "${sourcePrefix}; solkanLists /some/dir"
  [[ "$output" != *"allow-list-auto.json"* ]]
}

@test "solkanLists skips the auto allow-list when ralph-mode prints nothing" {
  ralph-mode() { return 0; }
  bats_mock ralph-mode

  bats_run_zsh "${sourcePrefix}; solkanLists /some/dir"
  [[ "$output" != *"allow-list-auto.json"* ]]
}

@test "solkanLists skips the auto allow-list when ralph-mode fails" {
  ralph-mode() {
    print auto
    return 1
  }
  bats_mock ralph-mode

  bats_run_zsh "${sourcePrefix}; solkanLists /some/dir"
  [[ "$output" != *"allow-list-auto.json"* ]]
}

@test "solkanLists passes the directory to ralph-mode" {
  ralph-mode() { print -r -- "$*" > "$BATS_TMP_DIR/ralph-mode-args.txt"; }
  bats_mock ralph-mode

  bats_run_zsh "${sourcePrefix}; solkanLists /some/dir"
  [[ "$(cat "$BATS_TMP_DIR/ralph-mode-args.txt")" == "/some/dir" ]]
}

@test "solkanLists passes the repo-local allow-list and rewrite-list when present" {
  mkdir -p "$BATS_TMP_DIR/fakerepo/.claude"
  echo '["my-local-cmd"]' > "$BATS_TMP_DIR/fakerepo/.claude/allow-list.json"
  echo '{"my-dangerous": "echo"}' > "$BATS_TMP_DIR/fakerepo/.claude/rewrite-list.json"
  git-directory-root() { echo "$BATS_TMP_DIR/fakerepo"; }
  bats_mock git-directory-root

  bats_run_zsh "${sourcePrefix}; solkanLists /some/dir"
  [[ "$output" == *"--allow-list-file"$'\n'"$BATS_TMP_DIR/fakerepo/.claude/allow-list.json"* ]]
  [[ "$output" == *"--rewrite-list-file"$'\n'"$BATS_TMP_DIR/fakerepo/.claude/rewrite-list.json"* ]]
}

@test "solkanLists skips the repo-local lists when absent" {
  mkdir -p "$BATS_TMP_DIR/fakerepo"
  git-directory-root() { echo "$BATS_TMP_DIR/fakerepo"; }
  bats_mock git-directory-root

  bats_run_zsh "${sourcePrefix}; solkanLists /some/dir"
  [[ "$output" != *"fakerepo"* ]]
}

@test "solkanLists passes the session allow-list when the file exists" {
  export CLAUDE_SESSIONS_DIR="$BATS_TMP_DIR/sessions"
  export CLAUDE_SESSION_ID="test"
  mkdir -p "$BATS_TMP_DIR/sessions/test"
  echo '["telnet"]' > "$BATS_TMP_DIR/sessions/test/allow-list.json"

  bats_run_zsh "${sourcePrefix}; solkanLists /some/dir"
  [[ "$output" == *"--allow-list-file"$'\n'"$BATS_TMP_DIR/sessions/test/allow-list.json"* ]]
}

@test "solkanLists skips the session allow-list when the file is absent" {
  export CLAUDE_SESSIONS_DIR="$BATS_TMP_DIR/sessions"
  export CLAUDE_SESSION_ID="test"

  bats_run_zsh "${sourcePrefix}; solkanLists /some/dir"
  [[ "$output" != *"$BATS_TMP_DIR/sessions"* ]]
}

# solkanEvaluate: verdict

@test "solkanEvaluate allows an allow-listed command with no rejected commands" {
  bats_run_zsh "${sourcePrefix}; solkanEvaluate 'git status' /some/dir; print -r -- \"\$? \$SOLKAN_VERDICT [\$SOLKAN_REJECTED]\""
  [[ "$output" == "0 allow []" ]]
}

@test "solkanEvaluate rejects a command with a rejected sub-command and lists it" {
  bats_run_zsh "${sourcePrefix}; solkanEvaluate 'git status && wget evil.com' /some/dir; print -r -- \"\$? \$SOLKAN_VERDICT [\$SOLKAN_REJECTED]\""
  [[ "$output" == "1 reject [wget]" ]]
}

@test "solkanEvaluate lists every rejected command" {
  bats_run_zsh "${sourcePrefix}; solkanEvaluate 'wget a | telnet b' /some/dir; print -r -- \"\${(j:,:)SOLKAN_REJECTED}\""
  [[ "$output" == "wget,telnet" ]]
}

@test "solkanEvaluate allows a command that is only in the session allow-list" {
  export CLAUDE_SESSIONS_DIR="$BATS_TMP_DIR/sessions"
  export CLAUDE_SESSION_ID="test"
  mkdir -p "$BATS_TMP_DIR/sessions/test"
  echo '["telnet"]' > "$BATS_TMP_DIR/sessions/test/allow-list.json"

  bats_run_zsh "${sourcePrefix}; solkanEvaluate 'telnet bad.com' /some/dir; print -r -- \$SOLKAN_VERDICT"
  [[ "$output" == "allow" ]]
}

@test "solkanEvaluate allows python3 in auto mode" {
  ralph-mode() { print auto; }
  bats_mock ralph-mode

  bats_run_zsh "${sourcePrefix}; solkanEvaluate 'python3 x.py' /some/dir; print -r -- \$SOLKAN_VERDICT"
  [[ "$output" == "allow" ]]
}

@test "solkanEvaluate rejects python3 outside auto mode" {
  ralph-mode() { print single; }
  bats_mock ralph-mode

  bats_run_zsh "${sourcePrefix}; solkanEvaluate 'python3 x.py' /some/dir; print -r -- \$SOLKAN_VERDICT"
  [[ "$output" == "reject" ]]
}

# solkanEvaluate: rewrite

@test "solkanEvaluate gives the original command when nothing is rewritten" {
  bats_run_zsh "${sourcePrefix}; solkanEvaluate 'git status' /some/dir; print -r -- \$SOLKAN_COMMAND"
  [[ "$output" == "git status" ]]
}

@test "solkanEvaluate applies the rm guard-rail" {
  bats_run_zsh "${sourcePrefix}; solkanEvaluate 'rm -f a' /some/dir; print -r -- \$SOLKAN_COMMAND"
  [[ "$output" == "rm-guarded -f a" ]]
}

@test "solkanEvaluate applies the guard-rails to a compound command" {
  bats_run_zsh "${sourcePrefix}; solkanEvaluate 'find . -name x | head' /some/dir; print -r -- \$SOLKAN_COMMAND"
  [[ "$output" == "find-guarded . -name x | head" ]]
}

@test "solkanEvaluate keeps /usr/bin/find unchanged" {
  bats_run_zsh "${sourcePrefix}; solkanEvaluate '/usr/bin/find . -name x' /some/dir; print -r -- \$SOLKAN_COMMAND"
  [[ "$output" == "/usr/bin/find . -name x" ]]
}

@test "solkanEvaluate rewrites a command from the repo-local rewrite-list" {
  mkdir -p "$BATS_TMP_DIR/fakerepo/.claude"
  echo '{"my-dangerous": "echo"}' > "$BATS_TMP_DIR/fakerepo/.claude/rewrite-list.json"
  git-directory-root() { echo "$BATS_TMP_DIR/fakerepo"; }
  bats_mock git-directory-root

  bats_run_zsh "${sourcePrefix}; solkanEvaluate 'my-dangerous foo' /some/dir; print -r -- \$SOLKAN_COMMAND"
  [[ "$output" == "echo foo" ]]
}

# solkanEvaluate: token-saving pass

@test "solkanEvaluate gives a single command the token-saving rewrite by default" {
  bats_run_zsh "${sourcePrefix}; solkanEvaluate 'zsh-test a.bats' /some/dir; print -r -- \$SOLKAN_COMMAND"
  [[ "$output" == "zsh-test-token-saving a.bats" ]]
}

@test "solkanEvaluate keeps a quoted operator inside a single command" {
  bats_run_zsh "${sourcePrefix}; solkanEvaluate 'zsh-test \"a | b.bats\"' /some/dir; print -r -- \$SOLKAN_COMMAND"
  [[ "$output" == 'zsh-test-token-saving "a | b.bats"' ]]
}

@test "solkanEvaluate keeps only guard-rails for a single command when the token-saving pass is skipped" {
  bats_run_zsh "${sourcePrefix}; solkanEvaluate --skip-token-saving 'zsh-test a.bats' /some/dir; print -r -- \$SOLKAN_COMMAND"
  [[ "$output" == "zsh-test a.bats" ]]

  bats_run_zsh "${sourcePrefix}; solkanEvaluate --skip-token-saving 'rm -f a' /some/dir; print -r -- \$SOLKAN_COMMAND"
  [[ "$output" == "rm-guarded -f a" ]]
}

@test "solkanEvaluate never gives a compound command the token-saving rewrite" {
  bats_run_zsh "${sourcePrefix}; solkanEvaluate 'zsh-test a.bats | head' /some/dir; print -r -- \$SOLKAN_COMMAND"
  [[ "$output" == "zsh-test a.bats | head" ]]

  bats_run_zsh "${sourcePrefix}; solkanEvaluate 'zsh-test a.bats && echo ok' /some/dir; print -r -- \$SOLKAN_COMMAND"
  [[ "$output" == "zsh-test a.bats && echo ok" ]]
}

@test "solkanEvaluate uses the repo-local token-saving list for a single command only" {
  mkdir -p "$BATS_TMP_DIR/fakerepo/.claude"
  echo '{"my-cmd": "my-cmd-token-saving"}' > "$BATS_TMP_DIR/fakerepo/.claude/rewrite-list-token-saving.json"
  git-directory-root() { echo "$BATS_TMP_DIR/fakerepo"; }
  bats_mock git-directory-root

  bats_run_zsh "${sourcePrefix}; solkanEvaluate 'my-cmd foo' /some/dir; print -r -- \$SOLKAN_COMMAND"
  [[ "$output" == "my-cmd-token-saving foo" ]]

  bats_run_zsh "${sourcePrefix}; solkanEvaluate 'my-cmd foo | cat' /some/dir; print -r -- \$SOLKAN_COMMAND"
  [[ "$output" == "my-cmd foo | cat" ]]
}
