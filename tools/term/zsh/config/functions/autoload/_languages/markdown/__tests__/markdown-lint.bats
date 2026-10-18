bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# --- Stylish output (default) ---

@test "clean file: no output, exits 0" {
  local file="$BATS_TMP_DIR/clean.md"
  printf '# Title\n\nSome text.\n' > "$file"

  bats_run_zsh "markdown-lint $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "file with violation: prints line, column, rule and message, exits 1" {
  local file="$BATS_TMP_DIR/bad.md"
  printf '# Title\n\n### Skipped\n' > "$file"

  bats_run_zsh "cd $BATS_TMP_DIR && markdown-lint bad.md"
  [[ "$status" -eq 1 ]]
  [[ "${lines[0]}" == "bad.md" ]]
  [[ "${lines[1]}" == *"3:1"* ]]
  [[ "${lines[1]}" == *"error"* ]]
  [[ "${lines[1]}" == *"Heading levels should only increment by one level at a time"* ]]
  [[ "${lines[1]}" == *"MD001/heading-increment"* ]]
}

# --- JSON output (--json) ---

@test "--json on clean file: outputs [], exits 0" {
  local file="$BATS_TMP_DIR/clean.md"
  printf '# Title\n\nSome text.\n' > "$file"

  bats_run_zsh "markdown-lint --json $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "[]" ]]
}

@test "--json on file with violations: array of unified objects, exits 1" {
  local file="$BATS_TMP_DIR/bad.md"
  printf '# Title\n\n### Skipped\n' > "$file"

  bats_run_zsh "markdown-lint --json $file"
  [[ "$status" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq 'length')" == "1" ]]
  local item="$(printf '%s' "$output" | jq '.[0]')"
  [[ "$(printf '%s' "$item" | jq -r '.file')" == "$file" ]]
  [[ "$(printf '%s' "$item" | jq -r '.code')" == "MD001/heading-increment" ]]
  [[ "$(printf '%s' "$item" | jq -r '.level')" == "error" ]]
  [[ "$(printf '%s' "$item" | jq -r '.line')" == "3" ]]
  [[ "$(printf '%s' "$item" | jq -r '.endLine')" == "3" ]]
  [[ "$(printf '%s' "$item" | jq -r '.column')" == "1" ]]
  [[ "$(printf '%s' "$item" | jq -r '.endColumn')" == "1" ]]
  [[ "$(printf '%s' "$item" | jq -r '.message')" == *"Heading levels should only increment by one level at a time"* ]]
}

# --- Rules handled by Prettier ---

@test "does not report line length violations" {
  local file="$BATS_TMP_DIR/long.md"
  local sentence="The quick brown fox jumps over the lazy dog and keeps running through the forest."
  printf '# Title\n\n%s %s %s\n' "$sentence" "$sentence" "$sentence" > "$file"

  bats_run_zsh "markdown-lint $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "does not report list style violations" {
  local file="$BATS_TMP_DIR/lists.md"
  printf '# Title\n\nIntro:\n* one\n    * nested\n+ two\n\n1.  first\n2.  second\n' > "$file"

  bats_run_zsh "markdown-lint $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "--fix leaves no violation on a fenced block inside a tight list" {
  local file="$BATS_TMP_DIR/fence.md"
  printf '# Title\n\n1. Run:\n   ```sh\n   echo hi\n   ```\n2. Done\n' > "$file"

  bats_run_zsh "markdown-lint --fix $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

# --- Fix mode ---

@test "--fix formats the file then reports only remaining violations" {
  local file="$BATS_TMP_DIR/messy.md"
  local sentence="The quick brown fox jumps over the lazy dog and keeps running through the forest."
  printf '# Title\n\n%s %s %s\n\n### Skipped\n' "$sentence" "$sentence" "$sentence" > "$file"

  bats_run_zsh "markdown-lint --fix --json $file"
  [[ "$status" -eq 1 ]]
  # Prettier wrapped the long paragraph
  [[ "$(wc -l < "$file")" -gt 6 ]]
  # Only the heading violation remains
  [[ "$(printf '%s' "$output" | jq 'length')" == "1" ]]
  [[ "$(printf '%s' "$output" | jq -r '.[0].code')" == "MD001/heading-increment" ]]
}

# --- Config ---

@test "a project-local config takes precedence" {
  local project="$BATS_TMP_DIR/project"
  mkdir -p "$project"
  printf '# Title\n\n### Skipped\n' > "$project/bad.md"
  printf '{"config":{"MD001":false}}' > "$project/.markdownlint-cli2.jsonc"

  bats_run_zsh "markdown-lint $project/bad.md"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

# --- Argument handling ---

@test "directory argument lints every .md file and skips other files" {
  local dir="$BATS_TMP_DIR/src"
  mkdir -p "$dir"
  printf '# Title\n\n### Skipped\n' > "$dir/a.md"
  printf '# Title\n\n### Skipped\n' > "$dir/b.md"
  printf '# Title\n\n### Skipped\n' > "$dir/notes.txt"

  bats_run_zsh "markdown-lint --json $dir"
  [[ "$status" -eq 1 ]]
  local files="$(printf '%s' "$output" | jq -r '.[].file' | sort)"
  [[ "$files" == "$dir/a.md"$'\n'"$dir/b.md" ]]
}

@test "directory without .md files: exits 0 with no output" {
  local dir="$BATS_TMP_DIR/src"
  mkdir -p "$dir"
  echo 'hello' > "$dir/notes.txt"

  bats_run_zsh "markdown-lint $dir"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "no files provided: errors with exit 1" {
  bats_run_zsh "markdown-lint"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"No files provided"* ]]
}
