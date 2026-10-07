bats_load_library 'helper'

setup() {
  bats_tmp_dir
  ORIGINAL_HANDLER='handleKeyDown:(br)=>{if(br.name==="right"&&!Do){if(LEe(Wo)&&Ie===""){_e(),Fs(Wo.text),br.preventDefault(),br.stopImmediatePropagation();return}}'
  PATCHED_HANDLER='handleKeyDown:(br)=>{if(br.name==="down" &&!Do){if(LEe(Wo)&&Ie===""){_e(),Fs(Wo.text),br.preventDefault(),br.stopImmediatePropagation();return}}'
  export FAKE_BINARY="$BATS_TMP_DIR/claude"
}

@test "returns 0 when the binary has the patched handler" {
  printf 'before%safter' "$PATCHED_HANDLER" > "$FAKE_BINARY"

  bats_run_zsh "claude-is-suggestion-patched $FAKE_BINARY"

  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "returns 1 when the binary has the original handler" {
  printf 'before%safter' "$ORIGINAL_HANDLER" > "$FAKE_BINARY"

  bats_run_zsh "claude-is-suggestion-patched $FAKE_BINARY"

  [[ "$status" -eq 1 ]]
  [[ "$output" == "" ]]
}

@test "returns 1 when the file does not exist" {
  bats_run_zsh "claude-is-suggestion-patched $BATS_TMP_DIR/missing"

  [[ "$status" -eq 1 ]]
  [[ "$output" == "" ]]
}

@test "works on a file with binary content around the handler" {
  printf '\x00\x01\xff\xfe%s\x00\x80\xc3\x28' "$PATCHED_HANDLER" > "$FAKE_BINARY"

  bats_run_zsh "claude-is-suggestion-patched $FAKE_BINARY"

  [[ "$status" -eq 0 ]]
}

@test "uses the default binary path when no argument is given" {
  mkdir -p "$BATS_TMP_DIR/node_modules/.bin"
  printf '%s' "$PATCHED_HANDLER" > "$BATS_TMP_DIR/node_modules/.bin/claude"
  # The mocked root still needs the patch tools
  ln --symbolic "$PWD/tools" "$BATS_TMP_DIR/tools"
  bats_mock_env OROSHI_ROOT "$BATS_TMP_DIR"

  bats_run_zsh "claude-is-suggestion-patched"

  [[ "$status" -eq 0 ]]
}
