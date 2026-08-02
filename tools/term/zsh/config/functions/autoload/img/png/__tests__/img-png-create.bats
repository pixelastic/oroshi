bats_load_library 'helper'

setup() {
  bats_disable_worktree_aware
  bats_tmp_dir
}

@test "creates a .png file at the given path" {
  local dest="$BATS_TMP_DIR/test.png"
  bats_run_zsh "img-png-create $dest"
  [[ "$status" -eq 0 ]]
  [[ -f "$dest" ]]
}

@test "errors when no path provided" {
  bats_run_zsh "img-png-create"
  [[ "$status" -ne 0 ]]
}
