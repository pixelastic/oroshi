bats_load_library 'helper'

setup() {
	bats_git_dir 'testrepo'
	bats_git remote add origin git@github.com:pixelastic/testrepo.git
}

@test "errors if no args" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-remote-rename"
	[[ "$status" -ne 0 ]]
	[[ "$output" == *"two arguments"* ]]
}

@test "errors if only one arg" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-remote-rename origin"
	[[ "$status" -ne 0 ]]
	[[ "$output" == *"two arguments"* ]]
}

@test "errors if source remote does not exist" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-remote-rename nonexistent newname"
	[[ "$status" -ne 0 ]]
	local stripped="$(bats_strip_ansi "$output")"
	[[ "$stripped" == *"nonexistent"* ]]
	[[ "$stripped" == *"does not exist"* ]]
}

@test "errors if destination remote already exists" {
	bats_git remote add upstream git@github.com:other/testrepo.git
	bats_run_zsh "cd $BATS_GIT_DIR && git-remote-rename origin upstream"
	[[ "$status" -ne 0 ]]
	local stripped="$(bats_strip_ansi "$output")"
	[[ "$stripped" == *"upstream"* ]]
	[[ "$stripped" == *"Remote"*"already exists"* ]]
}

@test "renames remote and prints confirmation" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-remote-rename origin upstream"
	[[ "$status" -eq 0 ]]
	local stripped="$(bats_strip_ansi "$output")"
	[[ "$stripped" == *"renamed"* ]]

	# Verify the remote was actually renamed (use local config to avoid global config noise)
	run bats_git config --local --get remote.upstream.url
	[[ "$output" == "git@github.com:pixelastic/testrepo.git" ]]
	run bats_git config --local --get remote.origin.url
	[[ "$status" -ne 0 ]]
}
