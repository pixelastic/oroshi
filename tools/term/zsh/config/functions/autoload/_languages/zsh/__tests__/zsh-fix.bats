bats_load_library 'helper'

setup() {
  bats_tmp_dir
  FIXTURE_DIRECTORY="$(cd "${BATS_TEST_DIRNAME}" && pwd)"
  UNFORMATTED=$'if true\nthen\necho ok\nfi'
  FORMATTED=$'if true\nthen\n  echo ok\nfi'
}

@test "default: file modified in place, nothing to stdout" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '%s\n' "$UNFORMATTED" > "$file"
  bats_run_zsh "zsh-fix $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  [[ "$(cat "$file")" == "$FORMATTED" ]]
}

@test "default with multiple files: all files formatted in place" {
  local file1="$BATS_TMP_DIR/a.zsh"
  local file2="$BATS_TMP_DIR/b.zsh"
  printf '%s\n' "$UNFORMATTED" > "$file1"
  printf '%s\n' "$UNFORMATTED" > "$file2"
  bats_run_zsh "zsh-fix $file1 $file2"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$file1")" == "$FORMATTED" ]]
  [[ "$(cat "$file2")" == "$FORMATTED" ]]
}

@test "fixture: unformatted input formatted in place to expected output" {
  local file="$BATS_TMP_DIR/fixture.zsh"
  cp "$FIXTURE_DIRECTORY/fixture-unformatted.txt" "$file"
  bats_run_zsh "zsh-fix $file"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$file")" == "$(cat "$FIXTURE_DIRECTORY/fixture-formatted.txt")" ]]
}

@test "--stdout: formatted content to stdout, original file unchanged" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '%s\n' "$UNFORMATTED" > "$file"
  bats_run_zsh "zsh-fix --stdout $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$FORMATTED" ]]
  [[ "$(cat "$file")" == "$UNFORMATTED" ]]
}

@test "--stdout: temp copy removed even when beautysh fails" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'if true; then\n' > "$file"
  mktemp() { echo "$BATS_TMP_DIR/temporary-copy"; }
  bats_mock mktemp
  bats_run_zsh "zsh-fix --stdout $file"
  [[ "$status" -eq 1 ]]
  [[ ! -f "$BATS_TMP_DIR/temporary-copy" ]]
}

@test "--stdout with multiple files: exit 1, files unchanged" {
  local file1="$BATS_TMP_DIR/a.zsh"
  local file2="$BATS_TMP_DIR/b.zsh"
  printf '%s\n' "$UNFORMATTED" > "$file1"
  printf '%s\n' "$UNFORMATTED" > "$file2"
  bats_run_zsh "zsh-fix --stdout $file1 $file2"
  [[ "$status" -eq 1 ]]
  [[ "$(cat "$file1")" == "$UNFORMATTED" ]]
  [[ "$(cat "$file2")" == "$UNFORMATTED" ]]
}

@test "--stdout with a directory: exit 1" {
  local dir="$BATS_TMP_DIR/src"
  mkdir -p "$dir"
  printf '%s\n' "$UNFORMATTED" > "$dir/a.zsh"
  bats_run_zsh "zsh-fix --stdout $dir"
  [[ "$status" -eq 1 ]]
  [[ "$(cat "$dir/a.zsh")" == "$UNFORMATTED" ]]
}

@test "--original-path: temp file formatted in place" {
  local realPath="$BATS_TMP_DIR/real.zsh"
  local file="$BATS_TMP_DIR/tmp.zsh"
  printf '%s\n' "$UNFORMATTED" > "$realPath"
  printf '%s\n' "$UNFORMATTED" > "$file"
  bats_run_zsh "zsh-fix --original-path $realPath $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  [[ "$(cat "$file")" == "$FORMATTED" ]]
  [[ "$(cat "$realPath")" == "$UNFORMATTED" ]]
}

@test "--original-path with --stdout: formatted content to stdout" {
  local realPath="$BATS_TMP_DIR/real.zsh"
  local file="$BATS_TMP_DIR/tmp.zsh"
  printf '%s\n' "$UNFORMATTED" > "$realPath"
  printf '%s\n' "$UNFORMATTED" > "$file"
  bats_run_zsh "zsh-fix --original-path $realPath --stdout $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$FORMATTED" ]]
  [[ "$(cat "$file")" == "$UNFORMATTED" ]]
}

@test "--original-path with multiple files: exit 1" {
  local file1="$BATS_TMP_DIR/a.zsh"
  local file2="$BATS_TMP_DIR/b.zsh"
  printf '%s\n' "$UNFORMATTED" > "$file1"
  printf '%s\n' "$UNFORMATTED" > "$file2"
  bats_run_zsh "zsh-fix --original-path $file1 $file1 $file2"
  [[ "$status" -eq 1 ]]
  [[ "$(cat "$file2")" == "$UNFORMATTED" ]]
}

@test "--original-path: ZSH detected from real path when temp name hides it" {
  # conform.nvim temp copies of autoload functions look like .conform.123.my-func
  local dir="$BATS_TMP_DIR/functions/autoload/misc"
  mkdir -p "$dir"
  local realPath="$dir/my-func"
  local file="$dir/.conform.123.my-func"
  printf '%s\n' "$UNFORMATTED" > "$realPath"
  printf '%s\n' "$UNFORMATTED" > "$file"
  bats_run_zsh "zsh-fix --original-path $realPath $file"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$file")" == "$FORMATTED" ]]
}

@test "directory: ZSH files formatted recursively, others skipped" {
  local dir="$BATS_TMP_DIR/src"
  mkdir -p "$dir/nested"
  printf '%s\n' "$UNFORMATTED" > "$dir/a.zsh"
  printf '%s\n' "$UNFORMATTED" > "$dir/nested/b.zsh"
  printf '%s\n' "$UNFORMATTED" > "$dir/notes.txt"
  bats_run_zsh "zsh-fix $dir"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  [[ "$(cat "$dir/a.zsh")" == "$FORMATTED" ]]
  [[ "$(cat "$dir/nested/b.zsh")" == "$FORMATTED" ]]
  [[ "$(cat "$dir/notes.txt")" == "$UNFORMATTED" ]]
}

@test "non-ZSH file: silently skipped, file unchanged" {
  local file="$BATS_TMP_DIR/notes.txt"
  printf '%s\n' "$UNFORMATTED" > "$file"
  bats_run_zsh "zsh-fix $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  [[ "$(cat "$file")" == "$UNFORMATTED" ]]
}
