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
  bats_run_zsh "filetype-group .fdignore"
  [ "$status" -eq 0 ]
  [ "$output" = "config" ]
}

@test "dotfile .gitignore returns config group" {
  bats_run_zsh "filetype-group .gitignore"
  [ "$status" -eq 0 ]
  [ "$output" = "config" ]
}

@test "regular file file.png returns image group" {
  bats_run_zsh "filetype-group file.png"
  [ "$status" -eq 0 ]
  [ "$output" = "image" ]
}
