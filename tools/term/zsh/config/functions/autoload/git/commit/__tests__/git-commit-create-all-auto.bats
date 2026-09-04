bats_load_library 'helper'

setup() {
	bats_tmp_dir
}

@test "captures git-commit-message output and passes it as commit message to git-commit-create" {
	git-file-add() { :; }
	git-commit-message() { echo "feat(scope): auto message"; }
	git-commit-create() { echo "$@" > "$BATS_TMP_DIR/create-args.txt"; }
	bats_mock git-file-add git-commit-message git-commit-create

	bats_run_zsh "git-commit-create-all-auto"
	[[ "$status" -eq 0 ]]

	local createArgs="$(cat "$BATS_TMP_DIR/create-args.txt")"
	[[ "$createArgs" == "feat(scope): auto message" ]]
}

@test "echoes the generated message to stdout" {
	git-file-add() { :; }
	git-commit-message() { echo "feat(scope): auto message"; }
	git-commit-create() { :; }
	bats_mock git-file-add git-commit-message git-commit-create

	bats_run_zsh "git-commit-create-all-auto"
	[[ "$output" == *"feat(scope): auto message"* ]]
}

@test "forwards extra flags to git-commit-create" {
	git-file-add() { :; }
	git-commit-message() { echo "chore: cleanup"; }
	git-commit-create() { echo "$@" > "$BATS_TMP_DIR/create-args.txt"; }
	bats_mock git-file-add git-commit-message git-commit-create

	bats_run_zsh "git-commit-create-all-auto -n"
	[[ "$status" -eq 0 ]]

	local createArgs="$(cat "$BATS_TMP_DIR/create-args.txt")"
	[[ "$createArgs" == "chore: cleanup -n" ]]
}

@test "passes repo path to git-commit-message as positional arg" {
	git-file-add() { :; }
	git-commit-message() {
		echo "$@" > "$BATS_TMP_DIR/message-args.txt"
		echo "fix: something"
	}
	git-commit-create() { :; }
	bats_mock git-file-add git-commit-message git-commit-create

	bats_run_zsh "git-commit-create-all-auto /tmp/my-repo"
	[[ "$status" -eq 0 ]]

	local messageArgs="$(cat "$BATS_TMP_DIR/message-args.txt")"
	[[ "$messageArgs" == "/tmp/my-repo" ]]
}

@test "converts repo path to --repo flag for git-commit-create" {
	git-file-add() { :; }
	git-commit-message() { echo "fix: something"; }
	git-commit-create() { echo "$@" > "$BATS_TMP_DIR/create-args.txt"; }
	bats_mock git-file-add git-commit-message git-commit-create

	bats_run_zsh "git-commit-create-all-auto /tmp/my-repo"
	[[ "$status" -eq 0 ]]

	local createArgs="$(cat "$BATS_TMP_DIR/create-args.txt")"
	[[ "$createArgs" == "--repo /tmp/my-repo fix: something" ]]
}

@test "stages files before generating the message" {
	git-file-add() { echo "staged" > "$BATS_TMP_DIR/add-called.txt"; }
	git-commit-message() {
		# Verify staging happened before message generation
		[[ -f "$BATS_TMP_DIR/add-called.txt" ]] || return 1
		echo "feat: after staging"
	}
	git-commit-create() { :; }
	bats_mock git-file-add git-commit-message git-commit-create

	bats_run_zsh "git-commit-create-all-auto"
	[[ "$status" -eq 0 ]]
}

@test "passes --repo to git-file-add" {
	git-file-add() { echo "$@" > "$BATS_TMP_DIR/add-args.txt"; }
	git-commit-message() { echo "fix: something"; }
	git-commit-create() { :; }
	bats_mock git-file-add git-commit-message git-commit-create

	bats_run_zsh "git-commit-create-all-auto /tmp/my-repo"
	[[ "$status" -eq 0 ]]

	local addArgs="$(cat "$BATS_TMP_DIR/add-args.txt")"
	[[ "$addArgs" == "--repo /tmp/my-repo" ]]
}

@test "calls git-submodule-commit-all-auto when repo has submodules" {
	git-directory-has-submodules() { return 0; }
	git-submodule-commit-all-auto() { echo "$@" > "$BATS_TMP_DIR/submodule-args.txt"; }
	git-directory-dirty-count() { echo "3"; }
	git-file-add() { :; }
	git-commit-message() { echo "feat: parent changes"; }
	git-commit-create() { :; }
	bats_mock git-directory-has-submodules git-submodule-commit-all-auto git-directory-dirty-count git-file-add git-commit-message git-commit-create

	bats_run_zsh "git-commit-create-all-auto"
	[[ "$status" -eq 0 ]]
	[[ -f "$BATS_TMP_DIR/submodule-args.txt" ]]
}

@test "skips submodule step when repo has no submodules" {
	git-directory-has-submodules() { return 1; }
	git-submodule-commit-all-auto() { echo "called" > "$BATS_TMP_DIR/submodule-called.txt"; }
	git-file-add() { :; }
	git-commit-message() { echo "feat: changes"; }
	git-commit-create() { :; }
	bats_mock git-directory-has-submodules git-submodule-commit-all-auto git-file-add git-commit-message git-commit-create

	bats_run_zsh "git-commit-create-all-auto"
	[[ "$status" -eq 0 ]]
	[[ ! -f "$BATS_TMP_DIR/submodule-called.txt" ]]
}

@test "returns 0 when submodule commits leave no remaining changes" {
	git-directory-has-submodules() { return 0; }
	git-submodule-commit-all-auto() { :; }
	git-directory-dirty-count() { echo "0"; }
	git-file-add() { echo "called" > "$BATS_TMP_DIR/add-called.txt"; }
	git-commit-message() { echo "should not run"; }
	git-commit-create() { echo "called" > "$BATS_TMP_DIR/create-called.txt"; }
	bats_mock git-directory-has-submodules git-submodule-commit-all-auto git-directory-dirty-count git-file-add git-commit-message git-commit-create

	bats_run_zsh "git-commit-create-all-auto"
	[[ "$status" -eq 0 ]]
	[[ ! -f "$BATS_TMP_DIR/add-called.txt" ]]
	[[ ! -f "$BATS_TMP_DIR/create-called.txt" ]]
}

@test "threads --repo to git-submodule-commit-all-auto" {
	git-directory-has-submodules() { return 0; }
	git-submodule-commit-all-auto() { echo "$@" > "$BATS_TMP_DIR/submodule-args.txt"; }
	git-directory-dirty-count() { echo "2"; }
	git-file-add() { :; }
	git-commit-message() { echo "fix: something"; }
	git-commit-create() { :; }
	bats_mock git-directory-has-submodules git-submodule-commit-all-auto git-directory-dirty-count git-file-add git-commit-message git-commit-create

	bats_run_zsh "git-commit-create-all-auto /tmp/my-repo"
	[[ "$status" -eq 0 ]]

	local submoduleArgs="$(cat "$BATS_TMP_DIR/submodule-args.txt")"
	[[ "$submoduleArgs" == "--repo /tmp/my-repo" ]]
}

@test "threads --repo to git-directory-has-submodules" {
	git-directory-has-submodules() {
		echo "$@" > "$BATS_TMP_DIR/has-submodules-args.txt"
		return 0
	}
	git-submodule-commit-all-auto() { :; }
	git-directory-dirty-count() { echo "1"; }
	git-file-add() { :; }
	git-commit-message() { echo "fix: something"; }
	git-commit-create() { :; }
	bats_mock git-directory-has-submodules git-submodule-commit-all-auto git-directory-dirty-count git-file-add git-commit-message git-commit-create

	bats_run_zsh "git-commit-create-all-auto /tmp/my-repo"
	[[ "$status" -eq 0 ]]

	local hasSubmodulesArgs="$(cat "$BATS_TMP_DIR/has-submodules-args.txt")"
	[[ "$hasSubmodulesArgs" == "--repo /tmp/my-repo" ]]
}

@test "aborts without committing when git-commit-message fails" {
	git-file-add() { :; }
	git-commit-message() { return 1; }
	git-commit-create() {
		echo "should not run" > "$BATS_TMP_DIR/create-called.txt"
	}
	bats_mock git-file-add git-commit-message git-commit-create

	bats_run_zsh "git-commit-create-all-auto"
	[[ "$status" -ne 0 ]]
	[[ ! -f "$BATS_TMP_DIR/create-called.txt" ]]
}
