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
	# Fields: description domain size id creation-date, some with p: tags
	cat > "$BATS_TMP_DIR/todo.txt" <<-'ITEMS'
		2025-01-15 Buy milk domain:Home size:small id:buy-milk
		2025-01-10 Clean up branches domain:Git size:medium id:git-cleanup
		2025-01-20 Write docs domain:Git size:small id:git-docs p:git-cleanup
		2025-01-12 Refactor tests domain:Git size:large id:git-refactor
	ITEMS
}

# All items

@test "outputs all todos with correct column format when no args" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-list-raw"
	[[ "$status" -eq 0 ]]
	[[ "$output" == *"▮"* ]]

	# Check that all 4 items are present
	local lineCount="$(echo "$output" | wc -l)"
	[[ "$lineCount" -eq 4 ]]
}

# Domain filter

@test "outputs only matching domain when positional arg given" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-list-raw Git"
	[[ "$status" -eq 0 ]]

	# All lines should be Git domain
	[[ "$output" == *"Git▮"* ]]
	[[ "$output" != *"Home▮"* ]]
}

# Size mapping

@test "maps small to 1, medium to 2, large to 3" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-list-raw"
	[[ "$status" -eq 0 ]]

	# buy-milk is small → sizeRank 1
	[[ "$output" == *"Home▮1▮buy-milk▮"* ]]
	# git-cleanup is medium → sizeRank 2
	[[ "$output" == *"Git▮2▮git-cleanup▮"* ]]
	# git-refactor is large → sizeRank 3
	[[ "$output" == *"Git▮3▮git-refactor▮"* ]]
}

# Blocked detection

@test "sets blocked=1 when item has p: tags, 0 otherwise" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-list-raw"
	[[ "$status" -eq 0 ]]

	# git-docs has p:git-cleanup → blocked=1
	[[ "$output" == *"git-docs▮Write docs▮1▮"* ]]
	# buy-milk has no p: → blocked=0
	[[ "$output" == *"buy-milk▮Buy milk▮0▮"* ]]
}

# Sort order

@test "items sorted by domain, then sizeRank, then date, then slug" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-list-raw"
	[[ "$status" -eq 0 ]]

	# Expected order:
	# Git size:1 (small) 2025-01-20 git-docs
	# Git size:2 (medium) 2025-01-10 git-cleanup
	# Git size:3 (large) 2025-01-12 git-refactor
	# Home size:1 (small) 2025-01-15 buy-milk
	local lines=()
	while IFS= read -r line; do
		lines+=("$line")
	done <<< "$output"

	[[ "${lines[0]}" == *"git-docs"* ]]
	[[ "${lines[1]}" == *"git-cleanup"* ]]
	[[ "${lines[2]}" == *"git-refactor"* ]]
	[[ "${lines[3]}" == *"buy-milk"* ]]
}

# Backslash in description

@test "handles backslashes in descriptions without error" {
	cat > "$BATS_TMP_DIR/todo.txt" <<-'ITEMS'
		2025-01-15 Prefer `\cmd` over `command cmd` domain:Zsh size:small id:zsh-backslash
	ITEMS

	bats_run_zsh "cd $BATS_TMP_DIR && todo-list-raw"
	[[ "$status" -eq 0 ]]
	[[ "$output" == *"zsh-backslash"* ]]
	[[ "$output" == *'Prefer `\cmd` over `command cmd`'* ]]
}

# Empty result

@test "outputs nothing when no items match" {
	bats_run_zsh "cd $BATS_TMP_DIR && todo-list-raw NonExistent"
	[[ "$status" -eq 0 ]]
	[[ "$output" == "" ]]
}
