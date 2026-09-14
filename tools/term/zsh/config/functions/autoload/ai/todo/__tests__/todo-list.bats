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
		2025-01-15 Buy milk domain:Home size:small id:buy-milk
		2025-01-10 Clean up branches domain:Git size:medium id:git-cleanup
		2025-01-20 Write docs domain:Git size:small id:git-docs p:git-cleanup
	ITEMS
}

# No filter — domain column visible

@test "all slugs appear in output when no filter" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-list"
	[[ "$status" -eq 0 ]]
	local stripped="$(bats_strip_ansi "$output")"
	[[ "$stripped" == *"buy-milk"* ]]
	[[ "$stripped" == *"git-cleanup"* ]]
	[[ "$stripped" == *"git-docs"* ]]
}

@test "domain names appear in output when no filter" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-list"
	[[ "$status" -eq 0 ]]
	local stripped="$(bats_strip_ansi "$output")"
	[[ "$stripped" == *"Home"* ]]
	[[ "$stripped" == *"Git"* ]]
}

# With domain filter — no domain column

@test "only matching slugs appear with domain filter" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-list Git"
	[[ "$status" -eq 0 ]]
	local stripped="$(bats_strip_ansi "$output")"
	[[ "$stripped" == *"git-cleanup"* ]]
	[[ "$stripped" == *"git-docs"* ]]
}

@test "non-matching slugs absent with domain filter" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-list Git"
	[[ "$status" -eq 0 ]]
	local stripped="$(bats_strip_ansi "$output")"
	[[ "$stripped" != *"buy-milk"* ]]
}

# Empty result

@test "outputs nothing when no items match" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-list NonExistent"
	[[ "$status" -eq 0 ]]
	[[ "$output" == "" ]]
}
