bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../fzf-fs-preview.zsh'"
  bats_mock_env "OROSHI_TMP_FOLDER" "$BATS_TMP_DIR/tmp"
}

@test "fzf-preview-document-cover: echoes cache path after generating it" {
  file-hash() { echo "abc123"; }
  fake-extractor() { touch "$2"; }
  bats_mock file-hash fake-extractor

  local expectedPath="$BATS_TMP_DIR/tmp/fzf/previews/abc123.png"

  bats_run_zsh "${sourcePrefix}; fullPath='/fake/file.pdf'; fzf-preview-document-cover '/fake/file.pdf' 'fake-extractor'"
  [ "$status" -eq 0 ]
  [ "$output" = "$expectedPath" ]
}

@test "fzf-preview-document-cover: echoes cache path when already cached" {
  file-hash() { echo "abc123"; }
  bats_mock file-hash

  local expectedPath="$BATS_TMP_DIR/tmp/fzf/previews/abc123.png"
  mkdir -p "$BATS_TMP_DIR/tmp/fzf/previews"
  touch "$expectedPath"

  bats_run_zsh "${sourcePrefix}; fullPath='/fake/file.pdf'; fzf-preview-document-cover '/fake/file.pdf' 'fake-extractor'"
  [ "$status" -eq 0 ]
  [ "$output" = "$expectedPath" ]
}
