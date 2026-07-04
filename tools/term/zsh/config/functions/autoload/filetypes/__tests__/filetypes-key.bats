bats_load_library 'helper'

@test "dotfile .fdignore → _fdignore" {
  bats_run_zsh "filetypes-key .fdignore && echo \$REPLY"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "_fdignore" ]
}

@test "dotfile .babelrc.json → _babelrc_json" {
  bats_run_zsh "filetypes-key .babelrc.json && echo \$REPLY"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "_babelrc_json" ]
}

@test "regular file app.js → js" {
  bats_run_zsh "filetypes-key app.js && echo \$REPLY"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "js" ]
}

@test "regular file Makefile → empty string" {
  bats_run_zsh "filetypes-key Makefile && echo \"\$REPLY\""
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "" ]
}

@test "filepath src/components/app.js → js" {
  bats_run_zsh "filetypes-key src/components/app.js && echo \$REPLY"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "js" ]
}

@test "filepath config/.fdignore → _fdignore" {
  bats_run_zsh "filetypes-key config/.fdignore && echo \$REPLY"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "_fdignore" ]
}
