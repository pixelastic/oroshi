bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "bluesky-writer profile flags bold" {
  local file="$BATS_TMP_DIR/draft.md"
  printf 'We shipped the **new** release today.\n' > "$file"
  bats_run_zsh "prose-lint --profile bluesky-writer $file"
  [[ "$status" -eq 1 ]]
  printf '%s' "$output" | jq -e '.[] | select(.rule == "bluesky.NoMarkdown")' >/dev/null
}

@test "bluesky-writer profile flags a marketing phrase" {
  local file="$BATS_TMP_DIR/draft.md"
  printf 'This tool is a game-changer for your team.\n' > "$file"
  bats_run_zsh "prose-lint --profile bluesky-writer $file"
  [[ "$status" -eq 1 ]]
  printf '%s' "$output" | jq -e '.[] | select(.rule == "bluesky.NoMarketing")' >/dev/null
}

@test "bluesky-writer profile flags a third hashtag" {
  local file="$BATS_TMP_DIR/draft.md"
  printf 'New release is out. #zsh #cli #dotfiles\n' > "$file"
  bats_run_zsh "prose-lint --profile bluesky-writer $file"
  [[ "$status" -eq 1 ]]
  printf '%s' "$output" | jq -e '.[] | select(.rule == "bluesky.MaxHashtags")' >/dev/null
}

@test "bluesky-writer profile accepts two hashtags" {
  local file="$BATS_TMP_DIR/draft.md"
  printf 'New release is out. #zsh #cli\n' > "$file"
  bats_run_zsh "prose-lint --profile bluesky-writer $file"
  printf '%s' "$output" | jq -e 'type == "array"' >/dev/null
  printf '%s' "$output" | jq -e '[.[] | select(.rule | startswith("bluesky."))] | length == 0' >/dev/null
}

@test "bluesky-writer profile passes a clean draft" {
  local file="$BATS_TMP_DIR/draft.md"
  printf 'I rewrote my zsh prompt today.\n\nIt starts in 40 ms now, down from 300. The slow part was a git call.\n\nOne cache fixed it. #zsh\n' > "$file"
  bats_run_zsh "prose-lint --profile bluesky-writer $file"
  printf '%s' "$output" | jq -e 'type == "array"' >/dev/null
  printf '%s' "$output" | jq -e '[.[] | select(.rule | startswith("bluesky."))] | length == 0' >/dev/null
}
