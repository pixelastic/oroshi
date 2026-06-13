bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  CURRENT="$BATS_TEST_DIRNAME/../complete-git-worktrees"
  bats_git_worktree 'fix/bug'
  export BATS_MY_REPO="$BATS_GIT_DIR"

  bats_git_dir 'other-repo'
  bats_git_worktree 'feat/x'

  export iconDirty="±"
  export iconAhead=""
  export iconBehind=""
  icons-load-definitions() {
    typeset -gA ICONS
    ICONS[git-changes]="$iconDirty"
    ICONS[git-branch-ahead]="$iconAhead"
    ICONS[git-branch-behind]="$iconBehind"
  }
  bats_mock icons-load-definitions
}

teardown() {
  bats_cleanup
}

@test "includes worktrees of the current repo" {
  cd "$BATS_MY_REPO"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"fix/bug"* ]]
}

@test "always includes 'main'" {
  cd "$BATS_MY_REPO"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"main"* ]]
}

@test "does not include worktrees from other repos" {
  cd "$BATS_MY_REPO"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "$output" != *"feat/x"* ]]
}

@test "outputs only 'main' entry when no linked worktrees exist" {
  bats_git_dir 'clean-repo'
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 1 ]
  [[ "${lines[0]}" == "main:"* ]]
}

@test "returns 'main' and succeeds outside a git repo" {
  cd "$BATS_TMP_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "main" ]
}

@test "output is in name:description format" {
  cd "$BATS_MY_REPO"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "${lines[1]}" == *":"* ]]
}

@test "includes dirty count in description when non-zero" {
  touch "${BATS_GIT_WORKTREES}fix-bug/untracked.txt"
  cd "$BATS_MY_REPO"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"1${iconDirty}"* ]]
}

@test "suppresses zero counts in description" {
  cd "$BATS_MY_REPO"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  local fixbug_line=""
  for line in "${lines[@]}"; do
    [[ "$line" == "fix/bug"* ]] && fixbug_line="$line" && break
  done
  [[ "$fixbug_line" == "fix/bug:"* ]]
  [[ "$fixbug_line" != *"${iconDirty}"* ]]
  [[ "$fixbug_line" != *"${iconAhead}"* ]]
  [[ "$fixbug_line" != *"${iconBehind}"* ]]
}

@test "outputs main with no description when outside a git repo" {
  cd "$BATS_MY_REPO"
  bats_run_zsh "$CURRENT"
  [[ "${lines[0]}" == "main:"* ]]

  cd "$BATS_TMP_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "main" ]
}
