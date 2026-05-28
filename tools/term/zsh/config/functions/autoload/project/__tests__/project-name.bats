bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
  mkdir -p "$BATS_GIT_DIR/src"
  touch "$BATS_GIT_DIR/src/main.zsh"
  mkdir -p "${BATS_GIT_WORKTREES}fix-bug/src"
  touch "${BATS_GIT_WORKTREES}fix-bug/src/main.zsh"

  projects-load-definitions() {
    typeset -gA PROJECTS_V2
    PROJECTS_V2[my-project:path]="$BATS_GIT_DIR/"
  }
  bats_mock projects-load-definitions
}

teardown() {
  bats_cleanup
}

# --- Without argument (uses $PWD) ---

@test "no arg: at root of known project" {
  cd "$BATS_GIT_DIR"
  bats_run_function project-name
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}

@test "no arg: in subdirectory of known project" {
  cd "$BATS_GIT_DIR/src"
  bats_run_function project-name
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}

@test "no arg: in unknown project" {
  cd "$BATS_TMP_DIR"
  bats_run_function project-name
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "no arg: at root of worktree of known project" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  bats_run_function project-name
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}

@test "no arg: in subdirectory of worktree of known project" {
  cd "${BATS_GIT_WORKTREES}fix-bug/src"
  bats_run_function project-name
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}

# --- With argument ---

@test "with arg: root of known project" {
  bats_run_function project-name "$BATS_GIT_DIR"
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}

@test "with arg: subdirectory of known project" {
  bats_run_function project-name "$BATS_GIT_DIR/src"
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}

@test "with arg: file in subdirectory of known project" {
  bats_run_function project-name "$BATS_GIT_DIR/src/main.zsh"
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}

@test "with arg: root of worktree of known project" {
  bats_run_function project-name "${BATS_GIT_WORKTREES}fix-bug"
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}

@test "with arg: subdirectory of worktree of known project" {
  bats_run_function project-name "${BATS_GIT_WORKTREES}fix-bug/src"
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}

@test "with arg: unknown path" {
  bats_run_function project-name "$BATS_TMP_DIR"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

# --- Specificity ---

@test "nested projects: direct path returns the most specific project" {
  projects-load-definitions() {
    typeset -gA PROJECTS_V2
    PROJECTS_V2[catch-all:path]="$BATS_TMP_DIR/"
    PROJECTS_V2[my-project:path]="$BATS_GIT_DIR/"
  }
  bats_mock projects-load-definitions
  bats_run_function project-name "$BATS_GIT_DIR/src"
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}

@test "nested projects: worktree path returns the most specific project" {
  projects-load-definitions() {
    typeset -gA PROJECTS_V2
    PROJECTS_V2[catch-all:path]="$BATS_TMP_DIR/"
    PROJECTS_V2[my-project:path]="$BATS_GIT_DIR/"
  }
  bats_mock projects-load-definitions
  bats_run_function project-name "${BATS_GIT_WORKTREES}fix-bug"
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}
