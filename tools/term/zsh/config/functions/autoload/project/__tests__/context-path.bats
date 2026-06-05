bats_load_library 'helper'

setup() {
  CURRENT="$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/project/context-path"
  projects-load-definitions() { true; }
  bats_mock projects-load-definitions
}

teardown() {
  bats_cleanup
}

@test "path inside project: returns sub-path without leading slash" {
  context-root() { echo "/my/root"; }
  bats_mock context-root
  bats_run_zsh "$CURRENT" /my/root/src/foo
  [ "$status" -eq 0 ]
  [ "$output" = "src/foo" ]
}

@test "path at project root: returns empty string" {
  context-root() { echo "/my/root"; }
  bats_mock context-root
  bats_run_zsh "$CURRENT" /my/root
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "path outside all known projects: returns empty string" {
  context-root() { echo ""; }
  bats_mock context-root
  bats_run_zsh "$CURRENT" /tmp/unregistered
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
