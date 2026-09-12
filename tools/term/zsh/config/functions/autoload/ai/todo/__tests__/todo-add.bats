bats_load_library 'helper'

setup() {
	bats_tmp_dir

	# Local topydo config scoped to this test's temp dir
	touch "$BATS_TMP_DIR/todo.txt" "$BATS_TMP_DIR/done.txt"
	cat > "$BATS_TMP_DIR/.topydo" <<-CONF
		[topydo]
		filename = $BATS_TMP_DIR/todo.txt
		archive_filename = $BATS_TMP_DIR/done.txt
	CONF
}

# Basic add

@test "adds item with correct project tag, size tag, and id tag" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-add --domain Git --size small --slug git-prune 'Prune remote refs'"
	[[ "$status" -eq 0 ]]

	local content="$(cat "$BATS_TMP_DIR/todo.txt")"
	[[ "$content" == *"domain:Git"* ]]
	[[ "$content" == *"size:small"* ]]
	[[ "$content" == *"id:git-prune"* ]]
}

@test "includes description text in todo.txt" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-add --domain Git --size small --slug git-prune 'Prune remote refs'"
	[[ "$status" -eq 0 ]]

	local content="$(cat "$BATS_TMP_DIR/todo.txt")"
	[[ "$content" == *"Prune remote refs"* ]]
}

# Blocked-by

@test "adds p: tags for each blocked-by slug" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-add --domain Git --size small --slug git-prune --blocked-by git-cleanup 'Prune refs'"
	[[ "$status" -eq 0 ]]

	local content="$(cat "$BATS_TMP_DIR/todo.txt")"
	[[ "$content" == *"p:git-cleanup"* ]]
}

@test "supports multiple comma-separated blockers" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-add --domain Git --size small --slug git-prune --blocked-by git-cleanup,git-fetch 'Prune refs'"
	[[ "$status" -eq 0 ]]

	local content="$(cat "$BATS_TMP_DIR/todo.txt")"
	[[ "$content" == *"p:git-cleanup"* ]]
	[[ "$content" == *"p:git-fetch"* ]]
}

# Validation

@test "errors on invalid size" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-add --domain Git --size huge --slug git-prune 'Prune refs'"
	[[ "$status" -ne 0 ]]
	[[ "$output" == *"size"* ]]
}

# Output

@test "outputs the added item to stdout" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-add --domain Git --size small --slug git-prune 'Prune remote refs'"
	[[ "$status" -eq 0 ]]
	[[ "$output" != "" ]]
}
