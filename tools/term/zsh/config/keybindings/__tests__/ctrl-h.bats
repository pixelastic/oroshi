bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source $OROSHI_ROOT/tools/term/zsh/config/keybindings/ctrl-h.zsh"
}


# binding

@test "binding: ^H is bound to the history widget" {
  bats_run_zsh "${sourcePrefix}; bindkey '^H'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = *"oroshi-ctrl-h-widget"* ]]
}

@test "binding: ^R is not bound to the history widget" {
  bats_run_zsh "${sourcePrefix}; bindkey '^R'"
  [[ "$output" != *"oroshi-ctrl-h-widget"* ]]
}


# oroshi-ctrl-h-widget

@test "widget: appends the selected history entry to LBUFFER" {
  ctrl-h() { echo "git status"; }
  bats_mock ctrl-h

  bats_run_zsh "${sourcePrefix}; LBUFFER=''; oroshi-ctrl-h-widget; echo \$LBUFFER"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "git status " ]]
}

@test "widget: returns 1 when picker returns empty selection" {
  ctrl-h() { printf ''; }
  bats_mock ctrl-h

  bats_run_zsh "${sourcePrefix}; LBUFFER=''; oroshi-ctrl-h-widget"
  [[ "$status" -eq 1 ]]
}
