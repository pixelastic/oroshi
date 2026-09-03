bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# -- AI vocabulary detection --

@test "flags overused AI vocabulary (delve)" {
  local file="$BATS_TMP_DIR/ai-text.md"
  printf 'We delve into the details of the project.\n' > "$file"
  bats_run_zsh "prose-lint $file"
  [[ "$status" -eq 1 ]]
  printf '%s' "$output" | jq -e '.[] | select(.rule | startswith("ai-tells."))' >/dev/null
}

@test "flags overused AI vocabulary (robust)" {
  local file="$BATS_TMP_DIR/ai-text.md"
  printf 'This robust framework handles all edge cases.\n' > "$file"
  bats_run_zsh "prose-lint $file"
  [[ "$status" -eq 1 ]]
  printf '%s' "$output" | jq -e '.[] | select(.rule | startswith("ai-tells."))' >/dev/null
}

@test "flags hedging phrases" {
  local file="$BATS_TMP_DIR/ai-text.md"
  printf 'It is worth noting that the system works well.\n' > "$file"
  bats_run_zsh "prose-lint $file"
  [[ "$status" -eq 1 ]]
  printf '%s' "$output" | jq -e '.[] | select(.rule | startswith("ai-tells."))' >/dev/null
}

# -- Severity level --

@test "ai-tells rules report as warning severity" {
  local file="$BATS_TMP_DIR/ai-text.md"
  printf 'We delve into the details of the project.\n' > "$file"
  bats_run_zsh "prose-lint $file"
  [[ "$status" -eq 1 ]]
  local severity="$(printf '%s' "$output" | jq -r '[.[] | select(.rule | startswith("ai-tells."))] | .[0].severity')"
  [[ "$severity" == "warning" ]]
}

# -- Clean text --

@test "does not flag plain technical prose" {
  local file="$BATS_TMP_DIR/clean-text.md"
  printf 'The function returns a list of integers.\n' > "$file"
  bats_run_zsh "prose-lint $file"
  # Should not have ai-tells violations (may have others)
  local aiTellsCount="$(printf '%s' "$output" | jq '[.[] | select(.rule | startswith("ai-tells."))] | length')"
  [[ "$aiTellsCount" -eq 0 ]]
}
