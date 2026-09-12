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
		Review PR domain:Work size:large id:review-pr p:git-prune p:git-cleanup
	ITEMS
}

# Basic removal

@test "item no longer appears in todo.txt after removal" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-remove git-cleanup"
	[[ "$status" -eq 0 ]]

	run ! grep -q "id:git-cleanup" "$BATS_TMP_DIR/todo.txt"
}

# Dependency cleanup

@test "removes p:slug references from other items after deletion" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-remove git-cleanup"
	[[ "$status" -eq 0 ]]

	run ! grep -q "p:git-cleanup" "$BATS_TMP_DIR/todo.txt"
}

@test "only removes matching p: tag, leaves others intact" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-remove git-cleanup"
	[[ "$status" -eq 0 ]]

	# review-pr still has p:git-prune (only p:git-cleanup was removed)
	grep -q "p:git-prune" "$BATS_TMP_DIR/todo.txt"
}

# Validation

@test "errors when slug is not found" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-remove nonexistent"
	[[ "$status" -ne 0 ]]
}

# Output

@test "outputs the removed item to stdout" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-remove git-cleanup"
	[[ "$status" -eq 0 ]]
	[[ "$output" == *"git-cleanup"* ]]
}
