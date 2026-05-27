bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
  mkdir -p "$BATS_GIT_DIR/src"
  touch "$BATS_GIT_DIR/src/main.zsh"
  mkdir -p "${BATS_GIT_WORKTREES}fix-bug/src"
  touch "${BATS_GIT_WORKTREES}fix-bug/src/main.zsh"
  PROJ="typeset -gA PROJECTS; PROJECTS[my-project.path]=${BATS_GIT_DIR}/"
}

teardown() {
  bats_cleanup
}

# --- Without argument (uses $PWD) ---

@test "no arg: at root of known project" {
  run zsh -c "${PROJ}; cd ${BATS_GIT_DIR} && context-project"
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}

@test "no arg: in subdirectory of known project" {
  run zsh -c "${PROJ}; cd ${BATS_GIT_DIR}/src && context-project"
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}

@test "no arg: in unknown project" {
  run zsh -c "${PROJ}; cd ${BATS_TMP_DIR} && context-project"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "no arg: at root of worktree of known project" {
  run zsh -c "${PROJ}; cd ${BATS_GIT_WORKTREES}fix-bug && context-project"
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}

@test "no arg: in subdirectory of worktree of known project" {
  run zsh -c "${PROJ}; cd ${BATS_GIT_WORKTREES}fix-bug/src && context-project"
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}

# --- With argument ---

@test "with arg: root of known project" {
  run zsh -c "${PROJ}; context-project ${BATS_GIT_DIR}"
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}

@test "with arg: subdirectory of known project" {
  run zsh -c "${PROJ}; context-project ${BATS_GIT_DIR}/src"
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}

@test "with arg: file in subdirectory of known project" {
  run zsh -c "${PROJ}; context-project ${BATS_GIT_DIR}/src/main.zsh"
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}

@test "with arg: root of worktree of known project" {
  run zsh -c "${PROJ}; context-project ${BATS_GIT_WORKTREES}fix-bug"
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}

@test "with arg: subdirectory of worktree of known project" {
  run zsh -c "${PROJ}; context-project ${BATS_GIT_WORKTREES}fix-bug/src"
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}

@test "with arg: unknown path" {
  run zsh -c "${PROJ}; context-project ${BATS_TMP_DIR}"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

# --- Specificity ---

@test "nested projects: direct path returns the most specific project" {
  run zsh -c "typeset -gA PROJECTS; PROJECTS[catch-all.path]=${BATS_TMP_DIR}/; PROJECTS[my-project.path]=${BATS_GIT_DIR}/; context-project ${BATS_GIT_DIR}/src"
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}

@test "nested projects: worktree path returns the most specific project" {
  run zsh -c "typeset -gA PROJECTS; PROJECTS[catch-all.path]=${BATS_TMP_DIR}/; PROJECTS[my-project.path]=${BATS_GIT_DIR}/; context-project ${BATS_GIT_WORKTREES}fix-bug"
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}
