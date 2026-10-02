bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export FAKE_BINARY="$BATS_TMP_DIR/claude"
}

@test "returns 0 when the file contains the marker" {
  printf 'before/*oroshi-patched*/after' > "$FAKE_BINARY"

  bats_run_zsh "claude-is-color-patched $FAKE_BINARY"

  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "returns 1 when the file does not contain the marker" {
  printf 'before/*something-else*/after' > "$FAKE_BINARY"

  bats_run_zsh "claude-is-color-patched $FAKE_BINARY"

  [[ "$status" -eq 1 ]]
  [[ "$output" == "" ]]
}

@test "returns 1 when the file does not exist" {
  bats_run_zsh "claude-is-color-patched $BATS_TMP_DIR/missing"

  [[ "$status" -eq 1 ]]
  [[ "$output" == "" ]]
}

@test "works on a file with binary content around the marker" {
  printf '\x00\x01\xff\xfe/*oroshi-patched*/\x00\x80\xc3\x28' > "$FAKE_BINARY"

  bats_run_zsh "claude-is-color-patched $FAKE_BINARY"

  [[ "$status" -eq 0 ]]
}

@test "uses the default binary path when no argument is given" {
  mkdir -p "$BATS_TMP_DIR/node_modules/.bin"
  printf 'x/*oroshi-patched*/x' > "$BATS_TMP_DIR/node_modules/.bin/claude"
  bats_mock_env OROSHI_ROOT "$BATS_TMP_DIR"

  bats_run_zsh "claude-is-color-patched"

  [[ "$status" -eq 0 ]]
}

@test "returns 1 on the default binary path when it lacks the marker" {
  mkdir -p "$BATS_TMP_DIR/node_modules/.bin"
  printf 'nothing here' > "$BATS_TMP_DIR/node_modules/.bin/claude"
  bats_mock_env OROSHI_ROOT "$BATS_TMP_DIR"

  bats_run_zsh "claude-is-color-patched"

  [[ "$status" -eq 1 ]]
}

@test "the marker literal equals PATCH_MARKER exported by the patch module" {
  local helperFile="tools/term/zsh/config/functions/autoload/ai/claude-is-color-patched"
  local moduleFile="$PWD/tools/ai/claude/config/syntax/src/patchHighlightTables.js"
  local helperMarker="$(grep --only-matching --perl-regexp "PATCH_MARKER='\K[^']+" "$helperFile")"
  local moduleMarker="$(node --input-type=module --eval "import { PATCH_MARKER } from '$moduleFile'; process.stdout.write(PATCH_MARKER)")"

  [[ "$helperMarker" != "" ]]
  [[ "$helperMarker" == "$moduleMarker" ]]
}
