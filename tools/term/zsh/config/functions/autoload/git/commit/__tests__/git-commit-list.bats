bats_load_library 'helper'

setup() {
	bats_git_dir 'my-repo'

	# Mock colors-load-definitions to define minimal color vars
	colors-load-definitions() {
		typeset -gA COLORS
		COLORS[git-commit]=7
		COLORS[date]=7
		COLORS[git-author]=7
		COLORS[git-message:hex]="#ffffff"
	}
	bats_mock colors-load-definitions
	bats_disable_worktree_aware
}

@test "exits 0 when displaying commit log" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-commit-list"
	[[ "$status" -eq 0 ]]
}

@test "output contains initial commit message" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-commit-list"
	[[ "$status" -eq 0 ]]
	[[ "$output" == *"init"* ]]
}
