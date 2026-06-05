bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/term/zsh/is-zsh"
}

teardown() {
  bats_cleanup
}

@test "exits 0 for a .zsh file" {
  local file="$BATS_TMP_DIR/foo.zsh"
  echo "echo hello" > "$file"
  bats_run_zsh "$CURRENT" "$file"
  [ "$status" -eq 0 ]
}

@test "exits 0 for a no-extension file inside functions/autoload/" {
  local dir="$BATS_TMP_DIR/functions/autoload/git/file"
  mkdir -p "$dir"
  local file="$dir/my-func"
  echo "echo hello" > "$file"
  bats_run_zsh "$CURRENT" "$file"
  [ "$status" -eq 0 ]
}

@test "exits 0 for a no-extension file with zsh shebang" {
  local file="$BATS_TMP_DIR/my-script"
  printf '#!/usr/bin/env zsh\necho hello\n' > "$file"
  bats_run_zsh "$CURRENT" "$file"
  [ "$status" -eq 0 ]
}

@test "exits 1 for a no-extension file with ruby shebang" {
  local file="$BATS_TMP_DIR/my-script"
  printf '#!/usr/bin/env ruby\nputs "hello"\n' > "$file"
  bats_run_zsh "$CURRENT" "$file"
  [ "$status" -eq 1 ]
}

@test "exits 1 for a no-extension file with no shebang" {
  local file="$BATS_TMP_DIR/my-script"
  echo "echo hello" > "$file"
  bats_run_zsh "$CURRENT" "$file"
  [ "$status" -eq 1 ]
}

@test "exits 1 for a directory path" {
  local dir="$BATS_TMP_DIR/functions/autoload/git/file"
  mkdir -p "$dir"
  bats_run_zsh "$CURRENT" "$dir"
  [ "$status" -eq 1 ]
}

@test "exits 1 for a symlink to a .zsh file" {
  local target="$BATS_TMP_DIR/foo.zsh"
  local link="$BATS_TMP_DIR/foo-link.zsh"
  echo "echo hello" > "$target"
  ln -s "$target" "$link"
  bats_run_zsh "$CURRENT" "$link"
  [ "$status" -eq 1 ]
}

@test "exits 1 for a .bats file inside functions/autoload/" {
  local dir="$BATS_TMP_DIR/functions/autoload/misc/__tests__"
  mkdir -p "$dir"
  local file="$dir/slugify.bats"
  echo "# bats test" > "$file"
  bats_run_zsh "$CURRENT" "$file"
  [ "$status" -eq 1 ]
}
