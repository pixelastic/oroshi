bats_load_library 'helper'

setup() {
	bats_tmp_dir
}

@test "echoes node output on success" {
	node() { echo "feat(scope): auto message"; }
	bats_mock node

	bats_run_zsh "git-commit-message"
	[[ "$status" -eq 0 ]]
	[[ "$output" == "feat(scope): auto message" ]]
}

@test "exits non-zero when node produces empty output" {
	node() { :; }
	bats_mock node

	bats_run_zsh "git-commit-message"
	[[ "$status" -ne 0 ]]
}

@test "exits non-zero when node fails with no stdout" {
	node() { return 1; }
	bats_mock node

	bats_run_zsh "git-commit-message"
	[[ "$status" -ne 0 ]]
	[[ "$output" == "" ]]
}
