bats_load_library 'helper'

# Mock xmllint stderr output: tests write to $BATS_TMP_DIR/xmllint_stderr
# Mock exit code: tests write to $BATS_TMP_DIR/xmllint_exit
setup() {
  bats_tmp_dir

  # Default: clean output
  printf '' > "$BATS_TMP_DIR/xmllint_stderr"
  printf '0' > "$BATS_TMP_DIR/xmllint_exit"

  xmllint() {
    cat "$BATS_TMP_DIR/xmllint_stderr" >&2
    return "$(cat "$BATS_TMP_DIR/xmllint_exit")"
  }
  xml-fix() { printf '%s\n' "$*" >> "$BATS_TMP_DIR/fix_calls"; }
  bats_mock xmllint xml-fix
}

# --- Valid XML ---

@test "valid XML: no output, exits 0" {
  local file="$BATS_TMP_DIR/valid.xml"
  printf '<root/>\n' > "$file"

  bats_run_zsh "xml-lint $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "--json with valid XML: outputs [], exits 0" {
  local file="$BATS_TMP_DIR/valid.xml"
  printf '<root/>\n' > "$file"

  bats_run_zsh "xml-lint --json $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "[]" ]]
}

# --- Malformed XML ---

@test "malformed XML: stylish output with violation, exits 1" {
  local file="$BATS_TMP_DIR/bad.xml"
  printf '<root>\n' > "$file"

  printf '%s\n' "$file:2: parser error : Premature end of data in tag root line 1" \
    "" "^" > "$BATS_TMP_DIR/xmllint_stderr"
  printf '3' > "$BATS_TMP_DIR/xmllint_exit"

  bats_run_zsh "xml-lint $file"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"bad.xml"* ]]
  [[ "$output" == *"2:0"* ]]
  [[ "$output" == *"error"* ]]
  [[ "$output" == *"Premature end of data in tag root line 1"* ]]
}

@test "--json with malformed XML: unified JSON with all fields, exits 1" {
  local file="$BATS_TMP_DIR/bad.xml"
  printf '<root>\n' > "$file"

  printf '%s\n' "$file:2: parser error : Premature end of data in tag root line 1" \
    "" "^" > "$BATS_TMP_DIR/xmllint_stderr"
  printf '3' > "$BATS_TMP_DIR/xmllint_exit"

  bats_run_zsh "xml-lint --json $file"
  [[ "$status" -eq 1 ]]
  local item="$(printf '%s' "$output" | jq '.[0]')"
  [[ "$(printf '%s' "$item" | jq -r '.file')" == "$file" ]]
  [[ "$(printf '%s' "$item" | jq -r '.code')" == "parser-error" ]]
  [[ "$(printf '%s' "$item" | jq -r '.level')" == "error" ]]
  [[ "$(printf '%s' "$item" | jq -r '.line')" == "2" ]]
  [[ "$(printf '%s' "$item" | jq -r '.endLine')" == "2" ]]
  [[ "$(printf '%s' "$item" | jq -r '.column')" == "0" ]]
  [[ "$(printf '%s' "$item" | jq -r '.endColumn')" == "0" ]]
  [[ "$(printf '%s' "$item" | jq -r '.message')" == "Premature end of data in tag root line 1" ]]
  [[ "$(printf '%s' "$item" | jq 'keys | length')" == "8" ]]
}

# --- Multiple files ---

@test "mix of valid and malformed: only malformed in output, exits 1" {
  local good="$BATS_TMP_DIR/good.xml"
  local bad="$BATS_TMP_DIR/bad.xml"
  printf '<root/>\n' > "$good"
  printf '<root>\n' > "$bad"

  # xmllint reports errors only for bad.xml
  printf '%s\n' "$bad:2: parser error : Premature end of data in tag root line 1" \
    "" "^" > "$BATS_TMP_DIR/xmllint_stderr"
  printf '3' > "$BATS_TMP_DIR/xmllint_exit"

  bats_run_zsh "xml-lint --json $good $bad"
  [[ "$status" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq 'length')" == "1" ]]
  [[ "$(printf '%s' "$output" | jq -r '.[0].file')" == "$bad" ]]
}

# --- Directory input ---

@test "directory input: expands via file-expand --filter is-xml" {
  local dir="$BATS_TMP_DIR/mydir"
  mkdir -p "$dir"
  printf '<root/>\n' > "$dir/a.xml"

  file-expand() {
    printf '%s\n' "$@" > "$BATS_TMP_DIR/expand_args"
    printf '%s\n' "$dir/a.xml"
  }
  bats_mock file-expand
  bats_disable_worktree_aware

  bats_run_zsh "xml-lint $dir"
  [[ "$status" -eq 0 ]]
  local args="$(cat "$BATS_TMP_DIR/expand_args")"
  [[ "$args" == *"--filter"* ]]
  [[ "$args" == *"is-xml"* ]]
}

# --- Fix flag ---

@test "--fix: calls xml-fix first, then reports remaining violations" {
  local file="$BATS_TMP_DIR/bad.xml"
  printf '<root>\n' > "$file"

  printf '%s\n' "$file:2: parser error : Premature end of data in tag root line 1" \
    "" "^" > "$BATS_TMP_DIR/xmllint_stderr"
  printf '3' > "$BATS_TMP_DIR/xmllint_exit"

  bats_run_zsh "xml-lint --fix $file"
  [[ "$status" -eq 1 ]]
  # xml-fix was called
  [[ -f "$BATS_TMP_DIR/fix_calls" ]]
  [[ "$(cat "$BATS_TMP_DIR/fix_calls")" == *"$file"* ]]
  # Remaining violations reported
  [[ "$output" == *"Premature end of data"* ]]
}

# --- Error: no files provided ---

@test "errors when no files provided" {
  bats_run_zsh "xml-lint"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"No files provided"* ]]
}
