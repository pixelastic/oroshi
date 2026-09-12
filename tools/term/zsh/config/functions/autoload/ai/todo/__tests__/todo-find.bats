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

	# Seed todo.txt with known content
	cat > "$BATS_TMP_DIR/todo.txt" <<-'ITEMS'
		Buy milk domain:Home size:small id:buy-milk
		Clean up branches domain:Git size:medium id:git-cleanup
	ITEMS
}

# Lookup

@test "returns the topydo item number for a known slug" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-find git-cleanup"
	[[ "$status" -eq 0 ]]
	[[ "$output" =~ ^[0-9]+$ ]]
}

# Validation

@test "errors when slug is not found" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-find nonexistent"
	[[ "$status" -ne 0 ]]
}
