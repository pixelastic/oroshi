bats_load_library 'helper'

setup() {
  bats_git_dir 'repo'
  bats_git commit --allow-empty --quiet --message="feat: initial work"
}

@test "returns subject of current branch from cwd" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-branch-last-subject"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "feat: initial work" ]]
}

@test "returns subject of named branch" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-branch-last-subject main"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "feat: initial work" ]]
}

@test "returns subject from --repo path" {
  bats_run_zsh "git-branch-last-subject --repo $BATS_GIT_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "feat: initial work" ]]
}

@test "returns subject of named branch with --repo path" {
  bats_run_zsh "git-branch-last-subject main --repo $BATS_GIT_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "feat: initial work" ]]
}

@test "returns the latest commit, not older ones" {
  bats_git commit --allow-empty --quiet --message="fix: newer commit"
  bats_run_zsh "cd $BATS_GIT_DIR && git-branch-last-subject"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "fix: newer commit" ]]
}

@test "fails outside a git repo" {
  bats_run_zsh "cd $BATS_TMP_DIR && git-branch-last-subject"
  [[ "$status" -ne 0 ]]
}
