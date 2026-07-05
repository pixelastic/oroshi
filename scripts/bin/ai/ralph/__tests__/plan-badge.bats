bats_load_library 'helper'

setup() {
  bats_tmp_dir
  colors-load-definitions() {
    typeset -gA COLORS
    COLORS[git-issue]=3
    COLORS[success]=2
    COLORS[error]=9
  }
  icons-load-definitions() {
    typeset -gA ICONS
    ICONS[git-issue]="I"
  }
  bats_mock colors-load-definitions icons-load-definitions
}

@test "shows icon and progress when in progress" {
  plan-progress() { echo "1▮3"; }
  bats_mock plan-progress
  bats_run_zsh "plan-badge /some/plan"
  [ "$status" -eq 0 ]
  local clean="$(bats_strip_ansi "$output")"
  [[ "$clean" == "I 1/3" ]]
}

@test "uses success color when done equals total" {
  plan-progress() { echo "2▮2"; }
  bats_mock plan-progress
  bats_run_zsh "plan-badge /some/plan"
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\e[38;5;2m'* ]]
}

@test "shows error icon when plan-progress returns nothing" {
  plan-progress() { return 1; }
  bats_mock plan-progress
  bats_run_zsh "plan-badge /some/plan"
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\e[38;5;9m'* ]]
}

@test "outputs zsh prompt codes with --zsh flag" {
  plan-progress() { echo "1▮3"; }
  bats_mock plan-progress
  bats_run_zsh "plan-badge --zsh /some/plan"
  [ "$status" -eq 0 ]
  [[ "$output" == *"%F{"* ]]
}

@test "empty output when no plan dir and plan-directory returns empty" {
  plan-directory() { echo ""; }
  bats_mock plan-directory
  bats_run_zsh "plan-badge"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
