bats_load_library 'helper'

setup() {
  bats_disable_worktree_aware
  bats_tmp_dir
}

@test "creates a .svg file at the given path" {
  local dest="$BATS_TMP_DIR/test.svg"
  bats_run_zsh "img-svg-create $dest"
  [[ "$status" -eq 0 ]]
  [[ -f "$dest" ]]
}

@test "errors when no path provided" {
  bats_run_zsh "img-svg-create"
  [[ "$status" -ne 0 ]]
}
