bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# --- Root files first ---

@test "root file appears before subdir file" {
  bats_run_zsh "printf 'a/file.txt\nroot.txt' | sort-filepaths"
  local expected="root.txt
a/file.txt"
  [ "$output" = "$expected" ]
}

@test "root files sorted alphabetically" {
  bats_run_zsh "printf 'zebra.txt\nalpha.txt\nmiddle.txt' | sort-filepaths"
  local expected="alpha.txt
middle.txt
zebra.txt"
  [ "$output" = "$expected" ]
}

# --- Files before subdirectories at each level ---

@test "direct file in dir appears before nested file" {
  bats_run_zsh "printf 'a/sub/nested.txt\na/file.txt' | sort-filepaths"
  local expected="a/file.txt
a/sub/nested.txt"
  [ "$output" = "$expected" ]
}

@test "__lib/foo.zsh appears before __lib/__tests__/bar.bats" {
  bats_run_zsh "printf '__lib/__tests__/bar.bats\n__lib/foo.zsh' | sort-filepaths"
  local expected="__lib/foo.zsh
__lib/__tests__/bar.bats"
  [ "$output" = "$expected" ]
}

@test "file before subdir even when subdir name sorts before filename alphabetically" {
  bats_run_zsh "printf 'a/aaa-sub/b.txt\na/z-file.txt' | sort-filepaths"
  local expected="a/z-file.txt
a/aaa-sub/b.txt"
  [ "$output" = "$expected" ]
}

# --- Alphabetical ordering within same level ---

@test "subdirectories within the same parent are sorted alphabetically" {
  bats_run_zsh "printf 'a/z-sub/file.txt\na/a-sub/file.txt' | sort-filepaths"
  local expected="a/a-sub/file.txt
a/z-sub/file.txt"
  [ "$output" = "$expected" ]
}

@test "files within the same directory are sorted alphabetically" {
  bats_run_zsh "printf 'a/zebra.txt\na/alpha.txt\na/middle.txt' | sort-filepaths"
  local expected="a/alpha.txt
a/middle.txt
a/zebra.txt"
  [ "$output" = "$expected" ]
}

# --- Upward paths sort last ---

@test "../sibling path appears after all downward paths" {
  bats_run_zsh "printf '../sibling.txt\na/file.txt\nroot.txt' | sort-filepaths"
  local expected="root.txt
a/file.txt
../sibling.txt"
  [ "$output" = "$expected" ]
}

# --- Edge cases ---

@test "single-file input returns unchanged" {
  bats_run_zsh "sort-filepaths 'a/file.txt'"
  [ "$output" = "a/file.txt" ]
}

@test "empty input returns empty" {
  bats_run_zsh "printf '' | sort-filepaths"
  [ "$output" = "" ]
}

# --- Dotfiles sort after regular files ---

@test "dotfile at root sorts after regular file at root" {
  bats_run_zsh "printf '.fdignore\nMakefile' | sort-filepaths"
  local expected="Makefile
.fdignore"
  [ "$output" = "$expected" ]
}

@test "dotfile at root sorts before any subdirectory file" {
  bats_run_zsh "printf 'sub/file.txt\n.fdignore' | sort-filepaths"
  local expected=".fdignore
sub/file.txt"
  [ "$output" = "$expected" ]
}

@test "dotfile within subdir sorts after regular file in same subdir" {
  bats_run_zsh "printf 'a/.eslintrc\na/index.js' | sort-filepaths"
  local expected="a/index.js
a/.eslintrc"
  [ "$output" = "$expected" ]
}

@test "dotfile within subdir sorts before nested subdir files" {
  bats_run_zsh "printf 'a/sub/nested.txt\na/.eslintrc' | sort-filepaths"
  local expected="a/.eslintrc
a/sub/nested.txt"
  [ "$output" = "$expected" ]
}
