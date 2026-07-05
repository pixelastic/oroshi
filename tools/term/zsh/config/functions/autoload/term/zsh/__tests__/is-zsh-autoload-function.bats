bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "sets REPLY=1 for no-extension file inside functions/autoload/" {
  local dir="$BATS_TMP_DIR/functions/autoload/git/file"
  mkdir -p "$dir"
  local file="$dir/my-func"
  echo "setopt local_options err_return" > "$file"
  bats_run_zsh "is-zsh-autoload-function $file; echo \$REPLY"
  [ "$output" = "1" ]
}

@test "sets REPLY=0 for a .bats file inside functions/autoload/" {
  local dir="$BATS_TMP_DIR/functions/autoload/misc/__tests__"
  mkdir -p "$dir"
  local file="$dir/slugify.bats"
  echo "# bats test" > "$file"
  bats_run_zsh "is-zsh-autoload-function $file; echo \$REPLY"
  [ "$output" = "0" ]
}

@test "sets REPLY=0 for a .zsh file inside functions/autoload/" {
  local dir="$BATS_TMP_DIR/functions/autoload/misc"
  mkdir -p "$dir"
  local file="$dir/helpers.zsh"
  echo "# zsh lib" > "$file"
  bats_run_zsh "is-zsh-autoload-function $file; echo \$REPLY"
  [ "$output" = "0" ]
}

@test "sets REPLY=0 for a no-extension file outside functions/autoload/" {
  local file="$BATS_TMP_DIR/my-script"
  echo "#!/usr/bin/env zsh" > "$file"
  bats_run_zsh "is-zsh-autoload-function $file; echo \$REPLY"
  [ "$output" = "0" ]
}

@test "sets REPLY=0 for a directory inside functions/autoload/" {
  local dir="$BATS_TMP_DIR/functions/autoload/git/file"
  mkdir -p "$dir"
  bats_run_zsh "is-zsh-autoload-function $dir; echo \$REPLY"
  [ "$output" = "0" ]
}
