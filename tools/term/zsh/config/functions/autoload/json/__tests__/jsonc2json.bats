bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$OROSHI_ZSH_AUTOLOAD/json/jsonc2json"
  JSONC_FILE="$BATS_TMP_DIR/test.jsonc"
}

teardown() {
  bats_cleanup
}

# --- comment stripping ---

@test "strips full-line // comments" {
  cat >"$JSONC_FILE" <<'JSONC'
{
  // this is a comment
  "key": "value"
}
JSONC
  bats_run_zsh "$CURRENT" "$JSONC_FILE"
  run jq -r '.key' <<<"$output"
  [ "$output" = "value" ]
}

@test "strips leading-whitespace // comments" {
  cat >"$JSONC_FILE" <<'JSONC'
{
    // indented comment
  "key": "value"
}
JSONC
  bats_run_zsh "$CURRENT" "$JSONC_FILE"
  run jq -r '.key' <<<"$output"
  [ "$output" = "value" ]
}

@test "preserves values containing //" {
  cat >"$JSONC_FILE" <<'JSONC'
{
  "url": "https://example.com"
}
JSONC
  bats_run_zsh "$CURRENT" "$JSONC_FILE"
  run jq -r '.url' <<<"$output"
  [ "$output" = "https://example.com" ]
}

# --- output validity ---

@test "output is valid JSON" {
  cat >"$JSONC_FILE" <<'JSONC'
{
  // comment
  "a": 1,
  "b": "two"
}
JSONC
  bats_run_zsh "$CURRENT" "$JSONC_FILE"
  run jq '.' <<<"$output"
  [ "$status" -eq 0 ]
}

@test "plain JSON file passes through unchanged" {
  echo '{"x":42}' >"$JSONC_FILE"
  bats_run_zsh "$CURRENT" "$JSONC_FILE"
  run jq '.x' <<<"$output"
  [ "$output" = "42" ]
}
