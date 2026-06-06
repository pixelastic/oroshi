bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$BATS_TMP_DIR/caller.zsh"
  PATH_ZSH="$OROSHI_ROOT/tools/term/zsh/config/path.zsh"

  FAKE_ROOT_A="$BATS_TMP_DIR/rootA"
  FAKE_ROOT_B="$BATS_TMP_DIR/rootB"
  mkdir -p "$FAKE_ROOT_A/scripts/bin/alpha"
  mkdir -p "$FAKE_ROOT_B/scripts/bin/gamma"
}

teardown() {
  bats_cleanup
}

@test "given a root arg, PATH contains scripts/bin subdirs of that root" {
  printf 'set -e; typeset -aU path; export OROSHI_ROOT="%s"; source "%s"; oroshi-reload-path "%s"; echo "$PATH"\n' \
    "$FAKE_ROOT_A" "$PATH_ZSH" "$FAKE_ROOT_B" >"$CURRENT"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"$FAKE_ROOT_B/scripts/bin/gamma"* ]]
}

@test "given a root arg, PATH does not contain scripts/bin subdirs from OROSHI_ROOT" {
  printf 'set -e; typeset -aU path; export OROSHI_ROOT="%s"; source "%s"; oroshi-reload-path "%s"; echo "$PATH"\n' \
    "$FAKE_ROOT_A" "$PATH_ZSH" "$FAKE_ROOT_B" >"$CURRENT"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "$output" != *"$FAKE_ROOT_A/scripts/bin/alpha"* ]]
}

@test "given no arg, PATH contains scripts/bin subdirs from OROSHI_ROOT" {
  printf 'set -e; typeset -aU path; export OROSHI_ROOT="%s"; source "%s"; oroshi-reload-path; echo "$PATH"\n' \
    "$FAKE_ROOT_A" "$PATH_ZSH" >"$CURRENT"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"$FAKE_ROOT_A/scripts/bin/alpha"* ]]
}
