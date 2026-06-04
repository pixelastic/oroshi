bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Override source builtin to skip private credential files
  source() {
    [[ "$1" == *private* ]] && return 0
    builtin source "$@"
  }
  bats_mock source
}

teardown() {
  bats_cleanup
}

@test "sourcing wav2txt-openai produces no output and exits cleanly" {
  bats_run_script "$OROSHI_ROOT/scripts/bin/audio/wav2txt-openai"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
