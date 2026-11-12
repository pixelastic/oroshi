bats_load_library 'helper'

setup() {
  bats_tmp_dir

  SEGMENT="${OROSHI_ROOT}/tools/ai/claude/config/statusline/segments/model.zsh"

  colors-load-definitions() {
    typeset -gA COLORS
    COLORS[claude-model]=146
  }
  bats_mock colors-load-definitions
}

@test "writes the model name in the model color" {
  bats_run_zsh "colors-load-definitions; source '$SEGMENT'; getModelSegment 'Sonnet 4.6'; print -r -- \$REPLY"
  [[ "$status" -eq 0 ]]
  [[ "$(bats_strip_ansi "$output")" == "Sonnet 4.6" ]]
  [[ "$output" == *$'\e[38;5;146m'* ]]
}
