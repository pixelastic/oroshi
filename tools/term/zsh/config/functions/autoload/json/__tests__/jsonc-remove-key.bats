bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "removes a top-level key and preserves comments" {
  cat > "$BATS_TMP_DIR/input.jsonc" <<'EOF'
{
  // Keep this entry
  "keep": "value",
  // Remove this entry
  "removeMe": "gone",
  // Also keep this
  "alsoKeep": true
}
EOF

  bats_run_zsh "jsonc-remove-key $BATS_TMP_DIR/input.jsonc removeMe"
  [[ "$status" -eq 0 ]]

  local actual
  actual="$(cat "$BATS_TMP_DIR/input.jsonc")"

  local expected
  expected=$(cat <<'EOF'
{
  // Keep this entry
  "keep": "value",
  // Also keep this
  "alsoKeep": true
}
EOF
)
  [[ "$actual" = "$expected" ]]
}

@test "exits successfully when key does not exist" {
  cat > "$BATS_TMP_DIR/input.jsonc" <<'EOF'
{
  "existing": true
}
EOF

  local before
  before="$(cat "$BATS_TMP_DIR/input.jsonc")"

  bats_run_zsh "jsonc-remove-key $BATS_TMP_DIR/input.jsonc nonexistent"
  [[ "$status" -eq 0 ]]

  local after
  after="$(cat "$BATS_TMP_DIR/input.jsonc")"
  [[ "$before" = "$after" ]]
}

@test "exits with error when file does not exist" {
  bats_run_zsh "jsonc-remove-key $BATS_TMP_DIR/nope.jsonc key"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"nope.jsonc"* ]]
}

@test "exits with error when file is not valid JSONC" {
  echo "not { valid json at all" > "$BATS_TMP_DIR/bad.jsonc"

  bats_run_zsh "jsonc-remove-key $BATS_TMP_DIR/bad.jsonc key"
  [[ "$status" -ne 0 ]]
}
