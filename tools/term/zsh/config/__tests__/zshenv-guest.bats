bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '$BATS_TEST_DIRNAME/../zshenv-guest.zsh'"
  MOCK_FILE="$BATS_TMP_DIR/mock.zsh"

  mock_env "OROSHI_ROOT" "$BATS_TMP_DIR"

  # Mock $PATH
  mkdir -p "$BATS_TMP_DIR/tools/term/zsh/config"
  touch "$BATS_TMP_DIR/tools/term/zsh/config/path.zsh"
  mock_command "oroshi-reload-path" 'echo "PATH:$1";'

  # Mock $fpath
  mkdir -p "$BATS_TMP_DIR/tools/term/zsh/config/functions"
  touch "$BATS_TMP_DIR/tools/term/zsh/config/functions/oroshi-reload-fpath.zsh"
  mock_command "oroshi-reload-fpath" 'echo "fpath:$1";'
}

teardown() {
  bats_cleanup
}

# Run zsh without any config nor ENV variable (except mocked), so we can safely
# source zshenv-host.zsh and test its behavior in isolation.
run_bare_zsh() {
  zshCommand="$1"

  # Prepend mock file if present
  zshCommandPrefix="";
  [[ -f "$MOCK_FILE" ]] && zshCommandPrefix="source $MOCK_FILE;"

  # -f ignores all config files
  # -i ignore all existing ENV variables
  # bats-lint disable=noRunZsh
  run zsh -f -i -c "$zshCommandPrefix $zshCommand"
}

# Mock an ENV variable for run_bare_zsh
mock_env() {
  echo "export $1='$2'" >> "$MOCK_FILE"
}

# Mock a command for run_bare_zsh
mock_command() {
  echo "function ${1}() { $2 }" >> "$MOCK_FILE"
}

@test "set PATH and fpath relative to OROSHI_ROOT" {
  run_bare_zsh "$sourcePrefix"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "PATH:$BATS_TMP_DIR" ]
  [ "${lines[1]}" = "fpath:$BATS_TMP_DIR" ]
}

@test "allow overriding anything through MOCK_OVERRIDE" {
  mock_env "MOCK_OVERRIDE" "$BATS_TMP_DIR/mock-override.zsh"
  echo "function override() { echo 'overriden'; }" > "$BATS_TMP_DIR/mock-override.zsh"

  run_bare_zsh "$sourcePrefix && override"
  [ "$status" -eq 0 ]
  [ "${lines[2]}" = "overriden" ]
}
