bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "wraps a long paragraph at 80 columns" {
  local file="$BATS_TMP_DIR/test.md"
  local sentence="The quick brown fox jumps over the lazy dog and keeps running through the forest."
  echo "$sentence $sentence $sentence" > "$file"

  bats_run_zsh "markdown-fix $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]

  local longestLine="$(awk '{ if (length($0) > max) max = length($0) } END { print max }' "$file")"
  [[ "$longestLine" -le 80 ]]
  [[ "$(wc -l < "$file")" -gt 1 ]]
}

@test "leaves front matter unchanged" {
  local file="$BATS_TMP_DIR/test.md"
  printf -- '---\ntitle: "A very long title that should never be wrapped by the formatter at all"\ntags: [a,   b]\n---\n\n# Hello\n' > "$file"
  local expected="$(head -n 4 "$file")"

  bats_run_zsh "markdown-fix $file"
  [[ "$status" -eq 0 ]]
  [[ "$(head -n 4 "$file")" == "$expected" ]]
}

@test "leaves code fences and inline code unchanged" {
  local file="$BATS_TMP_DIR/test.md"
  local fence='const veryLongLine = "this line of code is much longer than eighty columns and must stay on one line";'
  local inline='`some-very-long-inline-code-span --with --many --flags --that --should --not --be --broken`'
  printf '```js\n%s\n```\n\nBefore %s after.\n' "$fence" "$inline" > "$file"

  bats_run_zsh "markdown-fix $file"
  [[ "$status" -eq 0 ]]
  grep --fixed-strings --line-regexp --quiet "$fence" "$file"
  grep --fixed-strings --quiet "$inline" "$file"
}

@test "keeps tables as tables" {
  local file="$BATS_TMP_DIR/test.md"
  printf '| Name | Description |\n|---|---|\n| foo | A fairly long description that goes on and on and on past the eighty column limit |\n' > "$file"

  bats_run_zsh "markdown-fix $file"
  [[ "$status" -eq 0 ]]
  [[ "$(wc -l < "$file")" -eq 3 ]]
  [[ "$(grep --count '^|' "$file")" -eq 3 ]]
}

@test "does not break a long image link" {
  local file="$BATS_TMP_DIR/test.md"
  local image='![An image with alt text](https://example.com/a/very/long/path/to/an/image/that/is/way/longer/than/eighty/columns.png)'
  printf 'Some text before the image %s and some text after it.\n' "$image" > "$file"

  bats_run_zsh "markdown-fix $file"
  [[ "$status" -eq 0 ]]
  grep --fixed-strings --quiet "(https://example.com/a/very/long/path/to/an/image/that/is/way/longer/than/eighty/columns.png)" "$file"
}

@test "changes whitespace only, never the words" {
  local file="$BATS_TMP_DIR/test.md"
  local sentence="The quick brown fox jumps over the lazy dog and keeps running through the forest."
  echo "$sentence $sentence $sentence" > "$file"
  local before="$(tr --squeeze-repeats '[:space:]' '\n' < "$file")"

  bats_run_zsh "markdown-fix $file"
  [[ "$status" -eq 0 ]]
  local after="$(tr --squeeze-repeats '[:space:]' '\n' < "$file")"
  [[ "$before" == "$after" ]]
}

@test "--stdout prints fixed content without modifying original" {
  local file="$BATS_TMP_DIR/test.md"
  local sentence="The quick brown fox jumps over the lazy dog and keeps running through the forest."
  echo "$sentence $sentence $sentence" > "$file"
  local original="$(cat "$file")"

  bats_run_zsh "markdown-fix --stdout $file"
  [[ "$status" -eq 0 ]]
  [[ "$(echo "$output" | wc -l)" -gt 1 ]]
  [[ "$(cat "$file")" == "$original" ]]
}

@test "--stdout with multiple files exits 1" {
  local file1="$BATS_TMP_DIR/a.md"
  local file2="$BATS_TMP_DIR/b.md"
  echo '# A' > "$file1"
  echo '# B' > "$file2"

  bats_run_zsh "markdown-fix --stdout $file1 $file2"
  [[ "$status" -eq 1 ]]
}

@test "--stdout with a directory exits 1" {
  local directory="$BATS_TMP_DIR/src"
  mkdir -p "$directory"
  echo '# A' > "$directory/a.md"

  bats_run_zsh "markdown-fix --stdout $directory"
  [[ "$status" -eq 1 ]]
}

@test "formats every .md file of a directory" {
  local directory="$BATS_TMP_DIR/src"
  mkdir -p "$directory/nested"
  local sentence="The quick brown fox jumps over the lazy dog and keeps running through the forest."
  echo "$sentence $sentence" > "$directory/a.md"
  echo "$sentence $sentence" > "$directory/nested/b.md"

  bats_run_zsh "markdown-fix $directory"
  [[ "$status" -eq 0 ]]
  [[ "$(wc -l < "$directory/a.md")" -gt 1 ]]
  [[ "$(wc -l < "$directory/nested/b.md")" -gt 1 ]]
}

@test "skips non-Markdown files silently" {
  local directory="$BATS_TMP_DIR/src"
  mkdir -p "$directory"
  echo '# A' > "$directory/a.md"
  local text='some   text    with   odd   spacing'
  echo "$text" > "$directory/notes.txt"

  bats_run_zsh "markdown-fix $directory"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  [[ "$(cat "$directory/notes.txt")" == "$text" ]]
}

@test "--original-path resolves the config from the real path" {
  local file="$BATS_TMP_DIR/tmp-copy.md"
  echo '# Title' > "$file"

  # The real path lives in a project with its own prettier config
  local project="$BATS_TMP_DIR/project"
  mkdir -p "$project/docs"
  echo '{}' > "$project/package.json"
  echo 'export default {};' > "$project/prettier.config.js"

  # Record the prettier call instead of running the real binary
  prettier() { echo "$*" > "$BATS_TMP_DIR/prettier-args"; }
  bats_mock prettier
  bats_disable_worktree_aware

  bats_run_zsh "markdown-fix --original-path $project/docs/README.md $file"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/prettier-args")" == *"--config $project/prettier.config.js"* ]]
}
