bats_load_library 'helper'

setup() {
	bats_git_dir 'my-repo'
	echo "hello" > "$BATS_GIT_DIR/tracked.txt"
	bats_git add tracked.txt
	bats_git commit --quiet -m "add tracked"
}

@test "returns 0 when called with path to a dirty repo" {
	echo "change" >> "$BATS_GIT_DIR/tracked.txt"
	bats_run_zsh "git-directory-is-dirty $BATS_GIT_DIR"
	[[ "$status" -eq 0 ]]
}

@test "returns 1 when called with path to a clean repo" {
	bats_run_zsh "git-directory-is-dirty $BATS_GIT_DIR"
	[[ "$status" -eq 1 ]]
}
