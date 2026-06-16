bats_load_library 'helper'

# --- ANSI mode (no --zsh) ---

setup() {
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

@test "colorize with fg and bg produces ANSI fg sequence" {
  bats_run_zsh "colorize 'text' 87 100"
  [[ "$output" == *$'\e[38;5;87m'* ]]
}

@test "colorize with fg and bg produces ANSI bg sequence" {
  bats_run_zsh "colorize 'text' 87 100"
  [[ "$output" == *$'\e[48;5;100m'* ]]
}

@test "colorize with fg and bg ends with ANSI reset" {
  bats_run_zsh "colorize 'text' 87 100"
  [[ "$output" == *$'\e[0m'* ]]
}

@test "colorize ANSI output contains no zsh codes" {
  bats_run_zsh "colorize 'text' 87 100"
  [[ "$output" != *'%K{'* ]]
  [[ "$output" != *'%F{'* ]]
}

@test "colorize without bg produces no background ANSI code" {
  bats_run_zsh "colorize 'text' 87"
  [[ "$output" != *$'\e[48;'* ]]
  [[ "$output" != *'%K{'* ]]
}

# --- Zsh mode (--zsh) ---

@test "colorize --zsh produces fg zsh code" {
  bats_run_zsh "colorize 'text' 87 100 --zsh"
  [[ "$output" == *'%F{87}'* ]]
}

@test "colorize --zsh produces bg zsh code" {
  bats_run_zsh "colorize 'text' 87 100 --zsh"
  [[ "$output" == *'%K{100}'* ]]
}

@test "colorize --zsh ends with fg and bg reset codes" {
  bats_run_zsh "colorize 'text' 87 100 --zsh"
  [[ "$output" == *'%f%k'* ]]
}

@test "colorize --zsh output contains no ANSI sequence" {
  bats_run_zsh "colorize 'text' 87 100 --zsh"
  [[ "$output" != *$'\e['* ]]
}

# --- OROSHI_IS_PROMPT backward compat removed ---

@test "OROSHI_IS_PROMPT=1 does not trigger zsh output" {
  export OROSHI_IS_PROMPT=1
  bats_run_zsh "colorize text 87"
  unset OROSHI_IS_PROMPT
  [[ "$output" != *'%F{'* ]]
  [[ "$output" == *$'\e['* ]]
}

# --- Concatenation ---

@test "two consecutive colorize calls concatenate without newlines" {
  local script="$BATS_TMP_DIR/concat.zsh"
  printf "colorize 'foo' 87\ncolorize 'bar' 88\n" >"$script"
  bats_run_zsh "$script"
  [[ "$output" != *$'\n'* ]]
}
