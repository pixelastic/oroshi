bats_load_library 'helper'

setup() {
  bats_tmp_dir

  NBSP=$'\u00a0'

  SEGMENT="${OROSHI_ROOT}/tools/ai/claude/config/statusline/segments/context.zsh"

  colors-load-definitions() {
    typeset -gA COLORS
    COLORS[claude-contextHigh]=1
    COLORS[claude-contextMedium]=3
    COLORS[claude-contextLow]=8
  }
  context-badge() { [[ "$1" == "/some/dir" ]] && echo "BADGE"; }
  bats_mock colors-load-definitions context-badge
}

# Source the segment, call it with the given named arguments and print the REPLY
# Usage: context_segment <totalTokens> <contextPercentage> [currentDir]
context_segment() {
  bats_run_zsh "colors-load-definitions; source '$SEGMENT'; getContextSegment --total-tokens $1 --context-percentage $2 --current-dir '${3:-/other/dir}'; print -r -- \$REPLY"
}

@test "formats tokens with a k suffix" {
  context_segment 1000 0
  [[ "$(bats_strip_ansi "$output")" == "1k" ]]

  context_segment 1500 0
  [[ "$(bats_strip_ansi "$output")" == "1.5k" ]]

  context_segment 51000 0
  [[ "$(bats_strip_ansi "$output")" == "51k" ]]
}

@test "colors high when the percentage is 60 or more" {
  context_segment 0 60
  [[ "$output" == *$'\e[38;5;1m'* ]]
}

@test "colors medium when the percentage is below 60" {
  context_segment 0 59
  [[ "$output" == *$'\e[38;5;3m'* ]]
}

@test "colors low when the percentage is below 20" {
  context_segment 0 19
  [[ "$output" == *$'\e[38;5;8m'* ]]
}

@test "puts the context badge before the tokens, joined by a no-break space" {
  context_segment 51000 24 /some/dir
  [[ "$status" -eq 0 ]]
  [[ "$(bats_strip_ansi "$output")" == "BADGE${NBSP}51k" ]]
}

@test "writes only the tokens when the badge is empty" {
  context_segment 51000 24 /other/dir
  [[ "$(bats_strip_ansi "$output")" == "51k" ]]
}
