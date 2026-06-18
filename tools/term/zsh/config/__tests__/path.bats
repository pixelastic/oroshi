bats_load_library 'helper'

setup() {
  bats_tmp_dir
  FAKE_ROOT_A="$BATS_TMP_DIR/rootA"
  FAKE_ROOT_B="$BATS_TMP_DIR/rootB"
  mkdir -p "$FAKE_ROOT_A/scripts/bin/alpha"
  mkdir -p "$FAKE_ROOT_B/scripts/bin/gamma"
}

@test "given a root arg, PATH contains scripts/bin subdirs of that root" {
  bats_run_zsh "oroshi-reload-path $FAKE_ROOT_B; echo \$PATH"
  [ "$status" -eq 0 ]
  [[ "$output" == *"$FAKE_ROOT_B/scripts/bin/gamma"* ]]
}

@test "given a root arg, PATH does not contain scripts/bin subdirs from OROSHI_ROOT" {
  bats_run_zsh "oroshi-reload-path $FAKE_ROOT_B; echo \$PATH"
  [ "$status" -eq 0 ]
  [[ "$output" != *"$FAKE_ROOT_A/scripts/bin/alpha"* ]]
}

@test "given no arg, PATH contains scripts/bin subdirs from OROSHI_ROOT" {
  bats_mock_env OROSHI_ROOT "$FAKE_ROOT_A"
  bats_run_zsh "oroshi-reload-path; echo \$PATH"
  [ "$status" -eq 0 ]
  [[ "$output" == *"$FAKE_ROOT_A/scripts/bin/alpha"* ]]
}
