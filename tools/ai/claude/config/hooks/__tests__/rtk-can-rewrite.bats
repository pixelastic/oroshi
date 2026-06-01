setup() {
  SCRIPT="$(dirname "$BATS_TEST_FILENAME")/../rtk-can-rewrite"
}

@test "exits 0 for built-in rtk command" {
  run "$SCRIPT" "git status"
  [ "$status" -eq 0 ]
}

@test "exits 0 for bats (TOML filter)" {
  run "$SCRIPT" "bats foo.bats"
  [ "$status" -eq 0 ]
}

@test "exits 1 for command with no rtk equivalent" {
  run "$SCRIPT" "echo hello"
  [ "$status" -eq 1 ]
}
