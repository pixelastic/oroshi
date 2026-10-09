bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# Documentation
@test "prints the full header of an autoloaded function, without comment prefixes" {
  printf '#autoload\n# Title\n#\n# Usage:\n# $ fixture-function arg\necho body\n' > "$BATS_TMP_DIR/fixture-function"
  bats_run_zsh "fpath=($BATS_TMP_DIR \$fpath); helper-documentation fixture-function"
  [[ "$status" -eq 0 ]]
  [[ "$output" == $'Title\n\nUsage:\n$ fixture-function arg' ]]
}

@test "prints the full header of a script, skipping the shebang" {
  printf '#!/usr/bin/env zsh\n# Title\n# Usage:\n# $ fixture-script arg\necho body\n' > "$BATS_TMP_DIR/fixture-script"
  chmod +x "$BATS_TMP_DIR/fixture-script"
  bats_run_zsh "PATH=$BATS_TMP_DIR:\$PATH helper-documentation fixture-script"
  [[ "$status" -eq 0 ]]
  [[ "$output" == $'Title\nUsage:\n$ fixture-script arg' ]]
}

@test "stops at the first non-comment line" {
  printf '# Title\necho body\n# Not header\n' > "$BATS_TMP_DIR/fixture-stop"
  bats_run_zsh "fpath=($BATS_TMP_DIR \$fpath); helper-documentation fixture-stop"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "Title" ]]
}

@test "prints nothing for a file without header" {
  printf 'echo body\n' > "$BATS_TMP_DIR/fixture-bare"
  bats_run_zsh "fpath=($BATS_TMP_DIR \$fpath); helper-documentation fixture-bare"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

# Reply
@test "fills REPLY and prints nothing with --reply" {
  printf '# Title\n# Usage:\n' > "$BATS_TMP_DIR/fixture-reply"
  bats_run_zsh "fpath=($BATS_TMP_DIR \$fpath); helper-documentation --reply fixture-reply && print -r -- \"reply=\$REPLY\""
  [[ "$status" -eq 0 ]]
  [[ "$output" == $'reply=Title\nUsage:' ]]
}

# Errors
@test "exits non-zero for an unknown name" {
  bats_run_zsh "helper-documentation zzzzxxxxxnonexistent"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}
