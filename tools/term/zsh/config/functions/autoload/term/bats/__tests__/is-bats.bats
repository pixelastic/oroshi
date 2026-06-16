bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

@test "exits 0 for a .bats file" {
  local file="$BATS_TMP_DIR/foo.bats"
  echo "# bats test" > "$file"
  bats_run_zsh "is-bats $file"
  [[ "$status" -eq 0 ]]
}

@test "exits 1 for a .zsh file" {
  local file="$BATS_TMP_DIR/foo.zsh"
  echo "echo hello" > "$file"
  bats_run_zsh "is-bats $file"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for a .js file" {
  local file="$BATS_TMP_DIR/foo.js"
  echo "console.log('hi')" > "$file"
  bats_run_zsh "is-bats $file"
  [[ "$status" -eq 1 ]]
}

@test "exits 0 for an extensionless file with ft=bats modeline on line 1" {
  local file="$BATS_TMP_DIR/my-helper"
  printf '# vim: set ft=bats:\n# content\n' > "$file"
  bats_run_zsh "is-bats $file"
  [[ "$status" -eq 0 ]]
}

@test "exits 1 for an extensionless file with ft=bash modeline on line 1" {
  local file="$BATS_TMP_DIR/my-helper"
  printf '# vim: set ft=bash:\n# content\n' > "$file"
  bats_run_zsh "is-bats $file"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for an extensionless file with no modeline" {
  local file="$BATS_TMP_DIR/my-helper"
  echo "echo hello" > "$file"
  bats_run_zsh "is-bats $file"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for a symlink to a .bats file" {
  local target="$BATS_TMP_DIR/foo.bats"
  local link="$BATS_TMP_DIR/foo-link.bats"
  echo "# bats test" > "$target"
  ln -s "$target" "$link"
  bats_run_zsh "is-bats $link"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for a directory path" {
  local dir="$BATS_TMP_DIR/some-dir"
  mkdir -p "$dir"
  bats_run_zsh "is-bats $dir"
  [[ "$status" -eq 1 ]]
}
