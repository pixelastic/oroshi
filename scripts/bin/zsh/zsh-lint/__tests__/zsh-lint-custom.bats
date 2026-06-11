#!/usr/bin/env bats

bats_load_library 'helper'

setup() {
  bats_tmp_dir
  local script="${BATS_TEST_DIRNAME}/../zsh-lint-custom.zsh"
  CURRENT="$BATS_TMP_DIR/caller.zsh"
  printf 'zsh-lint-custom "$@"\n' >"$CURRENT"
  printf "source '%s'\n" "$script" >"$BATS_TMP_DIR/mock.zsh"
}

teardown() {
  bats_cleanup
}

@test "outputs [] and exits 0 for clean file" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# clean\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "outputs JSON with code noManualArgParsing for case \"\$1\" pattern" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'case "$1" in\n  --foo) foo=1 ;;\nesac\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$output" == *'"code":"noManualArgParsing"'* ]]
}

@test "exits 1 when custom rule finds a violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'case "$1" in\n  --foo) foo=1 ;;\nesac\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$status" -eq 1 ]]
}

@test "outputs valid JSON array" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# clean\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  run bash -c "printf '%s' '$output' | jq 'type == \"array\"'"
  [[ "$output" == 'true' ]]
}

@test "outputs valid JSON when same rule fires on multiple lines" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'local a b c\nlocal d e f\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$status" -eq 1 ]]
  run bash -c "jq 'length' <<< '$output'"
  [[ "$output" == '2' ]]
}

@test "noWhileRead violation emits level error" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'while IFS= read -r line; do\necho "$line"\ndone\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$output" == *'"level":"error"'* ]]
}

@test "noManualArgParsing violation emits level error" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'case "$1" in\n  --foo) foo=1 ;;\nesac\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$output" == *'"level":"error"'* ]]
}

@test "noGroupedLocals violation emits level error" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'local a b\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$output" == *'"level":"error"'* ]]
}

@test "noExternalBasename violation emits level error" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'name="$(basename "$path")"\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$output" == *'"level":"error"'* ]]
}

@test "singleEqualsInTest violation emits level error" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '[[ "$a" = "$b" ]]\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$output" == *'"level":"error"'* ]]
}

@test "localOrReturn violation emits level error" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'local x="$(cmd)" || return 1\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$output" == *'"level":"error"'* ]]
}

@test "zsh-lint disable=X suppresses violation on next line" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# zsh-lint disable=noGroupedLocals\nlocal a b\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "zsh-lint-disable (old syntax) does not suppress violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# zsh-lint-disable noGroupedLocals\nlocal a b\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *'"code":"noGroupedLocals"'* ]]
}

@test "zsh-lint disable=X only suppresses the named rule" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# zsh-lint disable=noGroupedLocals\nlocal a b\nlocal c d\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$output" == *'"code":"noGroupedLocals"'* ]]
}

@test "zsh-lint disable=X with wrong code does not suppress" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# zsh-lint disable=noDashZ\nlocal a b\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$output" == *'"code":"noGroupedLocals"'* ]]
}

@test "zsh-lint disable=X,Y suppresses both violations on next line" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# zsh-lint disable=noGroupedLocals,singleEqualsInTest\nlocal a b; [[ "$x" = "$y" ]]\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "zsh-lint disable=X,Y does not suppress unlisted rule on same line" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# zsh-lint disable=noGroupedLocals,singleEqualsInTest\nlocal a b; [[ "$x" = "$y" ]]; name=$(basename "$path")\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$output" == *'"code":"noExternalBasename"'* ]]
  [[ "$output" != *'"code":"noGroupedLocals"'* ]]
  [[ "$output" != *'"code":"singleEqualsInTest"'* ]]
}
