bats_load_library 'helper'

@test "creates vocabulary symlink at styles/config/vocabularies/oroshi" {
  vale() { :; }
  bats_mock vale

  bats_run_zsh "prose-build"
  [[ "$status" -eq 0 ]]

  local symlinkPath="$OROSHI_ROOT/tools/prose/vale/styles/config/vocabularies/oroshi"
  [[ -L "$symlinkPath" ]]
}

@test "running twice does not error (idempotent symlink)" {
  vale() { :; }
  bats_mock vale

  bats_run_zsh "prose-build"
  [[ "$status" -eq 0 ]]
  bats_run_zsh "prose-build"
  [[ "$status" -eq 0 ]]
}
