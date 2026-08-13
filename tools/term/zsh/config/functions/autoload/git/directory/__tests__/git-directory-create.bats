bats_load_library 'helper'

setup() {
	bats_tmp_dir

	# Mock external commands
	git-github-repo-exists() { return 1; }
	git-commit-create-all() {
		git -C "$PWD" add --all
		git -C "$PWD" commit --quiet --message "$1"
	}
	git-remote-create() { git -C "$PWD" remote add "$1" "$2"; }
	git-branch-push() { :; }
	gh() { :; }
	bats_mock git-github-repo-exists git-commit-create-all git-remote-create git-branch-push gh
}

@test "fails when no repo name given" {
	bats_run_zsh "cd $BATS_TMP_DIR && git-directory-create"
	[[ "$status" -ne 0 ]]
	[[ "$output" == *"must pass the name"* ]]
}

@test "fails when directory already exists" {
	mkdir -p "$BATS_TMP_DIR/my-repo"

	bats_run_zsh "cd $BATS_TMP_DIR && git-directory-create my-repo"
	[[ "$status" -ne 0 ]]
	[[ "$output" == *"already exists"* ]]
}

@test "creates local git repo with -n flag" {
	bats_run_zsh "cd $BATS_TMP_DIR && git-directory-create -n my-repo"
	[[ "$status" -eq 0 ]]
	[[ -d "$BATS_TMP_DIR/my-repo/.git" ]]
	[[ -f "$BATS_TMP_DIR/my-repo/.gitignore" ]]
	[[ -f "$BATS_TMP_DIR/my-repo/README.md" ]]
}

@test "README contains repo name" {
	bats_run_zsh "cd $BATS_TMP_DIR && git-directory-create -n my-repo"
	[[ "$(cat "$BATS_TMP_DIR/my-repo/README.md")" == "# my-repo" ]]
}
