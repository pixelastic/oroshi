bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_disable_worktree_aware
  bats_mock_env "EXA_COLORS" ""

  filetypes-load-definitions() {
    typeset -gA FILETYPES
    FILETYPES[zsh:color]=99
  }
  exa() {
    echo "$EXA_COLORS" > "$BATS_TMP_DIR/exa-colors"
  }
  bats_mock filetypes-load-definitions exa
}

@test "inside autoload directory: exa receives fi= override in EXA_COLORS" {
  local autoloadDir="$BATS_TMP_DIR/functions/autoload/term/zsh"
  mkdir -p "$autoloadDir"
  bats_run_zsh "cd $autoloadDir && better-ls"
  [ "$status" -eq 0 ]
  local captured
  captured="$(cat "$BATS_TMP_DIR/exa-colors")"
  [[ "$captured" == *"fi=38;5;99"* ]]
}

@test "outside autoload directory: exa receives no fi= override in EXA_COLORS" {
  bats_run_zsh "cd $BATS_TMP_DIR && better-ls"
  [ "$status" -eq 0 ]
  local captured
  captured="$(cat "$BATS_TMP_DIR/exa-colors")"
  [[ "$captured" != *"fi="* ]]
}
