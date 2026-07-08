bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "file argument: formatted content to stdout, original file unchanged" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# clean file\n' > "$file"
  bats_run_zsh "zsh-fix $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "# clean file" ]]
  [[ "$(cat "$file")" == "# clean file" ]]
}

@test "--in-place: file modified in place, nothing to stdout" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# clean file\n' > "$file"
  bats_run_zsh "zsh-fix --in-place $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  [[ "$(cat "$file")" == "# clean file" ]]
}

@test "stdin: formatted content to stdout" {
  bats_run_zsh "printf '# clean file\n' | zsh-fix"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "# clean file" ]]
}

@test "shfmt failure: beautysh is called as fallback" {
  shfmt() { return 1; }
  bats_mock shfmt
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# test\n' > "$file"
  bats_run_zsh "zsh-fix $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" != "" ]]
}

@test "shfmt success: beautysh not called" {
  beautysh() { printf 'called\n' >"$BATS_TMP_DIR/beautysh_called"; }
  bats_mock beautysh
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# test\n' > "$file"
  bats_run_zsh "zsh-fix $file"
  [[ ! -f "$BATS_TMP_DIR/beautysh_called" ]]
}
