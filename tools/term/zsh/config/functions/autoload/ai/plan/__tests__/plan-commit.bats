bats_load_library 'helper'

# Creates a plan git repo at $BATS_TMP_DIR/plan with one commit
create_plan_repo() {
	local dir="$BATS_TMP_DIR/plan"
	git init --initial-branch=main --quiet "$dir"
	git -C "$dir" config user.email "bats@oroshi"
	git -C "$dir" config user.name "Bats"
	git -C "$dir" commit --allow-empty --quiet --message="init"
}

setup() {
	bats_tmp_dir
}

@test "commits dirty plan repo with given message" {
	create_plan_repo
	echo "dirty" > "$BATS_TMP_DIR/plan/notes.md"

	plan-directory() { echo "$BATS_TMP_DIR/plan"; }
	git-directory-is-dirty() { return 0; }
	bats_mock plan-directory git-directory-is-dirty

	bats_run_zsh "plan-commit 'my message' /some/repo"
	[[ "$status" -eq 0 ]]

	local lastMessage="$(git -C "$BATS_TMP_DIR/plan" log -1 --format=%s)"
	[[ "$lastMessage" == "my message" ]]
}

@test "does nothing when plan directory does not exist on disk" {
	plan-directory() { echo "$BATS_TMP_DIR/nonexistent"; }
	bats_mock plan-directory

	bats_run_zsh "plan-commit 'my message' /some/repo 2>&1"
	[[ "$status" -eq 0 ]]
	[[ "$output" == "" ]]
}

@test "does nothing when plan-directory fails" {
	plan-directory() { return 1; }
	bats_mock plan-directory

	bats_run_zsh "plan-commit 'my message' /some/repo"
	[[ "$status" -eq 0 ]]
}

@test "does nothing when plan repo is clean" {
	create_plan_repo

	plan-directory() { echo "$BATS_TMP_DIR/plan"; }
	git-directory-is-dirty() { return 1; }
	bats_mock plan-directory git-directory-is-dirty

	bats_run_zsh "plan-commit 'my message' /some/repo"
	[[ "$status" -eq 0 ]]

	# Still only the init commit
	local commitCount="$(git -C "$BATS_TMP_DIR/plan" rev-list --count HEAD)"
	[[ "$commitCount" -eq 1 ]]
}

@test "forwards remaining args to plan-directory" {
	plan-directory() {
		echo "$@" > "$BATS_TMP_DIR/plan-dir-args"
		return 1
	}
	bats_mock plan-directory

	bats_run_zsh "plan-commit 'msg' /some/path --project myapp"

	[[ "$(cat "$BATS_TMP_DIR/plan-dir-args")" == "/some/path --project myapp" ]]
}
