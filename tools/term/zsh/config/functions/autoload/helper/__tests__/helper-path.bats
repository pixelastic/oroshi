bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# Names
@test "prints the path of a loaded autoloaded function" {
  bats_run_zsh "slugify hello >/dev/null && helper-path slugify"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/misc/slugify" ]]
}

@test "prints the path of an autoloaded function that is not loaded yet" {
  bats_run_zsh "helper-path slugify"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/misc/slugify" ]]
}

@test "prints the path of a script" {
  bats_run_zsh "helper-path bin-zsh"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$OROSHI_ROOT/scripts/bin/bin-zsh" ]]
}

@test "exits non-zero and prints nothing for an unknown name" {
  bats_run_zsh "helper-path zzzzxxxxxnonexistent"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}

# Shell options
@test "prints the path of an autoloaded function when bare_glob_qual is off, like in Claude Code's Bash tool" {
  bats_run_zsh "unsetopt bare_glob_qual; helper-path slugify"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/misc/slugify" ]]
}

# Reply
@test "fills REPLY and prints nothing with --reply" {
  bats_run_zsh "helper-path --reply slugify && print -r -- \"reply=\$REPLY\""
  [[ "$status" -eq 0 ]]
  [[ "$output" == "reply=$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/misc/slugify" ]]
}
