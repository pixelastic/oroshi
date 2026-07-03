bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../fzf-options-prompt-label.zsh'"

  colors-load-definitions() {
    typeset -gA COLORS
    COLORS[fzf-commands-background]=143
    COLORS[fzf-commands-foreground]=149
    COLORS[black]=200
  }
  icons-load-definitions() {
    typeset -gA ICONS
    ICONS[fzf-commands]="X"
    ICONS[fzf-separator]=">"
  }
  bats_mock colors-load-definitions icons-load-definitions
}

@test "outputs badge with icon and label" {
  bats_run_zsh "${sourcePrefix}; fzf-options-prompt-label fzf-commands Commands fzf-commands-background fzf-commands-foreground"
  [ "$status" -eq 0 ]
  [[ "$output" == *" X Commands "* ]]
}

@test "badge uses foreground color for text" {
  bats_run_zsh "${sourcePrefix}; fzf-options-prompt-label fzf-commands Commands fzf-commands-background fzf-commands-foreground"
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\e[38;5;149m'* ]]
}

@test "badge uses background color for fill" {
  bats_run_zsh "${sourcePrefix}; fzf-options-prompt-label fzf-commands Commands fzf-commands-background fzf-commands-foreground"
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\e[48;5;143m'* ]]
}

@test "separator uses badge background color as background and black as foreground" {
  bats_run_zsh "${sourcePrefix}; fzf-options-prompt-label fzf-commands Commands fzf-commands-background fzf-commands-foreground"
  [ "$status" -eq 0 ]
  [[ "$output" == *">"* ]]
  [[ "$output" == *$'\e[38;5;200m\e[48;5;143m'">"$'\e[0m'* ]]
}
