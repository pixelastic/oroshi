setup() {
  SCRIPT="$(dirname "$BATS_TEST_FILENAME")/../preToolUse-Bash-rtk"
}

@test "prints original command when RTK has no equivalent" {
  run "$SCRIPT" "echo hello"
  [ "$status" -eq 0 ]
  [ "$output" = "echo hello" ]
}

@test "prints rewritten command when RTK rewrites" {
  run "$SCRIPT" "git status"
  [ "$status" -eq 0 ]
  [ "$output" = "rtk git status" ]
}

@test "is idempotent when command already uses RTK" {
  run "$SCRIPT" "rtk git status"
  [ "$status" -eq 0 ]
  [ "$output" = "rtk git status" ]
}
