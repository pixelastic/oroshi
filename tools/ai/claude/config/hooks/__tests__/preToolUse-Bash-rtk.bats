setup() {
  SCRIPT="$(dirname "$BATS_TEST_FILENAME")/../preToolUse-Bash-rtk"

  printf '#!/usr/bin/env zsh\nexit 1\n' > "$BATS_TEST_TMPDIR/mock-rtk-no-equiv"
  printf '#!/usr/bin/env zsh\nprint -- "rtk $2"\n' > "$BATS_TEST_TMPDIR/mock-rtk-rewrite"
  chmod +x "$BATS_TEST_TMPDIR"/mock-rtk-*
}

@test "prints original command when rtk rewrite has no equivalent (exit 1)" {
  run env RTK_CMD="$BATS_TEST_TMPDIR/mock-rtk-no-equiv" "$SCRIPT" "echo hello"
  [ "$status" -eq 0 ]
  [ "$output" = "echo hello" ]
}

@test "prints rewritten command from rtk rewrite stdout" {
  run env RTK_CMD="$BATS_TEST_TMPDIR/mock-rtk-rewrite" "$SCRIPT" "echo hello"
  [ "$status" -eq 0 ]
  [ "$output" = "rtk echo hello" ]
}

@test "is idempotent when command already uses RTK" {
  run "$SCRIPT" "rtk git status"
  [ "$status" -eq 0 ]
  [ "$output" = "rtk git status" ]
}
