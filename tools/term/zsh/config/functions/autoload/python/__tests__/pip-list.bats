bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "colorizes each package with pip-package-colorize" {
  pip-list-raw() { echo "requests▮2.31.0"; }
  pip-package-colorize() { echo "PKG:$1"; }
  colorize() { echo "colorize:$*"; }
  table() { echo "$*"; }
  bats_mock pip-list-raw pip-package-colorize colorize table

  bats_run_zsh "pip-list"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"PKG:requests"* ]]
}

@test "exits 0 with no output when list is empty" {
  pip-list-raw() { return 0; }
  bats_mock pip-list-raw

  bats_run_zsh "pip-list"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
