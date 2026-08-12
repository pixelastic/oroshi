bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "prepends zero-padded index to files" {
  touch "$BATS_TMP_DIR/alpha.jpg" "$BATS_TMP_DIR/beta.png" "$BATS_TMP_DIR/gamma.txt"

  bats_run_zsh "cd $BATS_TMP_DIR && rename-prefix-number alpha.jpg beta.png gamma.txt"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/01 - Alpha.jpg" ]]
  [[ -f "$BATS_TMP_DIR/02 - Beta.png" ]]
  [[ -f "$BATS_TMP_DIR/03 - Gamma.txt" ]]
}

@test "pads index based on file count" {
  # 100+ files → 3-digit padding
  for i in $(seq 1 101); do
    touch "$BATS_TMP_DIR/file${i}.txt"
  done

  local args=""
  for i in $(seq 1 101); do
    args+="file${i}.txt "
  done

  bats_run_zsh "cd $BATS_TMP_DIR && rename-prefix-number $args"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/001 - File1.txt" ]]
  [[ -f "$BATS_TMP_DIR/101 - File101.txt" ]]
}

@test "capitalizes first letter of filename" {
  touch "$BATS_TMP_DIR/hello.txt"

  bats_run_zsh "cd $BATS_TMP_DIR && rename-prefix-number hello.txt"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/01 - Hello.txt" ]]
}
