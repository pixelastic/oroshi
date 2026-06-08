bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export CURRENT="$OROSHI_ZSH_AUTOLOAD/icons/icons-load-definitions"
}

teardown() {
  bats_cleanup
}

@test "sources icons.zsh when ICONS is empty" {
  local iconsFile="$BATS_TMP_DIR/icons.zsh"
  echo 'typeset -gA ICONS; ICONS[prompt]=">"' > "$iconsFile"

  export OROSHI_ROOT="$BATS_TMP_DIR"
  mkdir -p "$BATS_TMP_DIR/tools/term/zsh/config/theming"
  cp "$iconsFile" "$BATS_TMP_DIR/tools/term/zsh/config/theming/icons.zsh"

  bats_run_function icons-load-definitions
  [ "$status" -eq 0 ]
}

@test "no-op when ICONS is already populated" {
  typeset -gA ICONS
  ICONS[prompt]=">"

  local iconsFile="$BATS_TMP_DIR/icons.zsh"
  echo 'ICONS[prompt]="OVERWRITTEN"' > "$iconsFile"

  export OROSHI_ROOT="$BATS_TMP_DIR"
  mkdir -p "$BATS_TMP_DIR/tools/term/zsh/config/theming"
  cp "$iconsFile" "$BATS_TMP_DIR/tools/term/zsh/config/theming/icons.zsh"

  bats_run_function icons-load-definitions
  [ "$status" -eq 0 ]
  [[ "${ICONS[prompt]}" == ">" ]]
}
