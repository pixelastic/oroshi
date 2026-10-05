bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "rewrites a badly formatted file in place" {
  local file="$BATS_TMP_DIR/messy.js"
  printf 'const   a   =   {b:1}\nexport {a}\n' > "$file"

  bats_run_zsh "js-fix $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  [[ "$(cat "$file")" == $'const a = { b: 1 };\nexport { a };' ]]
}

@test "fixes eslint-fixable violations and leaves well-formatted output" {
  local file="$BATS_TMP_DIR/template.js"
  printf 'const a = `x`;\nexport { a };\n' > "$file"

  bats_run_zsh "js-fix $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  [[ "$(cat "$file")" == $'const a = \'x\';\nexport { a };' ]]
}

@test "accepts several files and fixes each" {
  local file1="$BATS_TMP_DIR/a.js"
  local file2="$BATS_TMP_DIR/b.js"
  printf 'const   a   =   1\nexport {a}\n' > "$file1"
  printf 'const   b   =   2\nexport {b}\n' > "$file2"

  bats_run_zsh "js-fix $file1 $file2"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$file1")" == $'const a = 1;\nexport { a };' ]]
  [[ "$(cat "$file2")" == $'const b = 2;\nexport { b };' ]]
}

@test "expands a directory and skips non-JS files" {
  local dir="$BATS_TMP_DIR/src"
  mkdir -p "$dir"
  printf 'const   a   =   1\nexport {a}\n' > "$dir/a.js"
  printf 'const   b   =   2\n' > "$dir/notes.txt"

  bats_run_zsh "js-fix $dir"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  [[ "$(cat "$dir/a.js")" == $'const a = 1;\nexport { a };' ]]
  [[ "$(cat "$dir/notes.txt")" == "const   b   =   2" ]]
}

@test "--stdout prints the fixed code and leaves the file untouched" {
  local file="$BATS_TMP_DIR/messy.js"
  printf 'const   a   =   {b:1}\nexport {a}\n' > "$file"

  bats_run_zsh "js-fix --stdout $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == $'const a = { b: 1 };\nexport { a };' ]]
  [[ "$(cat "$file")" == $'const   a   =   {b:1}\nexport {a}' ]]
}

@test "--original-path resolves config from the real path" {
  local project="$BATS_TMP_DIR/project"
  mkdir -p "$project"
  # Project-local prettier config: 4 spaces indentation
  printf 'export default { tabWidth: 4 };\n' > "$project/prettier.config.js"
  printf '{"name":"project"}\n' > "$project/package.json"
  local realPath="$project/real.js"
  local scratchFile="$BATS_TMP_DIR/scratch.js"
  printf 'export function f() {\nreturn 1\n}\n' > "$scratchFile"

  bats_run_zsh "js-fix --stdout --original-path $realPath $scratchFile"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *$'\n    return 1;'* ]]
}

@test "--stdout with several files exits 1" {
  local file1="$BATS_TMP_DIR/a.js"
  local file2="$BATS_TMP_DIR/b.js"
  printf 'const a = 1;\n' > "$file1"
  printf 'const b = 2;\n' > "$file2"

  bats_run_zsh "js-fix --stdout $file1 $file2"
  [[ "$status" -eq 1 ]]
}

@test "--stdout with a directory exits 1" {
  local dir="$BATS_TMP_DIR/src"
  mkdir -p "$dir"
  printf 'const a = 1;\n' > "$dir/a.js"

  bats_run_zsh "js-fix --stdout $dir"
  [[ "$status" -eq 1 ]]
}

@test "--original-path with several files exits 1" {
  local file1="$BATS_TMP_DIR/a.js"
  local file2="$BATS_TMP_DIR/b.js"
  printf 'const a = 1;\n' > "$file1"
  printf 'const b = 2;\n' > "$file2"

  bats_run_zsh "js-fix --original-path /some/path.js $file1 $file2"
  [[ "$status" -eq 1 ]]
}

@test "--original-path with a directory exits 1" {
  local dir="$BATS_TMP_DIR/src"
  mkdir -p "$dir"
  printf 'const a = 1;\n' > "$dir/a.js"

  bats_run_zsh "js-fix --original-path /some/path.js $dir"
  [[ "$status" -eq 1 ]]
}

@test "exits 0 when no JS file is given" {
  local file="$BATS_TMP_DIR/notes.txt"
  printf 'hello\n' > "$file"

  bats_run_zsh "js-fix $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]

  bats_run_zsh "js-fix"
  [[ "$status" -eq 0 ]]
}

@test "exits 0 and prints nothing when violations remain that eslint cannot fix" {
  local file="$BATS_TMP_DIR/unfixable.js"
  printf 'export const same = (a, b) => a == b;\n' > "$file"

  bats_run_zsh "js-fix $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "--stdout prints only the fixed code when violations remain that eslint cannot fix" {
  local file="$BATS_TMP_DIR/unfixable.js"
  printf 'export const same = (a, b) => a == b;\n' > "$file"

  bats_run_zsh "js-fix --stdout $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == 'export const same = (a, b) => a == b;' ]]
}

@test "--stdout leaves no temporary file next to the original" {
  local file="$BATS_TMP_DIR/messy.js"
  printf 'const   a   =   1\nexport {a}\n' > "$file"

  bats_run_zsh "js-fix --stdout $file"
  [[ "$status" -eq 0 ]]
  local leftovers=("$BATS_TMP_DIR"/.js-fix-*)
  [[ ! -e "${leftovers[0]}" ]]
}
