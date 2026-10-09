bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# Descriptions
@test "prints the first comment line of an autoloaded function" {
  bats_run_zsh "helper-description slugify"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$(head --lines=1 "$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/misc/slugify" | sed 's/^# //')" ]]
}

@test "prints the second line of a script after its shebang" {
  bats_run_zsh "helper-description bin-zsh"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$(sed --quiet '2p' "$OROSHI_ROOT/scripts/bin/bin-zsh" | sed 's/^# //')" ]]
}

@test "prints an empty description when the header has none" {
  printf '#!/usr/bin/env zsh\necho hello\n' > "$BATS_TMP_DIR/fixture-no-description"
  chmod +x "$BATS_TMP_DIR/fixture-no-description"
  bats_run_zsh "PATH=$BATS_TMP_DIR:\$PATH helper-description fixture-no-description"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

# Reply
@test "fills REPLY and prints nothing with --reply" {
  bats_run_zsh "helper-description --reply slugify && print -r -- \"reply=\$REPLY\""
  [[ "$status" -eq 0 ]]
  [[ "$output" == "reply=$(head --lines=1 "$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/misc/slugify" | sed 's/^# //')" ]]
}

# Errors
@test "exits non-zero for an unknown name" {
  bats_run_zsh "helper-description zzzzxxxxxnonexistent"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}
