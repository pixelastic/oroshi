bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$OROSHI_ZSH_AUTOLOAD/term/js/is-js"
}

teardown() {
  bats_cleanup
}

@test "exits 0 for a .js file" {
  local file="$BATS_TMP_DIR/foo.js"
  echo "console.log('hi')" > "$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$status" -eq 0 ]]
}

@test "exits 1 for a .zsh file" {
  local file="$BATS_TMP_DIR/foo.zsh"
  echo "echo hello" > "$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for a .bats file" {
  local file="$BATS_TMP_DIR/foo.bats"
  echo "# bats test" > "$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$status" -eq 1 ]]
}

@test "exits 0 for an extensionless file with node shebang" {
  local file="$BATS_TMP_DIR/my-script"
  printf '#!/usr/bin/env node\nconsole.log("hi")\n' > "$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$status" -eq 0 ]]
}

@test "exits 1 for an extensionless file with zsh shebang" {
  local file="$BATS_TMP_DIR/my-script"
  printf '#!/usr/bin/env zsh\necho hello\n' > "$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for an extensionless file with no shebang" {
  local file="$BATS_TMP_DIR/my-script"
  echo "echo hello" > "$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for a symlink to a .js file" {
  local target="$BATS_TMP_DIR/foo.js"
  local link="$BATS_TMP_DIR/foo-link.js"
  echo "console.log('hi')" > "$target"
  ln -s "$target" "$link"
  bats_run_zsh "$CURRENT" "$link"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for a directory path" {
  local dir="$BATS_TMP_DIR/some-dir"
  mkdir -p "$dir"
  bats_run_zsh "$CURRENT" "$dir"
  [[ "$status" -eq 1 ]]
}
