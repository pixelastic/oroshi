bats_load_library 'helper'

setup() {
	bats_tmp_dir
}

@test "sends directory to trash-put" {
	# Track what trash-put received
	trash-put() { echo "$1" > "$BATS_TMP_DIR/trashed.txt"; }
	bats_mock trash-put

	mkdir -p "$BATS_TMP_DIR/mydir"
	bats_run_zsh "better-rmdir $BATS_TMP_DIR/mydir"
	[[ "$status" -eq 0 ]]
	[[ "$(cat "$BATS_TMP_DIR/trashed.txt")" == "$BATS_TMP_DIR/mydir" ]]
}

@test "uses rm -rf for Trash directories" {
	# Create a .Trash-1000 directory
	mkdir -p "$BATS_TMP_DIR/.Trash-1000"
	touch "$BATS_TMP_DIR/.Trash-1000/somefile"

	bats_run_zsh "better-rmdir $BATS_TMP_DIR/.Trash-1000"
	[[ "$status" -eq 0 ]]
	[[ ! -d "$BATS_TMP_DIR/.Trash-1000" ]]
}

@test "handles multiple arguments" {
	trash-put() { echo "$1" >> "$BATS_TMP_DIR/trashed.txt"; }
	bats_mock trash-put

	mkdir -p "$BATS_TMP_DIR/dir1" "$BATS_TMP_DIR/dir2"
	bats_run_zsh "better-rmdir $BATS_TMP_DIR/dir1 $BATS_TMP_DIR/dir2"
	[[ "$status" -eq 0 ]]
	[[ "$(wc -l < "$BATS_TMP_DIR/trashed.txt")" -eq 2 ]]
}
