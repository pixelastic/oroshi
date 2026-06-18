bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'feature'

  bats_mock_env OROSHI_WORKTREES_DIR "$BATS_GIT_WORKTREES"

  # bats_mock_env "OROSHI_ROOT" "$OROSHI_ROOT"
  # echo "oroshi-reload-fpath \$OROSHI_ROOT" >> "$BATS_TMP_DIR/mock.zsh"
}

# 1-argument form
@test "1-arg: renames the current worktree" {
  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--feature && git-worktree-rename refactor"

  # Passed
  bats_debug "$output"
  [ "$status" -eq 0 ]

  # Directories renamed
  [ ! -d "${BATS_GIT_WORKTREES}my-repo--feature" ]
  [ -d "${BATS_GIT_WORKTREES}my-repo--refactor" ]

  # Branch renamed
  bats_run_zsh "cd $BATS_GIT_DIR && git-branch-list-raw"
  [[ "${lines[0]}" = main* ]]
  [[ "${lines[1]}" = refactor* ]]
  [[ "${lines[2]}" == "" ]]

  # Worktree clean
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-list-raw"
  bats_debug "$output"
  [[ "${lines[0]}" = refactor* ]]
  [[ "${lines[1]}" == "" ]]
}

@test "fail if only one arg and not in a worktree" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-rename refactor"
  [ "$status" -eq 1 ]
}

# 2-argument form
@test "2-arg: renames the specified worktree" {
  bats_run_zsh "cd ${BATS_GIT_DIR} && git-worktree-rename feature refactor"

  # Passed
  [ "$status" -eq 0 ]

  # Directories renamed
  [ ! -d "${BATS_GIT_WORKTREES}feature" ]
  [ -d "${BATS_GIT_WORKTREES}my-repo--refactor" ]

  # Branch renamed
  bats_run_zsh "cd $BATS_GIT_DIR && git-branch-list-raw"
  [[ "${lines[0]}" = main* ]]
  [[ "${lines[1]}" = refactor* ]]
  [[ "${lines[2]}" == "" ]]

  # Worktree clean
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-list-raw"
  bats_debug "$output"
  [[ "${lines[0]}" = refactor* ]]
  [[ "${lines[1]}" == "" ]]

  # Internal git tracking updated
  [ ! -d "$BATS_GIT_DIR/.git/worktrees/my-repo--feature" ]
  [ -d "$BATS_GIT_DIR/.git/worktrees/my-repo--refactor" ]
}

@test "renames plans directory on success" {
  mkdir -p "${BATS_GIT_WORKTREES}my-repo--feature/plans/feature"
  bats_run_zsh "cd ${BATS_GIT_DIR} && git-worktree-rename feature refactor"

  [ "$status" -eq 0 ]
  [ ! -d "${BATS_GIT_WORKTREES}my-repo--refactor/plans/feature" ]
  [ -d "${BATS_GIT_WORKTREES}my-repo--refactor/plans/refactor" ]
}

# Fail early
@test "fails if destination branch already exists" {
  bats_git branch refactor

  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-rename feature refactor"
  [ "$status" -eq 1 ]
}

@test "fails if destination directory already exists" {
  mkdir -p "${BATS_GIT_WORKTREES}my-repo--refactor"

  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-rename feature refactor"
  [ "$status" -eq 1 ]
}

@test "fails if destination plans directory already exists" {
  mkdir -p "${BATS_GIT_WORKTREES}my-repo--feature/plans/feature"
  mkdir -p "${BATS_GIT_WORKTREES}my-repo--feature/plans/refactor"

  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-rename feature refactor"
  [ "$status" -eq 1 ]
}

# Change directories

# cd side-effects
@test "navigates to new directory when called from inside the renamed worktree" {
  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--feature && git-worktree-rename refactor && echo \$PWD"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "${BATS_GIT_WORKTREES}my-repo--refactor" ]
}

@test "stays in place when called from outside the renamed worktree" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-rename feature refactor && echo \$PWD"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "$BATS_GIT_DIR" ]
}
