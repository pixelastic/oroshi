bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

@test "aligns two columns" {
  bats_run_zsh "table 'foo▮bar'"
  [ "$status" -eq 0 ]
  [ "$output" = "foo  bar" ]
}

@test "accepts piped input" {
  bats_run_zsh "printf 'foo▮bar' | table"
  [ "$status" -eq 0 ]
  [ "$output" = "foo  bar" ]
}

@test "no ellipsis when content fits within terminal width" {
  tput() { echo "40"; }
  bats_mock tput
  bats_run_zsh "table 'col▮short'"
  [ "$status" -eq 0 ]
  [[ "$output" != *"…"* ]]
}

@test "adds ellipsis to last column when line overflows terminal width" {
  tput() { echo "14"; }
  bats_mock tput
  bats_run_zsh "table 'col▮this is a very long message'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"…"* ]]
  local stripped
  stripped="$(bats_strip_ansi "$output")"
  [[ ${#stripped} -le 14 ]]
}

@test "preserves ANSI color codes in non-truncated output" {
  tput() { echo "80"; }
  bats_mock tput
  printf 'col▮\033[31mred\033[0m' > "$BATS_TMP_DIR/input.txt"
  bats_run_zsh "cat $BATS_TMP_DIR/input.txt | table"
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\033[31m'* ]]
}

@test "does not corrupt ANSI ESC bytes when last column is truncated" {
  tput() { echo "10"; }
  bats_mock tput
  printf 'a▮\033[31mlong colored message\033[0m' > "$BATS_TMP_DIR/input.txt"
  bats_run_zsh "cat $BATS_TMP_DIR/input.txt | table"
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\033'* ]]
  [[ "$output" != *$'\xef\xbf\xbd'* ]]
}
