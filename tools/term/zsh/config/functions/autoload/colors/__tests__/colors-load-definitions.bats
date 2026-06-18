bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "no-op if COLORS already set" {
  bats_mock_env COLORS "preset"
  bats_run_zsh "colors-load-definitions"
  [ "$status" -eq 0 ]
}

@test "sources dist/colors.zsh from OROSHI_ROOT when COLORS is empty" {
  local fakeRoot="${BATS_TMP_DIR}/oroshi"
  bats_mock_env OROSHI_ROOT "$fakeRoot"

  mkdir -p "$fakeRoot/tools/term/zsh/config/theming/dist"
  printf 'typeset -gA COLORS\nCOLORS[sentinel]=42\n' > "$fakeRoot/tools/term/zsh/config/theming/dist/colors.zsh"

  bats_run_zsh "colors-load-definitions; echo \${COLORS[sentinel]}"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "42" ]
}
