bats_load_library 'helper'

setup() {
	bats_tmp_dir
}

@test "finds files by name" {
	mkdir -p "$BATS_TMP_DIR/sub"
	touch "$BATS_TMP_DIR/hello.txt"
	touch "$BATS_TMP_DIR/sub/world.txt"

	bats_run_zsh "better-find hello.txt $BATS_TMP_DIR"
	[[ "$status" -eq 0 ]]
	[[ "$output" == *"hello.txt"* ]]
}

@test "follows symlinks" {
	mkdir -p "$BATS_TMP_DIR/target"
	touch "$BATS_TMP_DIR/target/linked.txt"
	ln -s "$BATS_TMP_DIR/target" "$BATS_TMP_DIR/link"

	bats_run_zsh "better-find linked.txt $BATS_TMP_DIR/link"
	[[ "$status" -eq 0 ]]
	[[ "$output" == *"linked.txt"* ]]
}

@test "finds hidden files" {
	touch "$BATS_TMP_DIR/.hidden"

	bats_run_zsh "better-find .hidden $BATS_TMP_DIR"
	[[ "$status" -eq 0 ]]
	[[ "$output" == *".hidden"* ]]
}

@test "passes extra arguments to fd" {
	touch "$BATS_TMP_DIR/a.txt"
	touch "$BATS_TMP_DIR/b.rs"

	bats_run_zsh "better-find --extension txt . $BATS_TMP_DIR"
	[[ "$status" -eq 0 ]]
	[[ "$output" == *"a.txt"* ]]
	[[ "$output" != *"b.rs"* ]]
}
