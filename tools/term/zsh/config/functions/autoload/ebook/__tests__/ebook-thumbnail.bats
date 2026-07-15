bats_load_library 'helper'

setup() {
  bats_tmp_dir
  FIXTURE="$BATS_TEST_DIRNAME/fixtures/simple.epub"
}

@test "returns 1 if no input" {
  bats_run_zsh "ebook-thumbnail"
  [[ "$status" -eq 1 ]]
}

@test "extracts cover as PNG to specified output path" {
  local coverPath="$BATS_TMP_DIR/cover.png"
  bats_run_zsh "ebook-thumbnail $FIXTURE $coverPath"
  [[ "$status" -eq 0 ]]
  [[ -f "$coverPath" ]]
}

@test "output is a valid PNG file" {
  local coverPath="$BATS_TMP_DIR/cover.png"
  bats_run_zsh "ebook-thumbnail $FIXTURE $coverPath"
  bats_run_zsh "file $coverPath"
  [[ "$output" == *"PNG"* ]]
}
