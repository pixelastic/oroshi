bats_load_library 'helper'

setup() {
	bats_git_dir 'testrepo'
	bats_git config user.email "test@example.com"
}

@test "errors if no args" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-config-exists"
	[[ "$status" -ne 0 ]]
}

@test "returns 0 when config key exists" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-config-exists user.email"
	[[ "$status" -eq 0 ]]
}

@test "returns 1 when config key does not exist" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-config-exists user.nonexistent"
	[[ "$status" -ne 0 ]]
}

@test "produces no output" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-config-exists user.email"
	[[ "$output" == "" ]]
}
