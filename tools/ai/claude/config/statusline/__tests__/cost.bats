bats_load_library 'helper'

setup() {
  bats_tmp_dir

  SEGMENT="${OROSHI_ROOT}/tools/ai/claude/config/statusline/segments/cost.zsh"

  colors-load-definitions() {
    typeset -gA COLORS
    COLORS[claude-costLow]=6
    COLORS[claude-costHigh]=3
  }
  bats_mock colors-load-definitions
}

# Source the segment, call it with the given cost and print the REPLY
cost_segment() {
  bats_run_zsh "colors-load-definitions; source '$SEGMENT'; getCostSegment $1; print -r -- \$REPLY"
}

@test "formats a cost below one dollar in cents" {
  cost_segment 0.05
  [[ "$status" -eq 0 ]]
  [[ "$(bats_strip_ansi "$output")" == "5¢" ]]
  [[ "$output" == *$'\e[38;5;6m'* ]]
}

@test "formats a cost of one dollar or more in dollars" {
  cost_segment 1.5
  [[ "$status" -eq 0 ]]
  [[ "$(bats_strip_ansi "$output")" == '$1.50' ]]
  [[ "$output" == *$'\e[38;5;3m'* ]]
}
