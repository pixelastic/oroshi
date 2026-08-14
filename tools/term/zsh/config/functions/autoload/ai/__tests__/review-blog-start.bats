bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Default mock: md2gdoc returns a Google Docs URL
  md2gdoc() { echo "https://docs.google.com/document/d/mock123/edit"; }
  bats_mock md2gdoc
}

# --- File path detection ---

@test "file path calls md2gdoc and returns its URL" {
  echo "# Article" > "$BATS_TMP_DIR/article.md"

  md2gdoc() {
    echo "$@" > "$BATS_TMP_DIR/md2gdoc-args.txt"
    echo "https://docs.google.com/document/d/abc/edit"
  }
  bats_mock md2gdoc

  bats_run_zsh "review-blog-start $BATS_TMP_DIR/article.md"
  [[ "$status" -eq 0 ]]
  # Passes --no-open and the file path
  [[ "$(cat "$BATS_TMP_DIR/md2gdoc-args.txt")" == "--no-open $BATS_TMP_DIR/article.md" ]]
  expect_json '.url' 'https://docs.google.com/document/d/abc/edit'
}

# --- URL detection ---

@test "Google Docs URL passes through unchanged" {
  local url="https://docs.google.com/document/d/xyz789/edit"

  bats_run_zsh "review-blog-start $url"
  [[ "$status" -eq 0 ]]
  expect_json '.url' "$url"
}

# --- JSON output ---

@test "output is valid JSON with url field" {
  echo "# Test" > "$BATS_TMP_DIR/test.md"

  bats_run_zsh "review-blog-start $BATS_TMP_DIR/test.md"
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.url' > /dev/null
}

# --- Missing file ---

@test "non-existent file path exits with error" {
  bats_run_zsh "review-blog-start /nonexistent/file.md"
  [[ "$status" -ne 0 ]]
}
