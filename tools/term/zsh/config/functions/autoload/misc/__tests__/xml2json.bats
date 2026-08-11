bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "converts XML file to JSON" {
  echo '<root><name>test</name></root>' > "$BATS_TMP_DIR/input.xml"
  bats_disable_worktree_aware

  bats_run_zsh "cd $BATS_TMP_DIR && xml2json input.xml"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/input.json" ]]

  local content
  content="$(cat "$BATS_TMP_DIR/input.json")"
  [[ "$content" == *'"name"'* ]]
  [[ "$content" == *'"test"'* ]]
}

@test "converts multiple XML files" {
  echo '<root><a>1</a></root>' > "$BATS_TMP_DIR/one.xml"
  echo '<root><b>2</b></root>' > "$BATS_TMP_DIR/two.xml"
  bats_disable_worktree_aware

  bats_run_zsh "cd $BATS_TMP_DIR && xml2json one.xml two.xml"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/one.json" ]]
  [[ -f "$BATS_TMP_DIR/two.json" ]]
}
