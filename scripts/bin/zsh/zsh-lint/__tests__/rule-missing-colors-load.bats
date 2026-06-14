bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../zsh-lint-custom.zsh'"
}

teardown() {
  bats_cleanup
}

# PASS cases {{{
@test "no COLORS usage: no violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# nothing here\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *'"code":"missingColorsLoad"'* ]]
}

@test "COLORS[ with colors-load-definitions anywhere: no violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'colors-load-definitions\necho "$COLORS[red-1]"\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$output" != *'"code":"missingColorsLoad"'* ]]
}

@test "\${(k)COLORS} with colors-load-definitions: no violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'colors-load-definitions\nfor k in "${(k)COLORS}"; do echo "$k"; done\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$output" != *'"code":"missingColorsLoad"'* ]]
}

@test "COLORS[ without dollar sign (e.g. in jq string): no violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '"COLORS[\(.key)]=\(.value)"\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *'"code":"missingColorsLoad"'* ]]
}

@test "COLORS[ only in a comment: no violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# use $COLORS[red-1] for display\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *'"code":"missingColorsLoad"'* ]]
}

@test "disable comment above first trigger line: no violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# zsh-lint disable=missingColorsLoad\necho "$COLORS[red-1]"\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$output" != *'"code":"missingColorsLoad"'* ]]
}
# }}}

# FAIL cases {{{
@test "COLORS[ without colors-load-definitions: violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'echo "$COLORS[red-1]"\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$output" == *'"code":"missingColorsLoad"'* ]]
}

@test "\${(k)COLORS} without colors-load-definitions: violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'for k in "${(k)COLORS}"; do echo "$k"; done\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$output" == *'"code":"missingColorsLoad"'* ]]
}

@test "shebang script with COLORS[ and no loader: violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '#!/usr/bin/env zsh\nset -e\necho "$COLORS[red-1]"\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$output" == *'"code":"missingColorsLoad"'* ]]
}

@test "violation reported at first trigger line" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# comment\necho "$COLORS[red-1]"\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$output" == *'"line":2'* ]]
}
# }}}
