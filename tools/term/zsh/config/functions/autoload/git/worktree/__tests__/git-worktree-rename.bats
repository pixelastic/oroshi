bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'feature'

  bats_mock_env OROSHI_WORKTREES_DIR "$BATS_GIT_WORKTREES"
}

# 1-argument form
@test "1-arg: renames the current worktree" {
  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--feature && git-worktree-rename refactor"

  # Passed
  bats_debug
  [[ "$status" -eq 0 ]]

  # Directories renamed
  [[ ! -d "${BATS_GIT_WORKTREES}my-repo--feature" ]]
  [[ -d "${BATS_GIT_WORKTREES}my-repo--refactor" ]]

  # Branch renamed
  bats_run_zsh "cd $BATS_GIT_DIR && git-branch-list-raw"
  [[ "${lines[0]}" = main* ]]
  [[ "${lines[1]}" = refactor* ]]
  [[ "${lines[2]}" == "" ]]

  # Worktree clean
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-list-raw"
  bats_debug
  [[ "${lines[0]}" = refactor* ]]
  [[ "${lines[1]}" == "" ]]
}

@test "fail if only one arg and not in a worktree" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-rename refactor"
  [[ "$status" -eq 1 ]]
}

# 2-argument form
@test "2-arg: renames the specified worktree" {
  bats_run_zsh "cd ${BATS_GIT_DIR} && git-worktree-rename feature refactor"

  # Passed
  [[ "$status" -eq 0 ]]

  # Directories renamed
  [[ ! -d "${BATS_GIT_WORKTREES}feature" ]]
  [[ -d "${BATS_GIT_WORKTREES}my-repo--refactor" ]]

  # Branch renamed
  bats_run_zsh "cd $BATS_GIT_DIR && git-branch-list-raw"
  [[ "${lines[0]}" = main* ]]
  [[ "${lines[1]}" = refactor* ]]
  [[ "${lines[2]}" == "" ]]

  # Worktree clean
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-list-raw"
  bats_debug
  [[ "${lines[0]}" = refactor* ]]
  [[ "${lines[1]}" == "" ]]

  # Internal git tracking updated
  [[ ! -d "$BATS_GIT_DIR/.git/worktrees/my-repo--feature" ]]
  [[ -d "$BATS_GIT_DIR/.git/worktrees/my-repo--refactor" ]]
}

# External plan directory
@test "renames external plan directory on success" {
  local planDirectory="$BATS_TMP_DIR/plans"
  mkdir -p "$planDirectory/my-repo--feature"
  plan-directory() {
    local branch=""
    while [[ $# -gt 0 ]]; do
      [[ "$1" == "--branch" ]] && branch="$2"
      shift
    done
    echo "$BATS_TMP_DIR/plans/my-repo--${branch}"
  }
  bats_mock plan-directory
  bats_disable_worktree_aware

  bats_run_zsh "cd ${BATS_GIT_DIR} && git-worktree-rename feature refactor"

  bats_debug
  [[ "$status" -eq 0 ]]
  [[ ! -d "$planDirectory/my-repo--feature" ]]
  [[ -d "$planDirectory/my-repo--refactor" ]]
}

@test "preserves plan directory content after rename" {
  local planDirectory="$BATS_TMP_DIR/plans"
  mkdir -p "$planDirectory/my-repo--feature"
  echo "test content" > "$planDirectory/my-repo--feature/state.json"
  plan-directory() {
    local branch=""
    while [[ $# -gt 0 ]]; do
      [[ "$1" == "--branch" ]] && branch="$2"
      shift
    done
    echo "$BATS_TMP_DIR/plans/my-repo--${branch}"
  }
  bats_mock plan-directory
  bats_disable_worktree_aware

  bats_run_zsh "cd ${BATS_GIT_DIR} && git-worktree-rename feature refactor"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$planDirectory/my-repo--refactor/state.json")" == "test content" ]]
}

@test "succeeds when worktree has no plan" {
  plan-directory() {
    local branch=""
    while [[ $# -gt 0 ]]; do
      [[ "$1" == "--branch" ]] && branch="$2"
      shift
    done
    echo "$BATS_TMP_DIR/plans/my-repo--${branch}"
  }
  bats_mock plan-directory
  bats_disable_worktree_aware

  bats_run_zsh "cd ${BATS_GIT_DIR} && git-worktree-rename feature refactor"

  [[ "$status" -eq 0 ]]
  [[ -d "${BATS_GIT_WORKTREES}my-repo--refactor" ]]
}

@test "fails if destination external plan directory already exists" {
  local planDirectory="$BATS_TMP_DIR/plans"
  mkdir -p "$planDirectory/my-repo--feature"
  mkdir -p "$planDirectory/my-repo--refactor"
  plan-directory() {
    local branch=""
    while [[ $# -gt 0 ]]; do
      [[ "$1" == "--branch" ]] && branch="$2"
      shift
    done
    echo "$BATS_TMP_DIR/plans/my-repo--${branch}"
  }
  bats_mock plan-directory
  bats_disable_worktree_aware

  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-rename feature refactor"
  [[ "$status" -eq 1 ]]
}

# Fail early
@test "fails if destination branch already exists" {
  bats_git branch refactor

  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-rename feature refactor"
  [[ "$status" -eq 1 ]]
}

@test "fails if destination directory already exists" {
  mkdir -p "${BATS_GIT_WORKTREES}my-repo--refactor"

  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-rename feature refactor"
  [[ "$status" -eq 1 ]]
}

# Change directories

# cd side-effects
@test "navigates to new directory when called from inside the renamed worktree" {
  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--feature && git-worktree-rename refactor && echo \$PWD"
  [[ "$status" -eq 0 ]]
  [[ "${lines[-1]}" = "${BATS_GIT_WORKTREES}my-repo--refactor" ]]
}

@test "stays in place when called from outside the renamed worktree" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-rename feature refactor && echo \$PWD"
  [[ "$status" -eq 0 ]]
  [[ "${lines[-1]}" = "$BATS_GIT_DIR" ]]
}

# OROSHI_ROOT reload
@test "updates OROSHI_ROOT when it pointed to the renamed worktree" {
  oroshi-reload-fpath() { :; }
  oroshi-reload-path() { :; }
  bats_mock oroshi-reload-fpath oroshi-reload-path

  local worktreePath="${BATS_GIT_WORKTREES}my-repo--feature"
  bats_run_zsh "export OROSHI_ROOT='$worktreePath' && cd $worktreePath && git-worktree-rename refactor && echo \$OROSHI_ROOT"
  bats_debug
  [[ "$status" -eq 0 ]]
  # newDir inherits OROSHI_WORKTREES_DIR trailing slash
  [[ "${lines[-1]}" = "${BATS_GIT_WORKTREES}/my-repo--refactor" ]]
}

@test "does not touch OROSHI_ROOT when it pointed elsewhere" {
  oroshi-reload-fpath() { :; }
  oroshi-reload-path() { :; }
  bats_mock oroshi-reload-fpath oroshi-reload-path

  local worktreePath="${BATS_GIT_WORKTREES}my-repo--feature"
  bats_run_zsh "export OROSHI_ROOT='/some/other/path' && cd $worktreePath && git-worktree-rename refactor && echo \$OROSHI_ROOT"
  bats_debug
  [[ "$status" -eq 0 ]]
  [[ "${lines[-1]}" = "/some/other/path" ]]
}

# Submodule support
@test "renames a worktree containing an initialized submodule" {
  local worktreePath="${BATS_GIT_WORKTREES}my-repo--feature"
  bats_git_submodule "$worktreePath" 'my-sub'

  bats_run_zsh "cd ${BATS_GIT_DIR} && git-worktree-rename feature refactor"

  bats_debug
  [[ "$status" -eq 0 ]]

  # Directories renamed
  [[ ! -d "${BATS_GIT_WORKTREES}my-repo--feature" ]]
  [[ -d "${BATS_GIT_WORKTREES}my-repo--refactor" ]]

  # Submodule still works in the renamed worktree
  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--refactor && git submodule status"
  bats_debug
  [[ "$status" -eq 0 ]]
}
