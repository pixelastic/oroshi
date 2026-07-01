bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../fzf-colorize-path.zsh'"

  filetypes-load-definitions() {
    typeset -gA FILETYPES
    FILETYPES[js:color]=200
  }
  colors-load-definitions() {
    typeset -gA COLORS
    COLORS[directory]=100
    COLORS[text]=231
    COLORS[executable]=150
  }
  bats_mock filetypes-load-definitions colors-load-definitions
}

@test "colorizes directory segment and .js filename in respective colors" {
  bats_run_zsh "${sourcePrefix}; fzf-colorize-path 'src/app.js'; print -r -- \$REPLY"
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\e[38;5;100m'"src/"$'\e[0m'* ]]
  [[ "$output" == *$'\e[38;5;200m'"app.js"$'\e[0m'* ]]
}

@test "colorizes .js filename at root without directory prefix" {
  bats_run_zsh "${sourcePrefix}; fzf-colorize-path 'app.js'; print -r -- \$REPLY"
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\e[38;5;200m'"app.js"$'\e[0m'* ]]
  [[ "$output" != *$'\e[38;5;100m'* ]]
}

@test "colorizes no-extension executable in executable color" {
  touch "$BATS_TMP_DIR/my-script"
  chmod +x "$BATS_TMP_DIR/my-script"
  bats_run_zsh "${sourcePrefix}; fzf-colorize-path '$BATS_TMP_DIR/my-script'; print -r -- \$REPLY"
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\e[38;5;150m'"my-script"$'\e[0m'* ]]
}

@test "uses real-path for executable check when display-path differs" {
  touch "$BATS_TMP_DIR/my-script"
  chmod +x "$BATS_TMP_DIR/my-script"
  bats_run_zsh "${sourcePrefix}; fzf-colorize-path 'proj/…/bin/my-script' '$BATS_TMP_DIR/my-script'; print -r -- \$REPLY"
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\e[38;5;150m'"my-script"$'\e[0m'* ]]
}
