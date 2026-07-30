bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Default mock: md2gdocs returns a Google Docs URL
  md2gdocs() { echo "https://docs.google.com/document/d/mock123/edit"; }
  bats_mock md2gdocs
}

# --- File path detection ---

@test "file path calls md2gdocs and returns its URL" {
  echo "# Article" > "$BATS_TMP_DIR/article.md"

  md2gdocs() {
    echo "$@" > "$BATS_TMP_DIR/md2gdocs-args.txt"
    echo "https://docs.google.com/document/d/abc/edit"
  }
  bats_mock md2gdocs

  bats_run_zsh "review-article-start $BATS_TMP_DIR/article.md"
  [[ "$status" -eq 0 ]]
  # Passes --no-open and the file path
  [[ "$(cat "$BATS_TMP_DIR/md2gdocs-args.txt")" == "--no-open $BATS_TMP_DIR/article.md" ]]
  expect_json '.url' 'https://docs.google.com/document/d/abc/edit'
}

# --- URL detection ---

@test "Google Docs URL passes through unchanged" {
  local url="https://docs.google.com/document/d/xyz789/edit"

  bats_run_zsh "review-article-start $url"
  [[ "$status" -eq 0 ]]
  expect_json '.url' "$url"
}

# --- JSON output ---

@test "output is valid JSON with url field" {
  echo "# Test" > "$BATS_TMP_DIR/test.md"

  bats_run_zsh "review-article-start $BATS_TMP_DIR/test.md"
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.url' > /dev/null
}

# --- Missing file ---

@test "non-existent file path exits with error" {
  bats_run_zsh "review-article-start /nonexistent/file.md"
  [[ "$status" -ne 0 ]]
}
