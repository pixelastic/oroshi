bats_load_library 'helper'

setup() {
	bats_git_dir 'testrepo'
	bats_git remote add origin git@github.com:pixelastic/testrepo.git
	# Set upstream as the tracking remote for main
	bats_git remote add upstream git@github.com:other/testrepo.git
	bats_git config branch.main.remote upstream
}

@test "returns remote name from cwd" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-remote-current"
	[ "$status" -eq 0 ]
	[ "$output" = "upstream" ]
}

@test "returns remote name from given path" {
	bats_run_zsh "git-remote-current $BATS_GIT_DIR"
	[ "$status" -eq 0 ]
	[ "$output" = "upstream" ]
}
