bats_load_library 'helper'

# We mock the icons, so tests don't break when we decide to change the icons.
# But we don't mock -raw, as we want those tests to fail if we ever change the
# output format of -raw.

setup() {
  bats_git_dir 'main-repo'
  bats_git_worktree 'docs'
  bats_git_worktree 'feature'

  icons-load-definitions() {
    typeset -gA ICONS
    ICONS[git-changes]="±"
    ICONS[git-branch-ahead]="↑"
    ICONS[git-branch-behind]="↓"
    ICONS[git-worktree-current]=">"
  }
  bats_mock icons-load-definitions
}

@test "returns empty output when no worktrees exist" {
  bats_git_dir 'empty-repo'

  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-list"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "smoke: shows branch names, relative date and commit message" {
  git -C "${BATS_GIT_WORKTREES}main-repo--docs" commit --allow-empty -m "docs commit"
  git -C "${BATS_GIT_WORKTREES}main-repo--feature" commit --allow-empty -m "feature commit"

  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-list"
  [ "$status" -eq 0 ]
  local line0="$(bats_strip_ansi "${lines[0]}")"
  local line1="$(bats_strip_ansi "${lines[1]}")"
  [[ "$line0" == *"docs"*"docs commit"* ]]
  [[ "$line1" == *"feature"*"feature commit"* ]]
}

@test "marks only the current worktree with pointer" {
  bats_run_zsh "cd ${BATS_GIT_WORKTREES}main-repo--feature && git-worktree-list"

  [ "$status" -eq 0 ]
  local line0="$(bats_strip_ansi "${lines[0]}")"
  local line1="$(bats_strip_ansi "${lines[1]}")"
  [[ "$line0" != *">"* ]]
  [[ "$line1" == *">"*"feature"* ]]
}

@test "shows dirty, ahead and behind indicators; hides them when absent" {
  # advance main so feature can be behind
  git -C "$BATS_GIT_DIR" commit --allow-empty -m "main advances"
  # feature: 1 dirty file + 1 ahead + 1 behind
  echo "dirty" > "${BATS_GIT_WORKTREES}main-repo--feature/dirty.txt"
  git -C "${BATS_GIT_WORKTREES}main-repo--feature" commit --allow-empty -m "feat: ahead"

  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-list"
  [ "$status" -eq 0 ]
  local line0="$(bats_strip_ansi "${lines[0]}")"
  local line1="$(bats_strip_ansi "${lines[1]}")"
  [[ "$line0" == *"docs"*"1↓"* ]]
  [[ "$line1" == *"feature"*"±1"*"1↑"*"1↓"* ]]
}
