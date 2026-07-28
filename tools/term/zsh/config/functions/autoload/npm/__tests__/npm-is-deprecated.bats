bats_load_library 'helper'

@test "returns 0 when package is deprecated" {
  npm() {
    echo '{"name":"old-pkg","deprecated":"This package is no longer maintained"}'
  }
  bats_mock npm

  bats_run_zsh "npm-is-deprecated old-pkg"
  [[ "$status" -eq 0 ]]
}

@test "returns 1 when package is not deprecated" {
  npm() {
    echo '{"name":"active-pkg"}'
  }
  bats_mock npm

  bats_run_zsh "npm-is-deprecated active-pkg"
  [[ "$status" -eq 1 ]]
}

@test "returns 1 when package is not published" {
  npm() {
    return 1
  }
  bats_mock npm

  bats_run_zsh "npm-is-deprecated nonexistent-pkg"
  [[ "$status" -eq 1 ]]
}
