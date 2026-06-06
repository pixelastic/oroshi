bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$BATS_TEST_DIRNAME/../git-submodule-list"
}

teardown() {
  bats_cleanup
}

@test "parses submodule status without warnings" {
  git() { echo " abc12345678 some/module (main)"; }
  git-directory-root() { echo "/repo"; }
  path-relative() { echo "$1"; }
  sort-filepaths() { echo "$@"; }
  git-submodule-colorize() { echo "$1"; }
  git-branch-colorize() { echo "$1"; }
  git-commit-colorize() { echo "$1"; }
  table() { echo "$1"; }
  bats_mock git git-directory-root path-relative sort-filepaths git-submodule-colorize git-branch-colorize git-commit-colorize table

  local mockFile="$BATS_TMP_DIR/mock.zsh"
  run --separate-stderr zsh -c "[[ -f '${mockFile}' ]] && source '${mockFile}'; source '${CURRENT}'"

  [ "$status" -eq 0 ]
  [[ "$output" == *"main"* ]]
  [[ "$stderr" != *"substring expression"* ]]
}
