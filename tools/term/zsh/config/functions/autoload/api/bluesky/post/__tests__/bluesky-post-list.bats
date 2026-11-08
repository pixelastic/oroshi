bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub the raw list to record its arguments, then print canned lines
  bluesky-post-list-raw() {
    print -r -- "$@" >"$BATS_TMP_DIR/raw-args"
    echo "at://did:plc:me/app.bsky.feed.post/3k33▮2026-03-12T10:00:00.000Z▮New"
    echo "at://did:plc:me/app.bsky.feed.post/3k11▮2026-03-10T10:00:00.000Z▮Old"
  }
  bats_mock bluesky-post-list-raw
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

@test "passes the flags to the raw list as received" {
  bats_run_zsh "bluesky-post-list --limit 10 --account test"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "--limit 10 --account test" ]]
}

@test "shows the same rows as the raw list, with aligned columns" {
  bats_run_zsh "bluesky-post-list | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "at://did:plc:me/app.bsky.feed.post/3k33  2026-03-12T10:00:00.000Z  New" ]]
  [[ "${lines[1]}" == "at://did:plc:me/app.bsky.feed.post/3k11  2026-03-10T10:00:00.000Z  Old" ]]
}

@test "colors only the AT URI" {
  bats_run_zsh "bluesky-post-list"
  [[ "${lines[0]}" == $'\e['*"3k33"*$'\e[0m  2026-03-12T10:00:00.000Z  New' ]]
}

@test "prints nothing and exits non-zero when there is no post" {
  bluesky-post-list-raw() {
    echo ""
  }
  bats_mock bluesky-post-list-raw

  bats_run_zsh "bluesky-post-list"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}

@test "exits non-zero when the raw list fails" {
  bluesky-post-list-raw() {
    echo "BLUESKY_INVALID_ARGUMENT" >&2
    return 1
  }
  bats_mock bluesky-post-list-raw

  bats_run_zsh "bluesky-post-list"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"BLUESKY_INVALID_ARGUMENT"* ]]
}
