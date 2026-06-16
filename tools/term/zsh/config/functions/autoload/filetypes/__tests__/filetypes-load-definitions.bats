bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

@test "no-op if FILETYPES already set" {
  bats_mock_env FILETYPES "preset"
  bats_run_zsh "filetypes-load-definitions; echo \${FILETYPES}"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "preset" ]
}

@test "sources dist/filetypes.zsh from OROSHI_ROOT when FILETYPES is empty" {
  local fakeRoot="${BATS_TMP_DIR}/oroshi"
  bats_mock_env OROSHI_ROOT "$fakeRoot"

  mkdir -p "$fakeRoot/tools/term/zsh/config/theming/dist"
  printf 'typeset -gA FILETYPES\nFILETYPES[sentinel]=42\n' > "$fakeRoot/tools/term/zsh/config/theming/dist/filetypes.zsh"

  bats_run_zsh "filetypes-load-definitions; echo \${FILETYPES[sentinel]}"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "42" ]
}
