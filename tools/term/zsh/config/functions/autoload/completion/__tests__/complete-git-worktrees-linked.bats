bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  CURRENT="$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/completion/complete-git-worktrees-linked"
  bats_git_worktree 'fix/bug'
  bats_git_worktree 'feat/thing'

  export iconDirty="±"
  export iconAhead=""
  export iconBehind=""
}

teardown() {
  bats_cleanup
}

@test "does not include 'main'" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "$output" != *"main"* ]]
}

@test "includes linked worktree branch names" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"fix/bug"* ]]
  [[ "$output" == *"feat/thing"* ]]
}

@test "output is in name:description format" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == *":"* ]]
}

@test "includes dirty count in description when non-zero" {
  touch "${BATS_GIT_WORKTREES}fix-bug/untracked.txt"
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"1${iconDirty}"* ]]
}

@test "suppresses zero counts in description" {
  cd "$BATS_GIT_DIR"
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

@test "returns empty output when no worktrees exist" {
  bats_git_dir 'clean-repo'
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
