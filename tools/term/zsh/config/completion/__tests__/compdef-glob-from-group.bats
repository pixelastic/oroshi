bats_load_library 'helper'

setup() {
  bats_tmp_dir

  filetypes-load-definitions() {
    typeset -gA FILETYPES
    FILETYPES[zip:pattern]='*.zip'
    FILETYPES[zip:group]='archive'
    FILETYPES[rar:pattern]='*.rar'
    FILETYPES[rar:group]='archive'
    FILETYPES[txt:pattern]='*.txt'
    FILETYPES[txt:group]='text'
  }
  bats_mock filetypes-load-definitions
}

teardown() {
  bats_cleanup
}

@test "builds a glob from all extensions in the given group" {
  bats_run_zsh "
    source \$OROSHI_ROOT/tools/term/zsh/config/completion/compdef-glob-from-group.zsh
    compdef-glob-from-group archive
  "
  [ "$status" -eq 0 ]
  [ "$output" = "*.{rar,zip}" ]
}
