bats_load_library 'helper'

setup() {
	# Create a repo with two commits
	bats_git_dir 'my-repo'
	echo "first" > "$BATS_GIT_DIR/a.txt"
	bats_git add a.txt
	bats_git commit --quiet --message "commit A"
	export SHA_A="$(git -C "$BATS_GIT_DIR" rev-parse HEAD)"
	echo "second" > "$BATS_GIT_DIR/b.txt"
	bats_git add b.txt
	bats_git commit --quiet --message "commit B"
	export SHA_B="$(git -C "$BATS_GIT_DIR" rev-parse HEAD)"
}

@test "returns 0 when first commit is before second" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-commit-is-before $SHA_A $SHA_B"
	[[ "$status" -eq 0 ]]
}

@test "returns 1 when first commit is after second" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-commit-is-before $SHA_B $SHA_A"
	[[ "$status" -eq 1 ]]
}

@test "returns 1 when both commits are the same" {
	bats_run_zsh "cd $BATS_GIT_DIR && git-commit-is-before $SHA_A $SHA_A"
	[[ "$status" -eq 1 ]]
}
