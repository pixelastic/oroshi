bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source $OROSHI_ROOT/tools/term/zsh/config/keybindings/ctrl-o.zsh"
}

# oroshi-ctrl-o-widget dispatch

@test "widget: dispatches to ctrl-o when LBUFFER is empty" {
  ctrl-o() { echo "/default/dir"; }
  bats_mock ctrl-o

  bats_run_zsh "${sourcePrefix}; LBUFFER=''; oroshi-ctrl-o-widget; echo \$LBUFFER"
  [ "$status" -eq 0 ]
  [ "$output" = "/default/dir " ]
}

@test "widget: dispatches to ctrl-o when last word is not registered" {
  ctrl-o() { echo "/default/dir"; }
  bats_mock ctrl-o

  bats_run_zsh "${sourcePrefix}; LBUFFER='cd '; oroshi-ctrl-o-widget; echo \$LBUFFER"
  [ "$status" -eq 0 ]
  [ "$output" = "cd /default/dir " ]
}

@test "widget: dispatches to fzf-plans when last word is ralph" {
  fzf-plans() { echo "/plans/my-plan"; }
  bats_mock fzf-plans

  bats_run_zsh "${sourcePrefix}; LBUFFER='ralph'; oroshi-ctrl-o-widget; echo \$LBUFFER"
  [ "$status" -eq 0 ]
  [ "$output" = "ralph/plans/my-plan " ]
}

@test "widget: dispatches to fzf-plans when last word is raplh (typo)" {
  fzf-plans() { echo "/plans/my-plan"; }
  bats_mock fzf-plans

  bats_run_zsh "${sourcePrefix}; LBUFFER='raplh'; oroshi-ctrl-o-widget; echo \$LBUFFER"
  [ "$status" -eq 0 ]
  [ "$output" = "raplh/plans/my-plan " ]
}

@test "widget: returns 1 when picker returns empty selection" {
  ctrl-o() { printf ''; }
  bats_mock ctrl-o

  bats_run_zsh "${sourcePrefix}; LBUFFER='cd '; oroshi-ctrl-o-widget"
  [ "$status" -eq 1 ]
}

@test "widget: quotes directory path containing spaces" {
  ctrl-o() { echo "/home/tim/my documents"; }
  bats_mock ctrl-o

  bats_run_zsh "${sourcePrefix}; LBUFFER='cd '; oroshi-ctrl-o-widget; echo \$LBUFFER"
  [ "$status" -eq 0 ]
  [ "$output" = "cd '/home/tim/my documents' " ]
}
