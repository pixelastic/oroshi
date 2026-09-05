bats_load_library 'helper'

setup() {
  bats_tmp_dir

  colors-load-definitions() {
    typeset -gA COLORS
    COLORS[git-worktree]=42
    COLORS[git-worktree-foreground]=99
  }
  # Default: simple project, no worktree branch
  context-raw() { REPLY="my-project▮▮/repos/my-project"; }
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
  bats_mock colors-load-definitions context-raw projects-load-definitions icons-load-definitions
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
  context-raw() { REPLY="my-project▮fix/bug▮/worktrees/my-project--fix_bug"; }
  bats_mock context-raw

  bats_run_zsh "context-badge /some/path"
  local actual="$(bats_strip_ansi "$output")"

  [[ "$status" -eq 0 ]]
  [[ "$actual" == " x my-project S fix/bug S" ]]
}

# --- Submodule-in-worktree ---

@test "submodule-in-worktree: badge contains superproject worktree branch" {
  context-raw() { REPLY="my-project▮feat/x▮/worktrees/my-project--feat_x"; }
  bats_mock context-raw

  bats_run_zsh "context-badge /some/submodule/path"
  local actual="$(bats_strip_ansi "$output")"

  [[ "$status" -eq 0 ]]
  [[ "$actual" == " x my-project S feat/x S" ]]
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

# --- No project ---

@test "no project: empty output" {
  context-raw() { REPLY="▮▮"; }
  bats_mock context-raw

  bats_run_zsh "context-badge /tmp/random"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
