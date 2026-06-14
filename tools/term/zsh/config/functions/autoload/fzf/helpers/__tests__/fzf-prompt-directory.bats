bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'feature'
}

teardown() {
  bats_cleanup
}

@test "prompt badge contains context badge and path" {
  context-badge() { echo "my-repo/feature > "; }
  context-path() { echo "my-repo/src"; }
  simplify-path() { echo "simplify:$1"; }
  colorize() { echo "colorize:$1"; }
  bats_mock context-badge context-path simplify-path colorize

  bats_run_zsh "fzf-prompt-directory ${BATS_GIT_WORKTREES}my-repo--feature-my-feature"
  bats_debug
  [[ "$status" -eq 0 ]]
  [[ "$output" == "my-repo/feature > colorize: simplify:my-repo/src" ]]
}
