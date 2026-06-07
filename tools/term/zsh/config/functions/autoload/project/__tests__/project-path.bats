bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  CURRENT="$OROSHI_ZSH_AUTOLOAD/project/project-path"

  projects-load-definitions() {
    typeset -gA PROJECTS
    # shellcheck disable=SC2034
    PROJECTS[my-project:path]="$BATS_GIT_DIR/"
  }
  bats_mock projects-load-definitions
}

teardown() {
  bats_cleanup
}

# --- With argument ---

@test "with arg: returns path of known project" {
  bats_run_zsh "$CURRENT" my-project
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_GIT_DIR/" ]
}

@test "with arg: exits 1 for unknown project" {
  bats_run_zsh "$CURRENT" unknown-project
  [ "$status" -eq 1 ]
}

# --- Without argument (uses current project) ---

@test "no arg: returns path of current project" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_GIT_DIR/" ]
}

@test "no arg: exits 1 outside known project" {
  cd "$BATS_TMP_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 1 ]
}
