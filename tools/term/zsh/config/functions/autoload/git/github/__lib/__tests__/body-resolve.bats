bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '${OROSHI_ROOT}/tools/term/zsh/config/functions/autoload/git/github/__lib/body-resolve.zsh'"
}

# Print the body the resolver put in $REPLY
resolve_body() {
  bats_run_zsh "$sourcePrefix && git-github-body-resolve $* && printf '%s' \"\$REPLY\""
}

@test "returns the text of --body" {
  resolve_body --body "'Hello world'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "Hello world" ]]
}

@test "returns the content of --body-file" {
  printf 'Line one\nLine two\n' > "$BATS_TMP_DIR/body.md"

  resolve_body --body-file "'$BATS_TMP_DIR/body.md'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == $'Line one\nLine two' ]]
}

@test "returns an empty body when no flag is given" {
  resolve_body
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "fails when --body and --body-file are both given" {
  printf 'From file' > "$BATS_TMP_DIR/body.md"

  resolve_body --body "'From flag'" --body-file "'$BATS_TMP_DIR/body.md'"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"--body"*"--body-file"* ]]
}

@test "fails when the body file does not exist" {
  resolve_body --body-file "'$BATS_TMP_DIR/missing.md'"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"missing.md"* ]]
}
