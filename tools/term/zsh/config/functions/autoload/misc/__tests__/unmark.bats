bats_load_library 'helper'

setup() {
	bats_tmp_dir
	export MARKPATH="$BATS_TMP_DIR/marks"
	mkdir -p "$MARKPATH"
}

@test "errors when no mark name provided" {
	bats_run_zsh "unmark"
	[[ "$status" -ne 0 ]]
}

@test "errors when mark does not exist" {
	bats_run_zsh "unmark nonexistent"
	[[ "$status" -ne 0 ]]
}

@test "removes an existing mark" {
	ln -s /tmp "$MARKPATH/mymark"
	bats_run_zsh "unmark mymark"
	[[ "$status" -eq 0 ]]
	[[ ! -L "$MARKPATH/mymark" ]]
}
