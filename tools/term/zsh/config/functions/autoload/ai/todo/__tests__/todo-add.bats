bats_load_library 'helper'

setup() {
	bats_tmp_dir

	# Mock topydo to capture the exact command it receives
	topydo() {
		echo "$*" > "$BATS_TMP_DIR/topydo-args.txt"
		echo "added: $*"
	}
	bats_mock topydo
}

# Basic add

@test "adds item with correct project tag, size tag, and id tag" {
	bats_run_zsh "todo-add --domain Git --size small --slug git-prune 'Prune remote refs'"
	[[ "$status" -eq 0 ]]

	local args="$(cat "$BATS_TMP_DIR/topydo-args.txt")"
	[[ "$args" == *"+Git"* ]]
	[[ "$args" == *"size:small"* ]]
	[[ "$args" == *"id:git-prune"* ]]
}

@test "delegates to topydo add" {
	bats_run_zsh "todo-add --domain Git --size small --slug git-prune 'Prune remote refs'"
	[[ "$status" -eq 0 ]]

	local args="$(cat "$BATS_TMP_DIR/topydo-args.txt")"
	[[ "$args" == "add "* ]]
}

@test "includes description text in topydo command" {
	bats_run_zsh "todo-add --domain Git --size small --slug git-prune 'Prune remote refs'"
	[[ "$status" -eq 0 ]]

	local args="$(cat "$BATS_TMP_DIR/topydo-args.txt")"
	[[ "$args" == *"Prune remote refs"* ]]
}

# Blocked-by

@test "adds p: tags for each blocked-by slug" {
	bats_run_zsh "todo-add --domain Git --size small --slug git-prune --blocked-by git-cleanup 'Prune refs'"
	[[ "$status" -eq 0 ]]

	local args="$(cat "$BATS_TMP_DIR/topydo-args.txt")"
	[[ "$args" == *"p:git-cleanup"* ]]
}

@test "supports multiple comma-separated blockers" {
	bats_run_zsh "todo-add --domain Git --size small --slug git-prune --blocked-by git-cleanup,git-fetch 'Prune refs'"
	[[ "$status" -eq 0 ]]

	local args="$(cat "$BATS_TMP_DIR/topydo-args.txt")"
	[[ "$args" == *"p:git-cleanup"* ]]
	[[ "$args" == *"p:git-fetch"* ]]
}

# Validation

@test "errors on invalid size" {
	bats_run_zsh "todo-add --domain Git --size huge --slug git-prune 'Prune refs'"
	[[ "$status" -ne 0 ]]
	[[ "$output" == *"size"* ]]
}

# Output

@test "outputs the added item to stdout" {
	bats_run_zsh "todo-add --domain Git --size small --slug git-prune 'Prune remote refs'"
	[[ "$status" -eq 0 ]]
	[[ "$output" != "" ]]
}
