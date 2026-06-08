bats_load_library 'helper'

setup() {
  bats_git_dir 'repo'
  CURRENT="$OROSHI_ZSH_AUTOLOAD/git/branch/git-branch-rename"
}

teardown() {
  bats_cleanup
}

# --- no arguments ---

@test "no args: fails with non-zero exit code" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -ne 0 ]
}

# --- 1-argument form ---

@test "1 arg: renames current branch to given name" {
  cd "$BATS_GIT_DIR"
  git checkout -b feat/hello
  bats_run_zsh "$CURRENT" "feat/renamed"
  [ "$status" -eq 0 ]
  local branch
  branch="$(git -C "$BATS_GIT_DIR" branch --show-current)"
  [ "$branch" = "feat/renamed" ]
}

# --- 2-argument form ---

@test "2 args: renames named branch to new name" {
  cd "$BATS_GIT_DIR"
  git checkout -b feat/old
  git checkout main
  bats_run_zsh "$CURRENT" "feat/old" "feat/new"
  [ "$status" -eq 0 ]
  git -C "$BATS_GIT_DIR" show-ref --verify --quiet refs/heads/feat/new
  local oldExists
  git -C "$BATS_GIT_DIR" show-ref --verify --quiet refs/heads/feat/old && oldExists=1 || oldExists=0
  [ "$oldExists" -eq 0 ]
}
