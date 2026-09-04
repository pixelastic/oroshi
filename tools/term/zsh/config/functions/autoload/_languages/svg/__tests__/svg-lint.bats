bats_load_library 'helper'

# Mock xml-lint: capture calls, simulate output via control files
# Mock svg-fix: capture calls
# Mock file-expand: return .svg files from args (skip --filter and its value)
setup() {
  bats_tmp_dir

  # Default: clean xml-lint output
  printf '' > "$BATS_TMP_DIR/xmllint_stdout"
  printf '0' > "$BATS_TMP_DIR/xmllint_exit"

  xml-lint() {
    printf '%s\n' "$*" >> "$BATS_TMP_DIR/xmllint_calls"
    cat "$BATS_TMP_DIR/xmllint_stdout"
    return "$(cat "$BATS_TMP_DIR/xmllint_exit")"
  }
  svg-fix() {
    printf '%s\n' "$*" >> "$BATS_TMP_DIR/fix_calls"
  }
  file-expand() {
    printf '%s\n' "$*" >> "$BATS_TMP_DIR/expand_calls"
    # Skip --filter and its value, return remaining args as file paths
    shift 2
    for arg in "$@"; do
      printf '%s\n' "$arg"
    done
  }
  bats_mock xml-lint svg-fix file-expand
  bats_disable_worktree_aware
}

# --- Valid SVG ---

@test "returns 0 on a valid SVG" {
  local file="$BATS_TMP_DIR/valid.svg"
  printf '<svg/>\n' > "$file"

  bats_run_zsh "svg-lint $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "returns empty JSON array on a valid SVG with --json" {
  local file="$BATS_TMP_DIR/valid.svg"
  printf '<svg/>\n' > "$file"
  printf '[]\n' > "$BATS_TMP_DIR/xmllint_stdout"

  bats_run_zsh "svg-lint --json $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "[]" ]]
}

# --- Invalid SVG ---

@test "reports violations on an invalid SVG (stylish output)" {
  local file="$BATS_TMP_DIR/bad.svg"
  printf '<svg>\n' > "$file"
  printf 'bad.svg:2:0 error Premature end\n' > "$BATS_TMP_DIR/xmllint_stdout"
  printf '1' > "$BATS_TMP_DIR/xmllint_exit"

  bats_run_zsh "svg-lint $file"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"Premature end"* ]]
}

@test "reports violations on an invalid SVG (--json output)" {
  local file="$BATS_TMP_DIR/bad.svg"
  printf '<svg>\n' > "$file"
  printf '[{"file":"bad.svg","code":"parser-error"}]\n' > "$BATS_TMP_DIR/xmllint_stdout"
  printf '1' > "$BATS_TMP_DIR/xmllint_exit"

  bats_run_zsh "svg-lint --json $file"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"parser-error"* ]]
}

# --- Delegation ---

@test "delegates to xml-lint with --filter is-svg" {
  local file="$BATS_TMP_DIR/valid.svg"
  printf '<svg/>\n' > "$file"

  bats_run_zsh "svg-lint $file"
  [[ "$status" -eq 0 ]]
  local call="$(cat "$BATS_TMP_DIR/xmllint_calls")"
  [[ "$call" == *"--filter is-svg"* ]]
  [[ "$call" == *"$file"* ]]
}

@test "forwards --json to xml-lint" {
  local file="$BATS_TMP_DIR/valid.svg"
  printf '<svg/>\n' > "$file"
  printf '[]\n' > "$BATS_TMP_DIR/xmllint_stdout"

  bats_run_zsh "svg-lint --json $file"
  [[ "$status" -eq 0 ]]
  local call="$(cat "$BATS_TMP_DIR/xmllint_calls")"
  [[ "$call" == *"--json"* ]]
  [[ "$call" == *"--filter is-svg"* ]]
}

# --- Fix mode ---

@test "--fix calls svg-fix first then lints without --fix" {
  local file="$BATS_TMP_DIR/bad.svg"
  printf '<svg>\n' > "$file"
  printf 'violations\n' > "$BATS_TMP_DIR/xmllint_stdout"
  printf '1' > "$BATS_TMP_DIR/xmllint_exit"

  bats_run_zsh "svg-lint --fix $file"
  [[ "$status" -eq 1 ]]

  # svg-fix was called with the expanded file
  [[ -f "$BATS_TMP_DIR/fix_calls" ]]
  [[ "$(cat "$BATS_TMP_DIR/fix_calls")" == *"$file"* ]]

  # xml-lint was called without --fix
  local lintCall="$(cat "$BATS_TMP_DIR/xmllint_calls")"
  [[ "$lintCall" != *"--fix"* ]]
  [[ "$lintCall" == *"--filter is-svg"* ]]
}

# --- Directory expansion ---

@test "expands a directory and lints only .svg files" {
  local dir="$BATS_TMP_DIR/src"
  mkdir -p "$dir"
  printf '<svg/>\n' > "$dir/a.svg"
  printf 'not xml' > "$dir/readme.txt"

  # file-expand with is-svg filter returns only .svg files
  file-expand() {
    printf '%s\n' "$*" >> "$BATS_TMP_DIR/expand_calls"
    printf '%s\n' "$dir/a.svg"
  }
  bats_mock file-expand
  bats_disable_worktree_aware

  bats_run_zsh "svg-lint $dir"
  [[ "$status" -eq 0 ]]

  # file-expand received --filter is-svg
  local expandCall="$(cat "$BATS_TMP_DIR/expand_calls")"
  [[ "$expandCall" == *"--filter is-svg"* ]]

  # xml-lint received the expanded file, not the directory
  local lintCall="$(cat "$BATS_TMP_DIR/xmllint_calls")"
  [[ "$lintCall" == *"a.svg"* ]]
}

# --- Error: no files ---

@test "errors when no files provided" {
  bats_run_zsh "svg-lint"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"No files provided"* ]]
}
