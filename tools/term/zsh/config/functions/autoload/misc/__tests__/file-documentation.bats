bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# Blocks
@test "prints the leading comment block without comment prefixes" {
  printf '# Title\n#\n# Details\n# Usage:\n# $ thing arg\necho body\n' > "$BATS_TMP_DIR/fixture"
  bats_run_zsh "file-documentation $BATS_TMP_DIR/fixture"
  [[ "$status" -eq 0 ]]
  [[ "$output" == $'Title\n\nDetails\nUsage:\n$ thing arg' ]]
}

@test "skips the shebang and the autoload line" {
  printf '#!/usr/bin/env zsh\n#autoload\n# Title\necho body\n' > "$BATS_TMP_DIR/fixture"
  bats_run_zsh "file-documentation $BATS_TMP_DIR/fixture"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "Title" ]]
}

@test "skips empty and bare comment lines before the block" {
  printf '#\n\n# Title\n' > "$BATS_TMP_DIR/fixture"
  bats_run_zsh "file-documentation $BATS_TMP_DIR/fixture"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "Title" ]]
}

@test "stops at the first non-comment line" {
  printf '# Title\necho body\n# Not header\n' > "$BATS_TMP_DIR/fixture"
  bats_run_zsh "file-documentation $BATS_TMP_DIR/fixture"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "Title" ]]
}

@test "prints nothing for a file without header" {
  printf 'echo body\n' > "$BATS_TMP_DIR/fixture"
  bats_run_zsh "file-documentation $BATS_TMP_DIR/fixture"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

# Errors
@test "exits non-zero when the file is missing" {
  bats_run_zsh "file-documentation $BATS_TMP_DIR/zzzzxxxxxnonexistent"
  [[ "$status" -ne 0 ]]
}
