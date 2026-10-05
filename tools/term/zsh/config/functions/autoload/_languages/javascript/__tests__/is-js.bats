bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "exits 0 for a .js file" {
  local file="$BATS_TMP_DIR/foo.js"
  echo "console.log('hi')" > "$file"
  bats_run_zsh "is-js $file"
  [[ "$status" -eq 0 ]]
}

@test "exits 1 for a .zsh file" {
  local file="$BATS_TMP_DIR/foo.zsh"
  echo "echo hello" > "$file"
  bats_run_zsh "is-js $file"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for a .bats file" {
  local file="$BATS_TMP_DIR/foo.bats"
  echo "# bats test" > "$file"
  bats_run_zsh "is-js $file"
  [[ "$status" -eq 1 ]]
}

@test "exits 0 for an extensionless file with node shebang" {
  local file="$BATS_TMP_DIR/my-script"
  printf '#!/usr/bin/env node\nconsole.log("hi")\n' > "$file"
  bats_run_zsh "is-js $file"
  [[ "$status" -eq 0 ]]
}

@test "exits 1 for an extensionless file with zsh shebang" {
  local file="$BATS_TMP_DIR/my-script"
  printf '#!/usr/bin/env zsh\necho hello\n' > "$file"
  bats_run_zsh "is-js $file"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for an extensionless file with no shebang" {
  local file="$BATS_TMP_DIR/my-script"
  echo "echo hello" > "$file"
  bats_run_zsh "is-js $file"
  [[ "$status" -eq 1 ]]
}

@test "exits 0 for a symlink to a .js file" {
  local target="$BATS_TMP_DIR/foo.js"
  local link="$BATS_TMP_DIR/foo-link.js"
  echo "console.log('hi')" > "$target"
  ln -s "$target" "$link"
  bats_run_zsh "is-js $link"
  [[ "$status" -eq 0 ]]
}

@test "exits 1 for a directory path" {
  local dir="$BATS_TMP_DIR/some-dir"
  mkdir -p "$dir"
  bats_run_zsh "is-js $dir"
  [[ "$status" -eq 1 ]]
}

@test "exits 0 for each accepted extension" {
  local ext
  for ext in mjs cjs jsx vue; do
    local file="$BATS_TMP_DIR/foo.$ext"
    echo "x" > "$file"
    bats_run_zsh "is-js $file"
    [[ "$status" -eq 0 ]]
  done
}

@test "exits 1 for .ts and .tsx files" {
  local ext
  for ext in ts tsx; do
    local file="$BATS_TMP_DIR/foo.$ext"
    echo "x" > "$file"
    bats_run_zsh "is-js $file"
    [[ "$status" -eq 1 ]]
  done
}

@test "exits 1 for a missing file" {
  bats_run_zsh "is-js $BATS_TMP_DIR/missing.js"
  [[ "$status" -eq 1 ]]
}


@test "exits 0 for an extensionless file with direct-path node shebang" {
  local file="$BATS_TMP_DIR/my-script"
  printf '#!/usr/bin/node\nconsole.log("hi")\n' > "$file"
  bats_run_zsh "is-js $file"
  [[ "$status" -eq 0 ]]
}

@test "exits 1 for an extensionless file with a nodejs-like but different shebang" {
  local file="$BATS_TMP_DIR/my-script"
  printf '#!/usr/bin/env nodemon\nconsole.log("hi")\n' > "$file"
  bats_run_zsh "is-js $file"
  [[ "$status" -eq 1 ]]
}
