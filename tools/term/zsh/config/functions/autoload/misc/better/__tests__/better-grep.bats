bats_load_library 'helper'

setup() {
	bats_tmp_dir
}

@test "finds matching lines in a file" {
	echo "hello world" > "$BATS_TMP_DIR/test.txt"
	echo "goodbye" >> "$BATS_TMP_DIR/test.txt"

	bats_run_zsh "better-grep hello $BATS_TMP_DIR/test.txt"
	[[ "$status" -eq 0 ]]
	[[ "$output" == *"hello world"* ]]
}

@test "passes extra arguments to rg" {
	echo "Hello World" > "$BATS_TMP_DIR/test.txt"

	bats_run_zsh "better-grep --ignore-case hello $BATS_TMP_DIR/test.txt"
	[[ "$status" -eq 0 ]]
	[[ "$output" == *"Hello World"* ]]
}

@test "exits non-zero when no match" {
	echo "goodbye" > "$BATS_TMP_DIR/test.txt"

	bats_run_zsh "better-grep hello $BATS_TMP_DIR/test.txt"
	[[ "$status" -ne 0 ]]
}
