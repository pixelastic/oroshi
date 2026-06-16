bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

@test "no argument: exits with error" {
  bats_run_zsh "sidequest-end"
  [ "$status" -eq 1 ]
}

@test "file does not exist: exits with error" {
  bats_run_zsh "sidequest-end $BATS_TMP_DIR/nonexistent.md"
  [ "$status" -eq 1 ]
}

@test "valid file: calls sidequest with slug, --prompt @<filepath>, --no-focus" {
  file="$BATS_TMP_DIR/fix-ralph.md"
  touch "$file"
  sidequest() { echo "SIDEQUEST:$*"; }
  bats_mock sidequest

  bats_run_zsh "sidequest-end $file"

  [ "$status" -eq 0 ]
  [[ "$output" == "SIDEQUEST:fix-ralph --prompt @${file} --no-focus" ]]
}
