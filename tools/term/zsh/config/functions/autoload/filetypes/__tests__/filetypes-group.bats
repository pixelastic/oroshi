bats_load_library 'helper'

setup() {
  filetypes-load-definitions() {
    typeset -gA FILETYPES
    FILETYPES[_fdignore:group]=config
    FILETYPES[_gitignore:group]=config
    FILETYPES[png:group]=image
  }
  bats_mock filetypes-load-definitions
}

@test "dotfile .fdignore returns config group" {
  bats_run_zsh "filetypes-group .fdignore"
  [ "$status" -eq 0 ]
  [ "$output" = "config" ]
}

@test "dotfile .gitignore returns config group" {
  bats_run_zsh "filetypes-group .gitignore"
  [ "$status" -eq 0 ]
  [ "$output" = "config" ]
}

@test "regular file file.png returns image group" {
  bats_run_zsh "filetypes-group file.png"
  [ "$status" -eq 0 ]
  [ "$output" = "image" ]
}

@test "--reply produces no stdout" {
  bats_run_zsh "filetypes-group --reply file.png"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "--reply sets REPLY to group name" {
  bats_run_zsh "filetypes-group --reply file.png && echo \$REPLY"
  [ "$status" -eq 0 ]
  [ "$output" = "image" ]
}
