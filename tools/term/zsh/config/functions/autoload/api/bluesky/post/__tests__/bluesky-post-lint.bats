bats_load_library 'helper'

setup() {
  bats_tmp_dir
  printf 'I rewrote my prompt today.\n\nhttps://example.com\n' >"$BATS_TMP_DIR/draft.md"
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

# Stub the prose lint with a canned answer, read from a file to keep its quotes
stub_prose_lint() {
  printf '%s\n' "$1" >"$BATS_TMP_DIR/prose-output"
  prose-lint() {
    print -r -- "$@" >"$BATS_TMP_DIR/prose-args"
    cat "$BATS_TMP_DIR/prose-output"
    return "${PROSE_EXIT:-0}"
  }
  bats_mock prose-lint
  bats_mock_env "PROSE_EXIT" "${2:-0}"
}

@test "lints the draft with the bluesky-writer prose profile" {
  stub_prose_lint '[]'
  bats_run_zsh "bluesky-post-lint --text-file $BATS_TMP_DIR/draft.md"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/prose-args")" == "--profile bluesky-writer $BATS_TMP_DIR/draft.md" ]]
}

@test "merges the prose violations with the post violations" {
  stub_prose_lint '[{"line":1,"rule":"bluesky.NoMarkdown","severity":"error","match":"**","message":"No bold"}]'
  printf 'A **bold** post.\n' >"$BATS_TMP_DIR/draft.md"
  bats_run_zsh "bluesky-post-lint --json --text-file $BATS_TMP_DIR/draft.md"
  [[ "$status" -eq 1 ]]
  printf '%s' "$output" | jq -e 'map(select(.code == "bluesky.NoMarkdown" and .level == "error" and .line == 1)) | length == 1' >/dev/null
}

@test "keeps the length violation of the post" {
  stub_prose_lint '[]'
  bats_run_zsh "bluesky-post-lint --json --text '$(printf 'a%.0s' {1..301})'"
  [[ "$status" -eq 1 ]]
  printf '%s' "$output" | jq -e 'map(select(.code == "too-long-graphemes")) | length == 1' >/dev/null
}

@test "passes when the prose lint only has a suggestion" {
  stub_prose_lint '[{"line":1,"rule":"Google.Passive","severity":"suggestion","match":"was set","message":"Use active voice"}]' 1
  bats_run_zsh "bluesky-post-lint --json --text-file $BATS_TMP_DIR/draft.md"
  [[ "$status" -eq 0 ]]
  printf '%s' "$output" | jq -e 'length == 1' >/dev/null
}

@test "fails when the prose lint crashes" {
  stub_prose_lint '' 2
  bats_run_zsh "bluesky-post-lint --text-file $BATS_TMP_DIR/draft.md"
  [[ "$status" -eq 1 ]]
}

@test "lints inline text as well" {
  stub_prose_lint '[]'
  bats_run_zsh "bluesky-post-lint --text 'Hello world'"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/prose-args")" == "--profile bluesky-writer Hello world" ]]
}
