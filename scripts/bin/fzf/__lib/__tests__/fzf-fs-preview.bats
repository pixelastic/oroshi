bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../fzf-fs-preview.zsh'"
  bats_mock_env "OROSHI_TMP_FOLDER" "$BATS_TMP_DIR/tmp"

  filetypes-load-definitions() {
    typeset -gA FILETYPES
    FILETYPES[_fdignore:color]=174
    FILETYPES[_fdignore:icon]="DOTICON"
    FILETYPES[js:color]=200
    FILETYPES[js:icon]="JSICON"
  }
  colors-load-definitions() {
    typeset -gA COLORS
    COLORS[directory]=100
  }
  icons-load-definitions() { typeset -gA ICONS; }
  context-badge() { echo ""; }
  simplify-path() { echo ""; }
  bats_mock filetypes-load-definitions colors-load-definitions icons-load-definitions context-badge simplify-path
}

@test "fzf-preview-header: dotfile shows correct ANSI color" {
  touch "$BATS_TMP_DIR/.fdignore"

  bats_run_zsh "${sourcePrefix}; fzf-preview-header '$BATS_TMP_DIR/.fdignore'"
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\e[38;5;174m'* ]]
}

@test "fzf-preview-header: dotfile shows correct icon" {
  touch "$BATS_TMP_DIR/.fdignore"

  bats_run_zsh "${sourcePrefix}; fzf-preview-header '$BATS_TMP_DIR/.fdignore'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"DOTICON"* ]]
}

@test "fzf-preview-header: regular .js file gets its extension-based color" {
  touch "$BATS_TMP_DIR/app.js"

  bats_run_zsh "${sourcePrefix}; fzf-preview-header '$BATS_TMP_DIR/app.js'"
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\e[38;5;200m'* ]]
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
