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
		Write docs domain:Git size:small id:git-docs
	ITEMS
}

# No filters

@test "lists all items when no filters given" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-list"
	[[ "$status" -eq 0 ]]
	[[ "$output" == *"Buy milk"* ]]
	[[ "$output" == *"Clean up branches"* ]]
	[[ "$output" == *"Write docs"* ]]
}

# Domain filter

@test "lists only items matching the domain" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-list --domain Git"
	[[ "$status" -eq 0 ]]
	[[ "$output" == *"Clean up branches"* ]]
	[[ "$output" == *"Write docs"* ]]
	[[ "$output" != *"Buy milk"* ]]
}

# Size filter

@test "lists only items matching the size" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-list --size small"
	[[ "$status" -eq 0 ]]
	[[ "$output" == *"Buy milk"* ]]
	[[ "$output" == *"Write docs"* ]]
	[[ "$output" != *"Clean up branches"* ]]
}

# Combined filters

@test "lists only items matching both domain and size" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-list --domain Git --size small"
	[[ "$status" -eq 0 ]]
	[[ "$output" == *"Write docs"* ]]
	[[ "$output" != *"Buy milk"* ]]
	[[ "$output" != *"Clean up branches"* ]]
}
