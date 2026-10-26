bats_load_library 'helper'

setup() {
  bats_tmp_dir
  hooksDir="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  sourcePrefix="source '${hooksDir}/lib/solkan.zsh'"

  # Zsh helpers for the scripts of runSolkanScript: one output line per evaluation
  cat > "$BATS_TMP_DIR/helpers.zsh" <<'ZSH'
verdictOf() {
  solkanEvaluate "$@"
  print -r -- "$SOLKAN_VERDICT [${(j:,:)SOLKAN_ALLOWED}] [${(j:,:)SOLKAN_REJECTED}]"
}
rewriteOf() {
  solkanEvaluate "$@"
  print -r -- "$SOLKAN_VERDICT: $SOLKAN_COMMAND"
}
solkan() {
  print x >> "$BATS_TMP_DIR/solkan-calls"
  command solkan "$@"
}
callsOf() {
  : > "$BATS_TMP_DIR/solkan-calls"
  solkanEvaluate "$@"
  local -a calls=(${(f)"$(<"$BATS_TMP_DIR/solkan-calls")"})
  print -r -- "${#calls} ${@[-1]}"
}
ZSH
}

# Run the zsh script read from stdin, with solkanEvaluate, verdictOf, rewriteOf and callsOf available
runSolkanScript() {
  cat > "$BATS_TMP_DIR/script.zsh"
  bats_run_zsh "${sourcePrefix}; source '${BATS_TMP_DIR}/helpers.zsh'; source '${BATS_TMP_DIR}/script.zsh'"
}

# getSolkanArgs

@test "getSolkanArgs passes the global allow-list and rewrite-list" {
  bats_run_zsh "${sourcePrefix}; getSolkanArgs"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--allow-list-file"$'\n'"${hooksDir}/allow-list.json"* ]]
  [[ "$output" == *"--rewrite-list-file"$'\n'"${hooksDir}/rewrite-list.json"* ]]
}

@test "getSolkanArgs passes the auto allow-list after the global one when ralph-mode prints auto" {
  ralph-mode() { print auto; }
  bats_mock ralph-mode

  bats_run_zsh "${sourcePrefix}; getSolkanArgs"
  [[ "$output" == *"/allow-list.json"*"/allow-list-auto.json"* ]]
}

@test "getSolkanArgs skips the auto allow-list when ralph-mode prints single" {
  ralph-mode() { print single; }
  bats_mock ralph-mode

  bats_run_zsh "${sourcePrefix}; getSolkanArgs"
  [[ "$output" != *"allow-list-auto.json"* ]]
}

@test "getSolkanArgs skips the auto allow-list when ralph-mode prints nothing" {
  ralph-mode() { return 0; }
  bats_mock ralph-mode

  bats_run_zsh "${sourcePrefix}; getSolkanArgs"
  [[ "$output" != *"allow-list-auto.json"* ]]
}

@test "getSolkanArgs passes CLAUDE_CWD to ralph-mode" {
  ralph-mode() { print -r -- "$*" > "$BATS_TMP_DIR/ralph-mode-args.txt"; }
  bats_mock ralph-mode

  bats_run_zsh "${sourcePrefix}; CLAUDE_CWD=/some/dir; getSolkanArgs"
  [[ "$(cat "$BATS_TMP_DIR/ralph-mode-args.txt")" == "/some/dir" ]]
}

@test "getSolkanArgs passes the repo-local allow-list and rewrite-list when present" {
  mkdir -p "$BATS_TMP_DIR/fakerepo/.claude"
  echo '["my-local-cmd"]' > "$BATS_TMP_DIR/fakerepo/.claude/allow-list.json"
  echo '{"my-dangerous": "echo"}' > "$BATS_TMP_DIR/fakerepo/.claude/rewrite-list.json"
  export CLAUDE_GIT_ROOT="$BATS_TMP_DIR/fakerepo"

  bats_run_zsh "${sourcePrefix}; getSolkanArgs"
  [[ "$output" == *"--allow-list-file"$'\n'"$BATS_TMP_DIR/fakerepo/.claude/allow-list.json"* ]]
  [[ "$output" == *"--rewrite-list-file"$'\n'"$BATS_TMP_DIR/fakerepo/.claude/rewrite-list.json"* ]]
}

@test "getSolkanArgs skips the repo-local lists when absent" {
  mkdir -p "$BATS_TMP_DIR/fakerepo"
  export CLAUDE_GIT_ROOT="$BATS_TMP_DIR/fakerepo"

  bats_run_zsh "${sourcePrefix}; getSolkanArgs"
  [[ "$output" != *"fakerepo"* ]]
}

@test "getSolkanArgs passes the session allow-list when the file exists" {
  export CLAUDE_SESSION_DIR="$BATS_TMP_DIR/sessions/test"
  mkdir -p "$BATS_TMP_DIR/sessions/test"
  echo '["telnet"]' > "$BATS_TMP_DIR/sessions/test/allow-list.json"

  bats_run_zsh "${sourcePrefix}; getSolkanArgs"
  [[ "$output" == *"--allow-list-file"$'\n'"$BATS_TMP_DIR/sessions/test/allow-list.json"* ]]
}

@test "getSolkanArgs skips the session allow-list when the file is absent" {
  export CLAUDE_SESSION_DIR="$BATS_TMP_DIR/sessions/test"

  bats_run_zsh "${sourcePrefix}; getSolkanArgs"
  [[ "$output" != *"$BATS_TMP_DIR/sessions"* ]]
}

# solkanEvaluate
# Each test runs several evaluations in one zsh: Solkan is slow to start

@test "solkanEvaluate gives the verdict, the allowed and the rejected commands" {
  runSolkanScript <<'ZSH'
verdictOf 'git status'
verdictOf 'git status && wget evil.com'
verdictOf 'wget a | telnet b'
ZSH
  [[ "$status" -eq 0 ]]
  [[ "$output" == "allow [git status] []
reject [git status] [wget]
reject [] [wget,telnet]" ]]
}

@test "solkanEvaluate applies the guard-rails, alone or in a compound command" {
  runSolkanScript <<'ZSH'
rewriteOf 'git status'
rewriteOf 'rm -f a'
rewriteOf 'find . -name x | head'
rewriteOf '/usr/bin/find . -name x'
ZSH
  [[ "$status" -eq 0 ]]
  [[ "$output" == "allow: git status
allow: rm-guarded -f a
allow: find-guarded . -name x | head
allow: /usr/bin/find . -name x" ]]
}

@test "solkanEvaluate applies the shipped rewrite lists" {
  runSolkanScript <<'ZSH'
rewriteOf 'ls -la dir'
rewriteOf 'grep -c x f'
rewriteOf 'cat hooks/stop'
rewriteOf 'rmdir emptydir'
rewriteOf 'google-login'
rewriteOf 'google-login --account perso'
rewriteOf 'google-login --account perso | cat && google-login || echo failed'
ZSH
  [[ "$status" -eq 0 ]]
  [[ "$output" == "allow: ls-token-saving -la dir
allow: grep -c x f
allow: cat hooks/stop
allow: rmdir-guarded emptydir
allow: google-login-guarded
allow: google-login-guarded --account perso
allow: google-login-guarded --account perso | cat && google-login-guarded || echo failed" ]]
}

@test "solkanEvaluate gives only a single command the token-saving rewrite, unless it is skipped" {
  runSolkanScript <<'ZSH'
rewriteOf 'zsh-test a.bats'
rewriteOf 'zsh-test "a | b.bats"'
rewriteOf --skip-token-saving 'zsh-test a.bats'
rewriteOf --skip-token-saving 'rm -f a'
rewriteOf 'zsh-test a.bats | head'
rewriteOf 'zsh-test a.bats && echo ok'
ZSH
  [[ "$status" -eq 0 ]]
  [[ "$output" == 'allow: zsh-test-token-saving a.bats
allow: zsh-test-token-saving "a | b.bats"
allow: zsh-test a.bats
allow: rm-guarded -f a
allow: zsh-test a.bats | head
allow: zsh-test a.bats && echo ok' ]]
}

@test "solkanEvaluate uses the session allow-list and the repo-local rewrite lists" {
  export CLAUDE_SESSION_DIR="$BATS_TMP_DIR/sessions/test"
  mkdir -p "$BATS_TMP_DIR/sessions/test"
  echo '["telnet"]' > "$BATS_TMP_DIR/sessions/test/allow-list.json"

  mkdir -p "$BATS_TMP_DIR/fakerepo/.claude"
  echo '{"my-dangerous": "echo"}' > "$BATS_TMP_DIR/fakerepo/.claude/rewrite-list.json"
  echo '{"my-cmd": "my-cmd-token-saving"}' > "$BATS_TMP_DIR/fakerepo/.claude/rewrite-list-token-saving.json"
  export CLAUDE_GIT_ROOT="$BATS_TMP_DIR/fakerepo"

  runSolkanScript <<'ZSH'
verdictOf 'telnet bad.com'
rewriteOf 'my-dangerous foo'
rewriteOf 'my-cmd foo'
rewriteOf 'my-cmd foo | cat'
ZSH
  [[ "$status" -eq 0 ]]
  [[ "$output" == "allow [telnet] []
allow: echo foo
reject: my-cmd-token-saving foo
reject: my-cmd foo | cat" ]]
}

@test "solkanEvaluate allows python3 only in ralph auto mode" {
  runSolkanScript <<'ZSH'
ralph-mode() { print auto; }
verdictOf 'python3 x.py'
ralph-mode() { print single; }
verdictOf 'python3 x.py'
ZSH
  [[ "$status" -eq 0 ]]
  [[ "$output" == "allow [python3] []
reject [] [python3]" ]]
}

@test "solkanEvaluate runs Solkan a second time only for a single command found in a token-saving list" {
  mkdir -p "$BATS_TMP_DIR/fakerepo/.claude"
  echo '{"my-cmd": "my-cmd-token-saving"}' > "$BATS_TMP_DIR/fakerepo/.claude/rewrite-list-token-saving.json"
  export CLAUDE_GIT_ROOT="$BATS_TMP_DIR/fakerepo"

  runSolkanScript <<'ZSH'
callsOf 'git status'
callsOf 'wget evil.com'
callsOf 'ls -la dir'
callsOf 'my-cmd foo'
callsOf 'ls -la | cat'
callsOf --skip-token-saving 'ls -la dir'
ZSH
  [[ "$status" -eq 0 ]]
  [[ "$output" == "1 git status
1 wget evil.com
2 ls -la dir
2 my-cmd foo
1 ls -la | cat
1 ls -la dir" ]]
}
