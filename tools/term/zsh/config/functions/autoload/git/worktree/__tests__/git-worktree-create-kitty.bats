bats_load_library 'helper'

setup() {
  bats_git_dir 'myrepo'
  git-branch-slug() { echo "${1//\//_}"; }
  kitty-tab-create() { echo "TAB:$*"; }
  bats_mock git-branch-slug kitty-tab-create
  bats_disable_worktree_aware
}

@test "no argument: exits with error and opens no tab" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create-kitty"
  [[ "$status" -ne 0 ]]
  [[ "$output" != *"TAB:"* ]]
}

@test "outside a git repository: exits with error and opens no tab" {
  bats_tmp_dir
  bats_run_zsh "cd $BATS_TMP_DIR && git-worktree-create-kitty fix/bug"
  [[ "$status" -ne 0 ]]
  [[ "$output" != *"TAB:"* ]]
}

@test "valid branch: calls kitty-tab-create with Branch Slug as tab title" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create-kitty fix/bug"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "TAB:fix_bug "* ]]
}

@test "valid branch: passes --focus" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create-kitty fix/bug"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--focus"* ]]
}

@test "valid branch: command runs git-worktree-create with the branch, then exec zsh" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create-kitty fix/bug"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--cmd zsh -ic 'git-worktree-create fix/bug; exec zsh'"* ]]
}

@test "branch with special characters: stays quoted as one argument" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create-kitty 'fix/my bug'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"git-worktree-create fix/my\\ bug; exec zsh"* ]]
}

@test "valid branch: does not change the calling shell's cwd" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create-kitty fix/bug >/dev/null && pwd"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$BATS_GIT_DIR" ]]
}
