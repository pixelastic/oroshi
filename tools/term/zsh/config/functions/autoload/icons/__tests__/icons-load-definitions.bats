bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "sources config from mock root" {
  mkdir -p "$BATS_TMP_DIR/tools/term/zsh/config/theming/dist"
  echo 'typeset -gA ICONS; ICONS[test-key]="test-val"' > "$BATS_TMP_DIR/tools/term/zsh/config/theming/dist/icons.zsh"

  bats_mock_env "OROSHI_ROOT" "$BATS_TMP_DIR"
  bats_run_zsh "icons-load-definitions"
  # REVIEW: Should test that ICONS[test-key] has teh right value
  [ "$status" -eq 0 ]
}

@test "no-op when ICONS is already populated" {
  mkdir -p "$BATS_TMP_DIR/tools/term/zsh/config/theming/dist"
  local markerFile="$BATS_TMP_DIR/sourced"
  printf 'touch "%s"\n' "$markerFile" > "$BATS_TMP_DIR/tools/term/zsh/config/theming/dist/icons.zsh"

  # Pre-populate ICONS in the subprocess so the function exits early
  echo 'typeset -gA ICONS; ICONS[prompt]=">"' >> "$BATS_TMP_DIR/mock.zsh"

  bats_mock_env "OROSHI_ROOT" "$BATS_TMP_DIR"
  bats_run_zsh "icons-load-definitions"
  [ "$status" -eq 0 ]
  [[ ! -f "$markerFile" ]]
}
