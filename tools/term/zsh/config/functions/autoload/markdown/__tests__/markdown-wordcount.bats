bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "counts the words of plain paragraphs" {
  local file="$BATS_TMP_DIR/plain.md"
  printf 'One two three.\n\nFour five.\n' > "$file"
  bats_run_zsh "markdown-wordcount $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '5' ]]
}

@test "ignores the front matter block" {
  local file="$BATS_TMP_DIR/front.md"
  printf -- '---\ntitle: A long title here\ntags: one two\n---\nOne two three.\n' > "$file"
  bats_run_zsh "markdown-wordcount $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '3' ]]
}

@test "ignores fenced code blocks, whatever their language tag" {
  local file="$BATS_TMP_DIR/code.md"
  printf 'One two.\n\n```js\nconst a = 1;\nconst b = 2;\n```\n\nThree.\n\n```\nplain code here\n```\n\n```zsh\necho hello world\n```\n\nFour.\n' > "$file"
  bats_run_zsh "markdown-wordcount $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '4' ]]
}

@test "counts inline code words" {
  local file="$BATS_TMP_DIR/inline.md"
  printf 'Run `git status now` before you push.\n' > "$file"
  bats_run_zsh "markdown-wordcount $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '7' ]]
}

@test "prints zero for an empty file" {
  local file="$BATS_TMP_DIR/empty.md"
  : > "$file"
  bats_run_zsh "markdown-wordcount $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '0' ]]
}

@test "prints zero for a file that only holds front matter and code" {
  local file="$BATS_TMP_DIR/only-meta.md"
  printf -- '---\ntitle: Hello there\n---\n```js\nconst a = 1;\n```\n' > "$file"
  bats_run_zsh "markdown-wordcount $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '0' ]]
}

@test "fails with a usage message when no argument is given" {
  bats_run_zsh "markdown-wordcount"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Usage"* ]]
}

@test "fails when the file does not exist" {
  bats_run_zsh "markdown-wordcount $BATS_TMP_DIR/missing.md"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Usage"* ]]
}
