bats_load_library 'helper'

setup() {
  bats_tmp_dir
  SCRIPT="$BATS_TEST_DIRNAME/../preToolUse-Bash-solkan.zsh"
  CURRENT="$BATS_TMP_DIR/caller.zsh"
  printf 'preToolUse-Bash-solkan "$@"\n' >"$CURRENT"
  local hooksDir
  hooksDir="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  printf "hookDir='%s'\nsource '%s'\n" "$hooksDir" "$SCRIPT" > "$BATS_TMP_DIR/mock.zsh"
}

teardown() { bats_cleanup; }

@test "exits 0 for an allowlisted simple command" {
  bats_run_zsh "$CURRENT" "git status"
  [ "$status" -eq 0 ]
}

@test "exits 1 for a non-allowlisted simple command" {
  bats_run_zsh "$CURRENT" "wget evil.com"
  [ "$status" -eq 1 ]
}

@test "exits 0 for && compound where all subcommands are allowlisted" {
  bats_run_zsh "$CURRENT" "git status && git log --oneline"
  [ "$status" -eq 0 ]
}

@test "exits 1 for && compound with one non-allowlisted subcommand" {
  bats_run_zsh "$CURRENT" "git status && wget evil.com"
  [ "$status" -eq 1 ]
}

@test "exits 0 for || compound where all subcommands are allowlisted" {
  bats_run_zsh "$CURRENT" "git status || echo fallback"
  [ "$status" -eq 0 ]
}

@test "exits 1 for || compound with one non-allowlisted subcommand" {
  bats_run_zsh "$CURRENT" "git status || wget evil.com"
  [ "$status" -eq 1 ]
}

@test "exits 0 for ; compound where all subcommands are allowlisted" {
  bats_run_zsh "$CURRENT" "git status; echo done"
  [ "$status" -eq 0 ]
}

@test "exits 1 for ; compound with one non-allowlisted subcommand" {
  bats_run_zsh "$CURRENT" "git status; wget evil.com"
  [ "$status" -eq 1 ]
}

@test "exits 0 for pipe where all subcommands are allowlisted" {
  bats_run_zsh "$CURRENT" "git status | grep branch"
  [ "$status" -eq 0 ]
}

@test "exits 1 for pipe with one non-allowlisted subcommand" {
  bats_run_zsh "$CURRENT" "git status | wget evil.com"
  [ "$status" -eq 1 ]
}
