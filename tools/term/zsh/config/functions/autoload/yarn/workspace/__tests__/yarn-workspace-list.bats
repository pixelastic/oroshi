bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_disable_worktree_aware
}

mock_raw_output() {
  yarn-workspace-list-raw() {
    print "@mono/lib-a▮modules/lib-a▮First library\n@mono/lib-b▮modules/lib-b▮Second library"
  }
  bats_mock yarn-workspace-list-raw
}

# --- Output content ---

@test "displays workspace names" {
  mock_raw_output

  bats_run_zsh "yarn-workspace-list"
  [ "$status" -eq 0 ]
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" == *"@mono/lib-a"* ]]
  [[ "$stripped" == *"@mono/lib-b"* ]]
}

@test "displays relative paths" {
  mock_raw_output

  bats_run_zsh "yarn-workspace-list"
  [ "$status" -eq 0 ]
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" == *"modules/lib-a"* ]]
  [[ "$stripped" == *"modules/lib-b"* ]]
}

@test "displays descriptions" {
  mock_raw_output

  bats_run_zsh "yarn-workspace-list"
  [ "$status" -eq 0 ]
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" == *"First library"* ]]
  [[ "$stripped" == *"Second library"* ]]
}

# --- Path forwarding ---

@test "forwards path argument to yarn-workspace-list-raw" {
  yarn-workspace-list-raw() {
    echo "$@" > "$BATS_TMP_DIR/raw-args.txt"
    print "@mono/lib-a▮modules/lib-a▮First library"
  }
  bats_mock yarn-workspace-list-raw

  bats_run_zsh "yarn-workspace-list /some/path"
  [ "$status" -eq 0 ]
  [ "$(cat "$BATS_TMP_DIR/raw-args.txt")" = "/some/path" ]
}

# --- Empty output ---

@test "returns 0 when raw returns no workspaces" {
  yarn-workspace-list-raw() { return 1; }
  bats_mock yarn-workspace-list-raw

  bats_run_zsh "yarn-workspace-list"
  [ "$status" -eq 0 ]
}
