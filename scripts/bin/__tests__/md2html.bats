bats_load_library 'helper'

setup() {
  bats_tmp_dir

  pandoc() {
    local output="${*: -1}"
    echo "<html>converted</html>" > "$output"
  }
  bats_mock pandoc
}

@test "converts .md file to .html in same directory" {
  echo "# Hello" > "$BATS_TMP_DIR/test.md"
  bats_run_zsh "cd $BATS_TMP_DIR && md2html test.md"
  [ "$status" -eq 0 ]
  [ -f "$BATS_TMP_DIR/test.html" ]
}

@test "prints confirmation message" {
  echo "# Hello" > "$BATS_TMP_DIR/test.md"
  bats_run_zsh "cd $BATS_TMP_DIR && md2html test.md"
  [ "$status" -eq 0 ]
  [[ "$output" == *"test converted to html"* ]]
}

@test "converts multiple files" {
  echo "# A" > "$BATS_TMP_DIR/a.md"
  echo "# B" > "$BATS_TMP_DIR/b.md"
  bats_run_zsh "cd $BATS_TMP_DIR && md2html a.md b.md"
  [ "$status" -eq 0 ]
  [ -f "$BATS_TMP_DIR/a.html" ]
  [ -f "$BATS_TMP_DIR/b.html" ]
}
