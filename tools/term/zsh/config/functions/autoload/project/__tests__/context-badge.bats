bats_load_library 'helper'

setup() {
  bats_tmp_dir

  project-name() { echo "my-project"; }
  bats_mock project-name

  git-worktree-name() { echo ""; }
  bats_mock git-worktree-name

  projects-load-definitions() {
    typeset -gA PROJECTS_V2
    PROJECTS_V2[my-project:background:ansi]=100
    PROJECTS_V2[my-project:foreground:ansi]=255
    PROJECTS_V2[my-project:icon]="x "
    PROJECTS_V2[my-project:hideNameInPrompt]=0
  }
  bats_mock projects-load-definitions

  export COLOR_ORANGE_1=208
  export COLOR_ORANGE_7=130

  export BATS_SEPARATOR=""
}

teardown() {
  bats_cleanup
}

# --- Simple project ---

@test "simple project: output contains name" {
  bats_run_function context-badge /some/path
  local actual="$(bats_strip_ansi "$output")"
  [ "$status" -eq 0 ]
  [[ "$actual" == " x my-project ${BATS_SEPARATOR}" ]]
}

@test "simple project: output has ANSI sequences" {
  bats_run_function context-badge /some/path
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\e['* ]]
}

@test "simple project: --zsh flag outputs zsh codes not ANSI" {
  bats_run_function context-badge /some/path --zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *"%K{"* ]]
  [[ "$output" != *$'\e['* ]]
}

# --- Worktree ---

@test "worktree: output contains project name and branch" {
  git-worktree-name() { echo "fix/bug"; }
  bats_mock git-worktree-name

  bats_run_function context-badge /some/path
  local actual="$(bats_strip_ansi "$output")"
  echo "[[$actual]]"

  [ "$status" -eq 0 ]
  [[ "$actual" == " x my-project ${BATS_SEPARATOR} fix/bug ${BATS_SEPARATOR}" ]]
}

# --- hideNameInPrompt ---

@test "hideNameInPrompt: project name absent from output" {
  projects-load-definitions() {
    typeset -gA PROJECTS_V2
    PROJECTS_V2[my-project:background:ansi]=100
    PROJECTS_V2[my-project:foreground:ansi]=255
    PROJECTS_V2[my-project:icon]=x
    PROJECTS_V2[my-project:hideNameInPrompt]=1
  }
  bats_mock projects-load-definitions

  bats_run_function context-badge /some/path
  local actual="$(bats_strip_ansi "$output")"

  [ "$status" -eq 0 ]
  [[ "$actual" == " x ${BATS_SEPARATOR}" ]]
}
