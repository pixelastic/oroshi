bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source $OROSHI_ROOT/tools/term/zsh/config/keybindings/ctrl-p.zsh"
}


# oroshi-ctrl-p-widget dispatch

@test "widget: dispatches to ctrl-p when LBUFFER is empty" {
  ctrl-p() { echo "src/file.ts"; }
  bats_mock ctrl-p

  bats_run_zsh "${sourcePrefix}; LBUFFER=''; oroshi-ctrl-p-widget; echo \$LBUFFER"
  [ "$status" -eq 0 ]
  [ "$output" = "src/file.ts " ]
}

@test "widget: dispatches to fzf-git-files-dirty-stageable when last word is vfa" {
  fzf-git-files-dirty-stageable() { echo "src/file.ts"; }
  bats_mock fzf-git-files-dirty-stageable

  bats_run_zsh "${sourcePrefix}; LBUFFER='vfa '; oroshi-ctrl-p-widget; echo \$LBUFFER"
  [ "$status" -eq 0 ]
  [ "$output" = "vfa src/file.ts " ]
}

@test "widget: joins multiple selected files with spaces" {
  fzf-git-files-dirty-stageable() { printf 'src/a.ts\nsrc/b.ts'; }
  bats_mock fzf-git-files-dirty-stageable

  bats_run_zsh "${sourcePrefix}; LBUFFER='vfa '; oroshi-ctrl-p-widget; echo \$LBUFFER"
  [ "$status" -eq 0 ]
  [ "$output" = "vfa src/a.ts src/b.ts " ]
}

@test "widget: returns 1 when picker returns empty selection" {
  ctrl-p() { printf ''; }
  bats_mock ctrl-p

  bats_run_zsh "${sourcePrefix}; LBUFFER=''; oroshi-ctrl-p-widget"
  [ "$status" -eq 1 ]
}
