bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$BATS_TEST_DIRNAME/../project-exists"

  projects-load-definitions() { typeset -gA PROJECTS; }
  bats_mock projects-load-definitions
}

teardown() {
  bats_cleanup
}

@test "known project with icon: returns exit 0" {
  projects-load-definitions() {
    typeset -gA PROJECTS
    # shellcheck disable=SC2034
    PROJECTS[aberlaas:icon]="  "
  }
  bats_mock projects-load-definitions
  bats_run_zsh "$CURRENT" "aberlaas"
  [ "$status" -eq 0 ]
}

@test "unknown project: returns exit 1" {
  bats_run_zsh "$CURRENT" "unknown"
  [ "$status" -eq 1 ]
}
