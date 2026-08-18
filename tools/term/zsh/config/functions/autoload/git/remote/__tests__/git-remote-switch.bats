bats_load_library 'helper'

setup() {
	bats_git_dir 'testrepo'
	bats_git remote add origin git@github.com:pixelastic/testrepo.git
	bats_git remote add upstream git@github.com:other/testrepo.git
}

@test "errors if no args" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-remote-switch"
	[[ "$status" -ne 0 ]]
	[[ "$output" == *"remote name"* ]]
}

@test "errors if remote does not exist" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-remote-switch nonexistent"
	[[ "$status" -ne 0 ]]
	local stripped="$(bats_strip_ansi "$output")"
	[[ "$stripped" == *"does not exist"* ]]
}

@test "switches to remote when branch already tracks a remote" {
	# main tracks origin
	bats_git config branch.main.remote origin
	bats_run_zsh "cd $BATS_GIT_DIR && git-remote-switch upstream"
	[[ "$status" -eq 0 ]]

	run bats_git config --get branch.main.remote
	[[ "$output" == "upstream" ]]
}

@test "switches to remote when branch has no remote configured" {
	# main has no remote set — simulates a branch never pushed
	bats_git config --unset branch.main.remote 2>/dev/null || true
	bats_run_zsh "cd $BATS_GIT_DIR && git-remote-switch upstream"
	[[ "$status" -eq 0 ]]

	run bats_git config --get branch.main.remote
	[[ "$output" == "upstream" ]]
}
