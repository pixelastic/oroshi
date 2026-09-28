bats_load_library 'helper'

setup() {
	bats_tmp_dir
}

@test "copies the fixed prompt to the clipboard and prints it" {
	midjourney-fix() { echo "$(cat) --v 8.2"; }
	clipboard-write() { echo "$1" > "$BATS_TMP_DIR/clipboard"; }
	bats_mock midjourney-fix clipboard-write

	bats_run_zsh "midjourney-writer-end" <<<'a cat'
	[[ "$status" -eq 0 ]]
	[[ "$output" == "a cat --v 8.2" ]]
	[[ "$(cat "$BATS_TMP_DIR/clipboard")" == "a cat --v 8.2" ]]
}

@test "passes the argument to midjourney-fix" {
	midjourney-fix() { echo "$1 --v 8.2"; }
	clipboard-write() { :; }
	bats_mock midjourney-fix clipboard-write

	bats_run_zsh "midjourney-writer-end 'a dog'"
	[[ "$output" == "a dog --v 8.2" ]]
}

@test "copies nothing when the fix fails" {
	midjourney-fix() { return 1; }
	clipboard-write() { echo "$1" > "$BATS_TMP_DIR/clipboard"; }
	bats_mock midjourney-fix clipboard-write

	bats_run_zsh "midjourney-writer-end" <<<''
	[[ "$status" -ne 0 ]]
	[[ ! -f "$BATS_TMP_DIR/clipboard" ]]
}
