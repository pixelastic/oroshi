bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../../lib/input.zsh'"
}

# hookInit

@test "hookInit keeps the whole hook JSON from stdin in CLAUDE_HOOK_INPUT" {
  bats_run_zsh "${sourcePrefix}; hookInit; print -r -- \"\$CLAUDE_HOOK_INPUT\"" <<<'{"tool_name":"Bash","cwd":"/tmp"}'
  [[ "$status" -eq 0 ]]
  [[ "$output" = '{"tool_name":"Bash","cwd":"/tmp"}' ]]
}

@test "hookInit keeps CLAUDE_HOOK_INPUT out of the environment of child processes" {
  bats_run_zsh "${sourcePrefix}; hookInit; zsh -c 'print -r -- \"[\$CLAUDE_HOOK_INPUT]\"'" <<<'{"tool_name":"Bash"}'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "[]" ]]
}

@test "hookInit sets CLAUDE_SESSION_ID from session_id" {
  bats_run_zsh "${sourcePrefix}; hookInit; print -r -- \"\$CLAUDE_SESSION_ID\"" <<<'{"session_id":"abc-123"}'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "abc-123" ]]
}

@test "hookInit sets CLAUDE_SESSION_DIR from the session id" {
  export CLAUDE_SESSIONS_DIR="/tmp/sessions"
  bats_run_zsh "${sourcePrefix}; hookInit; print -r -- \"\$CLAUDE_SESSION_DIR\"" <<<'{"session_id":"abc-123"}'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "/tmp/sessions/abc-123" ]]
}

@test "hookInit leaves both session variables empty without session_id" {
  bats_run_zsh "${sourcePrefix}; hookInit; print -r -- \"[\$CLAUDE_SESSION_ID][\$CLAUDE_SESSION_DIR]\"" <<<'{"cwd":"/tmp"}'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "[][]" ]]
}

@test "hookInit keeps the session variables out of the environment of child processes" {
  export CLAUDE_SESSIONS_DIR="/tmp/sessions"
  bats_run_zsh "${sourcePrefix}; hookInit; zsh -c 'print -r -- \"[\$CLAUDE_SESSION_ID][\$CLAUDE_SESSION_DIR]\"'" <<<'{"session_id":"abc-123"}'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "[][]" ]]
}

@test "hookInit resolves a relative sessions dir to an absolute path" {
  export CLAUDE_SESSIONS_DIR="relative/sessions"
  bats_run_zsh "cd '/tmp'; ${sourcePrefix}; hookInit; print -r -- \"\$CLAUDE_SESSION_DIR\"" <<<'{"session_id":"abc-123"}'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "/tmp/relative/sessions/abc-123" ]]
}

@test "hookInit lets child processes run with a hook JSON over 128 KB" {
  bats_run_zsh "${sourcePrefix}; hookInit; zsh -c 'print ok'" < <(jq --null-input '{content: ("a" * 200000)}')
  [[ "$status" -eq 0 ]]
  [[ "$output" = "ok" ]]
}


@test "hookInit sets CLAUDE_CWD from cwd" {
  bats_run_zsh "${sourcePrefix}; hookInit; print -r -- \"\$CLAUDE_CWD\"" <<<'{"cwd":"/some/worktree"}'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "/some/worktree" ]]
}

@test "hookInit sets CLAUDE_GIT_ROOT to the git root of cwd inside a git repo" {
  git-directory-is-repository() {
    return 0
  }
  git-directory-root() {
    print -r -- "$BATS_TMP_DIR/fakerepo:$1"
  }
  bats_mock git-directory-is-repository git-directory-root
  bats_run_zsh "${sourcePrefix}; hookInit; print -r -- \"\$CLAUDE_GIT_ROOT\"" <<<'{"cwd":"/some/worktree"}'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$BATS_TMP_DIR/fakerepo:/some/worktree" ]]
}

@test "hookInit leaves CLAUDE_GIT_ROOT empty outside a git repo" {
  git-directory-is-repository() {
    return 1
  }
  bats_mock git-directory-is-repository
  bats_run_zsh "${sourcePrefix}; hookInit; print -r -- \"[\$CLAUDE_GIT_ROOT]\"" <<<'{"cwd":"/some/worktree"}'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "[]" ]]
}

@test "hookInit leaves CLAUDE_CWD and CLAUDE_GIT_ROOT empty without cwd" {
  bats_run_zsh "${sourcePrefix}; hookInit; print -r -- \"[\$CLAUDE_CWD][\$CLAUDE_GIT_ROOT]\"" <<<'{"session_id":"abc-123"}'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "[][]" ]]
}

# inputKeyRead

@test "inputKeyRead extracts command from a Bash input" {
  bats_run_zsh "${sourcePrefix}; hookInit; inputKeyRead '.tool_input.command'" <<<'{"tool_input":{"command":"echo hello"}}'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "echo hello" ]]
}

@test "inputKeyRead returns an empty string for a missing field" {
  bats_run_zsh "${sourcePrefix}; hookInit; inputKeyRead '.tool_input.command'" <<<'{"tool_input":{}}'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

# inputKeyWrite

@test "inputKeyWrite makes inputKeyRead give the new value" {
  bats_run_zsh "${sourcePrefix}; hookInit; inputKeyWrite '.tool_input.command' 'rm-guarded a'; inputKeyRead '.tool_input.command'" <<<'{"tool_input":{"command":"rm a"}}'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "rm-guarded a" ]]
}

@test "inputKeyWrite leaves every other key untouched" {
  bats_run_zsh "${sourcePrefix}; hookInit; inputKeyWrite '.tool_input.command' 'rm-guarded a'; print -r -- \"\$CLAUDE_HOOK_INPUT\"" <<<'{"tool_name":"Bash","cwd":"/tmp","tool_input":{"command":"rm a","description":"Remove","timeout":5000}}'
  [[ "$status" -eq 0 ]]
  expect_json '.tool_input.description' 'Remove'
  expect_json '.tool_input.timeout' '5000'
  expect_json '.tool_name' 'Bash'
  expect_json '.cwd' '/tmp'
}

@test "inputKeyWrite prints nothing" {
  bats_run_zsh "${sourcePrefix}; hookInit; inputKeyWrite '.tool_input.command' 'rm-guarded a'" <<<'{"tool_input":{"command":"rm a"}}'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}
