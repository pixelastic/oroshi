bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$OROSHI_ZSH_AUTOLOAD/python/pip-list"

  pip-list-raw() { echo "requests▮2.31.0"; }
  bats_mock pip-list-raw

  pip-package-colorize() { echo "PKG:$1"; }
  bats_mock pip-package-colorize

  colorize() { echo "$1"; }
  bats_mock colorize

  table() { echo "$1"; }
  bats_mock table
}

teardown() {
  bats_cleanup
}

@test "colorizes package name with pip-package-colorize, exit 0" {
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"PKG:requests"* ]]
}

@test "empty list: exits 0 with no output" {
  pip-list-raw() { return 0; }
  bats_mock pip-list-raw

  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
