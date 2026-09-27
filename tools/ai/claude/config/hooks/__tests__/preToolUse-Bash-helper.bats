bats_load_library 'helper'

setup() {
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../preToolUse-Bash-helper.zsh'"
}

# askReasonFormat

@test "askReasonFormat shows a command with count 0 without symbol" {
  bats_run_zsh "${sourcePrefix}; askReasonFormat --command wget --count 0"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "❌ wget ❌" ]]
}

@test "askReasonFormat shows a command with count 1 with a half moon" {
  bats_run_zsh "${sourcePrefix}; askReasonFormat --command wget --count 1"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "❌ wget 🌓 ❌" ]]
}

@test "askReasonFormat shows a command with count 2 with a full moon" {
  bats_run_zsh "${sourcePrefix}; askReasonFormat --command wget --count 2"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "❌ wget 🌕 ❌" ]]
}

@test "askReasonFormat joins several commands with a comma, each with its own symbol" {
  bats_run_zsh "${sourcePrefix}; askReasonFormat --command /usr/bin/grep --count 2 --command wget --count 0 --command curl --count 1"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "❌ /usr/bin/grep 🌕, wget, curl 🌓 ❌" ]]
}
