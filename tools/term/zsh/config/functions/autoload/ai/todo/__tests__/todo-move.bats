bats_load_library 'helper'

setup() {
	bats_tmp_dir

	# Local topydo config scoped to this test's temp dir
	export OROSHI_TODO_FILE="$BATS_TMP_DIR/todo.txt"
	touch "$BATS_TMP_DIR/todo.txt" "$BATS_TMP_DIR/done.txt"
	cat > "$BATS_TMP_DIR/.topydo" <<-CONF
		[topydo]
		filename = $BATS_TMP_DIR/todo.txt
		archive_filename = $BATS_TMP_DIR/done.txt
	CONF

	# Seed todo.txt with known content
	cat > "$BATS_TMP_DIR/todo.txt" <<-'ITEMS'
		Buy milk domain:Home size:small id:buy-milk
		Prune remote refs domain:Git size:small id:git-prune p:git-cleanup
		Clean up branches domain:Git size:medium id:git-cleanup
	ITEMS
}

# Basic move

@test "changes the domain tag from old domain to new domain" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-move git-cleanup Nvim"
	[[ "$status" -eq 0 ]]

	grep -q "domain:Nvim" "$BATS_TMP_DIR/todo.txt"
	run ! grep -q "domain:Git.*id:git-cleanup" "$BATS_TMP_DIR/todo.txt"
}

@test "preserves all other tags" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-move git-cleanup Nvim"
	[[ "$status" -eq 0 ]]

	# Description, size, and id are preserved on the moved item
	local line
	line="$(grep "id:git-cleanup" "$BATS_TMP_DIR/todo.txt")"
	[[ "$line" == *"Clean up branches"* ]]
	[[ "$line" == *"size:medium"* ]]
	[[ "$line" == *"id:git-cleanup"* ]]
	[[ "$line" == *"domain:Nvim"* ]]
}

# Validation

@test "errors when slug is not found" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-move nonexistent Nvim"
	[[ "$status" -ne 0 ]]
}

# Output

@test "outputs the modified item to stdout" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-move git-cleanup Nvim"
	[[ "$status" -eq 0 ]]
	[[ "$output" == *"git-cleanup"* ]]
	[[ "$output" == *"domain:Nvim"* ]]
}
