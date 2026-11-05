bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # prose-build writes under $OROSHI_ROOT, so it runs on a copy of the Vale sources
  # and never touches the real dist/ and styles/ that other tests read
  local sandboxRoot="$BATS_TMP_DIR/root"
  mkdir -p "$sandboxRoot/tools/prose/vale"
  cp --recursive "$OROSHI_ROOT/tools/prose/vale/src" "$sandboxRoot/tools/prose/vale/src"
  bats_mock_env "OROSHI_ROOT" "$sandboxRoot"
  SANDBOX_ROOT="$sandboxRoot"

  vale() { :; }
  bats_mock vale
}

@test "creates vocabulary symlink at styles/config/vocabularies/oroshi" {
  bats_run_zsh "prose-build"
  [[ "$status" -eq 0 ]]

  local symlinkPath="$SANDBOX_ROOT/tools/prose/vale/styles/config/vocabularies/oroshi"
  [[ -L "$symlinkPath" ]]
}

@test "running twice does not error (idempotent symlink)" {
  bats_run_zsh "prose-build"
  [[ "$status" -eq 0 ]]
  bats_run_zsh "prose-build"
  [[ "$status" -eq 0 ]]
}

@test "generates one dist file per source profile" {
  bats_run_zsh "prose-build"
  [[ "$status" -eq 0 ]]
  [[ -f "$SANDBOX_ROOT/tools/prose/vale/dist/default.ini" ]]
  [[ -f "$SANDBOX_ROOT/tools/prose/vale/dist/cfp-writer.ini" ]]
}
