bats_load_library 'helper'

# Main repo with a submodule at ./private
# Submodule's latest commit: "fix: resolve edge case"
# Submodule pointer is dirty (newer than main's committed pointer)
setup() {
	bats_tmp_dir
	export GIT_AUTHOR_NAME="Test"
	export GIT_AUTHOR_EMAIL="test@test.com"
	export GIT_COMMITTER_NAME="Test"
	export GIT_COMMITTER_EMAIL="test@test.com"

	git init "$BATS_TMP_DIR/sub-source" --initial-branch main
	git -C "$BATS_TMP_DIR/sub-source" commit --allow-empty --message "initial"

	git init "$BATS_TMP_DIR/main" --initial-branch main
	git -C "$BATS_TMP_DIR/main" commit --allow-empty --message "initial"
	git -c protocol.file.allow=always -C "$BATS_TMP_DIR/main" submodule add "$BATS_TMP_DIR/sub-source" ./private
	git -C "$BATS_TMP_DIR/main" commit --message "add submodule"

	# Advance submodule to create dirty pointer
	git -C "$BATS_TMP_DIR/main/private" commit --allow-empty --message "fix: resolve edge case"

	git-directory-root() { echo "$BATS_TMP_DIR/main"; }
	bats_mock git-directory-root
	bats_disable_worktree_aware
}

@test "commit subject matches chore(<name>): Update <path> submodule" {
	bats_run_zsh "git-commit-submodule ./private"
	[[ "$status" -eq 0 ]]

	local subject="$(git -C "$BATS_TMP_DIR/main" log -1 --format=%s)"
	[[ "$subject" == "chore(private): Update ./private submodule" ]]
}

@test "commit body contains the subject of the submodule's latest commit" {
	bats_run_zsh "git-commit-submodule ./private"
	[[ "$status" -eq 0 ]]

	local body="$(git -C "$BATS_TMP_DIR/main" log -1 --format=%b)"
	[[ "$body" == *"fix: resolve edge case"* ]]
}

@test "works with nested submodule paths" {
	git init "$BATS_TMP_DIR/nested-source" --initial-branch main
	git -C "$BATS_TMP_DIR/nested-source" commit --allow-empty --message "feat: nested feature"
	git -c protocol.file.allow=always -C "$BATS_TMP_DIR/main" submodule add "$BATS_TMP_DIR/nested-source" ./scripts/bin/img
	git -C "$BATS_TMP_DIR/main" commit --message "add nested submodule"
	git -C "$BATS_TMP_DIR/main/scripts/bin/img" commit --allow-empty --message "chore: update deps"

	bats_run_zsh "git-commit-submodule ./scripts/bin/img"
	[[ "$status" -eq 0 ]]

	local subject="$(git -C "$BATS_TMP_DIR/main" log -1 --format=%s)"
	[[ "$subject" == "chore(img): Update ./scripts/bin/img submodule" ]]

	local body="$(git -C "$BATS_TMP_DIR/main" log -1 --format=%b)"
	[[ "$body" == *"chore: update deps"* ]]
}

@test "accepts absolute path and derives git root from it" {
	bats_run_zsh "git-commit-submodule $BATS_TMP_DIR/main/private"
	[[ "$status" -eq 0 ]]

	local subject="$(git -C "$BATS_TMP_DIR/main" log -1 --format=%s)"
	[[ "$subject" == "chore(private): Update private submodule" ]]

	local body="$(git -C "$BATS_TMP_DIR/main" log -1 --format=%b)"
	[[ "$body" == *"fix: resolve edge case"* ]]
}

@test "accepts absolute path with nested submodule" {
	git init "$BATS_TMP_DIR/nested-source2" --initial-branch main
	git -C "$BATS_TMP_DIR/nested-source2" commit --allow-empty --message "feat: deep feature"
	git -c protocol.file.allow=always -C "$BATS_TMP_DIR/main" submodule add "$BATS_TMP_DIR/nested-source2" ./scripts/bin/img
	git -C "$BATS_TMP_DIR/main" commit --message "add nested submodule"
	git -C "$BATS_TMP_DIR/main/scripts/bin/img" commit --allow-empty --message "chore: nested update"

	bats_run_zsh "git-commit-submodule $BATS_TMP_DIR/main/scripts/bin/img"
	[[ "$status" -eq 0 ]]

	local subject="$(git -C "$BATS_TMP_DIR/main" log -1 --format=%s)"
	[[ "$subject" == "chore(img): Update scripts/bin/img submodule" ]]
}

@test "still works when submodule log returns empty" {
	git() {
		if [[ "$1" == "-C" && "$3" == "log" ]]; then
			return 0
		fi
		command git "$@"
	}
	bats_mock git

	bats_run_zsh "git-commit-submodule ./private"
	[[ "$status" -eq 0 ]]

	local body="$(command git -C "$BATS_TMP_DIR/main" log -1 --format=%b)"
	[[ -z "${body// }" ]]
}
