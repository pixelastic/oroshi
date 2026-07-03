bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../fzf-source-files.zsh'"

  filetypes-load-definitions() {
    typeset -gA FILETYPES
    FILETYPES[js:color]=200
  }
  colors-load-definitions() {
    typeset -gA COLORS
    COLORS[directory]=100
    COLORS[text]=231
    COLORS[executable]=150
  }
  bats_mock filetypes-load-definitions colors-load-definitions
}

@test "column 2 contains ANSI sequences for a .js file" {
  mkdir -p "$BATS_TMP_DIR/proj"
  touch "$BATS_TMP_DIR/proj/app.js"
  bats_run_zsh "${sourcePrefix}; fzf-source-files '$BATS_TMP_DIR/proj'"
  [ "$status" -eq 0 ]
  local col2="${output#*▮}"
  [[ "$col2" == *$'\e['* ]]
}

@test "column 1 contains no ANSI sequences" {
  mkdir -p "$BATS_TMP_DIR/proj"
  touch "$BATS_TMP_DIR/proj/app.js"
  bats_run_zsh "${sourcePrefix}; fzf-source-files '$BATS_TMP_DIR/proj'"
  [ "$status" -eq 0 ]
  local col1="${output%%▮*}"
  [[ "$col1" != *$'\e['* ]]
}

@test "column 2 contains ANSI sequences for an executable" {
  mkdir -p "$BATS_TMP_DIR/bin"
  touch "$BATS_TMP_DIR/bin/my-script"
  chmod +x "$BATS_TMP_DIR/bin/my-script"
  bats_run_zsh "${sourcePrefix}; fzf-source-files '$BATS_TMP_DIR/bin'"
  [ "$status" -eq 0 ]
  local col2="${output#*▮}"
  [[ "$col2" == *$'\e['* ]]
}

@test "directory segment of nested file is colorized in column 2" {
  mkdir -p "$BATS_TMP_DIR/proj/src"
  touch "$BATS_TMP_DIR/proj/src/app.js"
  bats_run_zsh "${sourcePrefix}; fzf-source-files '$BATS_TMP_DIR/proj'"
  [ "$status" -eq 0 ]
  local col2="${output#*▮}"
  [[ "$col2" == *$'\e[38;5;100m'"src/"$'\e[0m'* ]]
}

@test "filename is colorized in its filetype color in column 2" {
  mkdir -p "$BATS_TMP_DIR/proj"
  touch "$BATS_TMP_DIR/proj/app.js"
  bats_run_zsh "${sourcePrefix}; fzf-source-files '$BATS_TMP_DIR/proj'"
  [ "$status" -eq 0 ]
  local col2="${output#*▮}"
  [[ "$col2" == *$'\e[38;5;200m'"app.js"$'\e[0m'* ]]
}

@test "root files appear before subdirectory files (DFS files-first order)" {
  mkdir -p "$BATS_TMP_DIR/proj/a-dir"
  touch "$BATS_TMP_DIR/proj/z-root.txt"
  touch "$BATS_TMP_DIR/proj/a-dir/nested.txt"
  bats_run_zsh "${sourcePrefix}; fzf-source-files '$BATS_TMP_DIR/proj'"
  [ "$status" -eq 0 ]
  local first_line="$(echo "$output" | head -1)"
  local first_col1="${first_line%%▮*}"
  [[ "$first_col1" == *"z-root.txt" ]]
}
