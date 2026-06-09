bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  CURRENT="$OROSHI_ZSH_AUTOLOAD/git/worktree/git-worktree-list"
  bats_git_worktree 'fix/bug'
  bats_git_worktree 'feat/dark-mode'

  export BATS_CURRENT=">"

  icons-load-definitions() {
    typeset -gA ICONS
    # shellcheck disable=SC2034
    ICONS[git-changes]="±"
    # shellcheck disable=SC2034
    ICONS[git-branch-ahead]="↑"
    # shellcheck disable=SC2034
    ICONS[git-branch-behind]="↓"
    # shellcheck disable=SC2034
    ICONS[current]="$BATS_CURRENT"
  }
  bats_mock icons-load-definitions
}

teardown() {
  bats_cleanup
}

@test "output contains branch names" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"fix/bug"* ]]
  [[ "$output" == *"feat/dark-mode"* ]]
}

@test "output does not contain file paths" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [[ "$output" != *"$OROSHI_WORKTREES_DIR"* ]]
}

@test "returns empty output when no worktrees exist" {
  bats_git_dir 'clean-repo'
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "marks current worktree with pointer" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"${BATS_CURRENT}"* ]]
}

@test "shows ahead count vs main" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  git commit --allow-empty -m "commit one"
  git commit --allow-empty -m "commit two"
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"2"* ]]
}

@test "shows behind count vs main" {
  cd "$BATS_GIT_DIR"
  git commit --allow-empty -m "main commit 1"
  git commit --allow-empty -m "main commit 2"
  git commit --allow-empty -m "main commit 3"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" == *"3"* ]]
}

@test "shows relative date of last commit" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  git commit --allow-empty -m "dated commit"
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"seconds"* ]]
}

@test "shows last commit message" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  git commit --allow-empty -m "my test commit"
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"my test commit"* ]]
}

@test "COLOR_ALIAS_GIT_WORKTREE_DIRTY is defined with value 21" {
  local script="$BATS_TMP_DIR/color-test.zsh"
  printf 'source "%s/tools/term/zsh/config/theming/env/colors.zsh"\necho "$COLOR_ALIAS_GIT_WORKTREE_DIRTY"\n' "$OROSHI_ROOT" >"$script"
  bats_run_zsh "$script"
  [ "$status" -eq 0 ]
  [ "$output" = "21" ]
}

@test "shows dirty count with ± when worktree has uncommitted files" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  echo "dirty" > newfile.txt
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" == *"±"* ]]
}

@test "does not show ± when worktree is clean" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" != *"±"* ]]
}
