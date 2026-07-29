bats_load_library 'helper'

setup() {
	bats_git_dir 'my-repo'
	echo "hello" > "$BATS_GIT_DIR/tracked.txt"
	bats_git add tracked.txt
	bats_git commit --quiet -m "add tracked"
}

@test "stages all files when called with --repo /path" {
	echo "new" > "$BATS_GIT_DIR/untracked.txt"
	bats_run_zsh "git-file-add --repo $BATS_GIT_DIR"
	[[ "$status" -eq 0 ]]

	# Verify the file is staged
	local staged="$(git -C "$BATS_GIT_DIR" diff --cached --name-only)"
	[[ "$staged" == *"untracked.txt"* ]]
}
