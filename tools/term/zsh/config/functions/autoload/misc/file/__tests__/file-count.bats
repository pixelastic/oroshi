bats_load_library 'helper'

setup() {
	bats_tmp_dir
}

@test "counts files and directories recursively" {
	mkdir -p "$BATS_TMP_DIR/testdir/subdir"
	touch "$BATS_TMP_DIR/testdir/a.txt"
	touch "$BATS_TMP_DIR/testdir/b.txt"
	touch "$BATS_TMP_DIR/testdir/subdir/c.txt"

	# 2 files + 1 dir + 1 file in subdir = 4
	bats_run_zsh "cd $BATS_TMP_DIR/testdir && file-count"
	[[ "$status" -eq 0 ]]
	[[ "$output" -eq 4 ]]
}

@test "returns 0 for empty directory" {
	mkdir -p "$BATS_TMP_DIR/empty"

	bats_run_zsh "cd $BATS_TMP_DIR/empty && file-count"
	[[ "$status" -eq 0 ]]
	[[ "$output" -eq 0 ]]
}
