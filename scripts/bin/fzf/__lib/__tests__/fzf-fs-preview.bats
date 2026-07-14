bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_disable_worktree_aware
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../fzf-fs-preview.zsh'"
  bats_mock_env "OROSHI_TMP_FOLDER" "$BATS_TMP_DIR/tmp"

  filetypes-load-definitions() {
    typeset -gA FILETYPES
    FILETYPES[_fdignore:color]=174
    FILETYPES[_fdignore:icon]="DOTICON"
    FILETYPES[js:color]=200
    FILETYPES[js:icon]="JSICON"
    FILETYPES[zsh:color]=173
    FILETYPES[zsh:icon]="Z"
  }
  icons-load-definitions() { typeset -gA ICONS; }
  colors-load-definitions() {
    typeset -gA COLORS
    COLORS[directory]=100
    COLORS[text]=231
    COLORS[executable]=150
  }
  bats_mock filetypes-load-definitions icons-load-definitions colors-load-definitions
}

@test "fzf-preview-thumbnail: echoes cache path after generating it" {
  file-hash() { echo "abc123"; }
  fake-extractor() { touch "$2"; }
  bats_mock file-hash fake-extractor

  local expectedPath="$BATS_TMP_DIR/tmp/fzf/previews/abc123.png"

  bats_run_zsh "${sourcePrefix}; fullPath='/fake/file.pdf'; fzf-preview-thumbnail '/fake/file.pdf' 'fake-extractor'"
  [ "$status" -eq 0 ]
  [ "$output" = "$expectedPath" ]
}

@test "fzf-preview-thumbnail: echoes cache path when already cached" {
  file-hash() { echo "abc123"; }
  bats_mock file-hash

  local expectedPath="$BATS_TMP_DIR/tmp/fzf/previews/abc123.png"
  mkdir -p "$BATS_TMP_DIR/tmp/fzf/previews"
  touch "$expectedPath"

  bats_run_zsh "${sourcePrefix}; fullPath='/fake/file.pdf'; fzf-preview-thumbnail '/fake/file.pdf' 'fake-extractor'"
  [ "$status" -eq 0 ]
  [ "$output" = "$expectedPath" ]
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

@test "fzf-preview-header: autoload file gets zsh color and icon" {
  local autoloadDir="$BATS_TMP_DIR/functions/autoload"
  local autoloadFile="$autoloadDir/my-function"
  mkdir -p "$autoloadDir"
  touch "$autoloadFile"

  bats_run_zsh "${sourcePrefix}; fzf-preview-header '$autoloadFile'"
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\e[38;5;173m'* ]]
  [[ "$output" == *' Z '* ]]
}

@test "fzf-preview-header: non-autoload no-extension non-executable file gets no zsh color" {
  local plainFile="$BATS_TMP_DIR/plain-file"
  touch "$plainFile"

  bats_run_zsh "${sourcePrefix}; fzf-preview-header '$plainFile'"
  [ "$status" -eq 0 ]
  [[ "$output" != *$'\e[38;5;173m'* ]]
}
