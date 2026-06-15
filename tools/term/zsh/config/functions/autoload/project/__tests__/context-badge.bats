bats_load_library 'helper'

setup() {
  bats_tmp_dir

  colors-load-definitions() {
    typeset -gA COLORS
    COLORS[git-worktree]=42
    COLORS[git-worktree-foreground]=99
  }
  project-name() { echo "my-project"; }
  git-worktree-name() { echo ""; }
  projects-load-definitions() {
    typeset -gA PROJECTS
    PROJECTS[my-project:background:ansi]=77
    PROJECTS[my-project:foreground:ansi]=11
    PROJECTS[my-project:icon]="x "
    PROJECTS[my-project:hideNameInPrompt]=0
  }
  icons-load-definitions() {
    typeset -gA ICONS
    ICONS[badge-separator]="S"
  }
  bats_mock colors-load-definitions project-name git-worktree-name projects-load-definitions icons-load-definitions
}

teardown() {
  bats_cleanup
}

# --- Simple project ---

@test "simple project: output contains name" {
  bats_run_zsh "context-badge /some/path"
  local actual="$(bats_strip_ansi "$output")"
  [[ "$status" -eq 0 ]]
  [[ "$actual" == " x my-project S" ]]
}

@test "simple project: output has ANSI sequences" {
  bats_run_zsh "context-badge /some/path"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *$'\e['* ]]
}

@test "simple project: --zsh flag outputs zsh codes not ANSI" {
  bats_run_zsh "context-badge /some/path --zsh"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"%K{"* ]]
  [[ "$output" != *$'\e['* ]]
}

# --- Worktree ---

@test "worktree: output contains project name and branch" {
  git-worktree-name() { echo "fix/bug"; }
  bats_mock git-worktree-name

  bats_run_zsh "context-badge /some/path"
  local actual="$(bats_strip_ansi "$output")"

  [[ "$status" -eq 0 ]]
  [[ "$actual" == " x my-project S fix/bug S" ]]
}

# --- hideNameInPrompt ---

@test "hideNameInPrompt: project name absent from output" {
  projects-load-definitions() {
    typeset -gA PROJECTS
    PROJECTS[my-project:background:ansi]=77
    PROJECTS[my-project:foreground:ansi]=11
    PROJECTS[my-project:icon]=x
    PROJECTS[my-project:hideNameInPrompt]=1
  }
  bats_mock projects-load-definitions

  bats_run_zsh "context-badge /some/path"
  local actual="$(bats_strip_ansi "$output")"

  [[ "$status" -eq 0 ]]
  [[ "$actual" == " x S" ]]
}
