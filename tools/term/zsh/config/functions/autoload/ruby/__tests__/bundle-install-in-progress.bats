bats_load_library 'helper'

setup() {
	bats_git_dir 'ruby-project'
}

@test "returns 0 when lockfile exists" {
	touch "$BATS_GIT_DIR/.git/oroshi_bundle_install_in_progress"
	bats_disable_worktree_aware

	bats_run_zsh "cd $BATS_GIT_DIR && bundle-install-in-progress"
	[[ "$status" -eq 0 ]]
}

@test "returns 1 when lockfile does not exist" {
	bats_disable_worktree_aware

	bats_run_zsh "cd $BATS_GIT_DIR && bundle-install-in-progress"
	[[ "$status" -ne 0 ]]
}
