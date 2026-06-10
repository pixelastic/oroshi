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

# PASS cases {{{
@test "no ICONS usage: no violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# nothing here\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *'"code":"missingIconsLoad"'* ]]
}

@test "ICONS[ with icons-load-definitions anywhere: no violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'icons-load-definitions\necho "$ICONS[tab]"\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$output" != *'"code":"missingIconsLoad"'* ]]
}

@test "\${(k)ICONS} with icons-load-definitions: no violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'icons-load-definitions\nfor k in "${(k)ICONS}"; do echo "$k"; done\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$output" != *'"code":"missingIconsLoad"'* ]]
}

@test "ICONS[ only in a comment: no violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# use $ICONS[tab] for display\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *'"code":"missingIconsLoad"'* ]]
}

@test "disable comment above first trigger line: no violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# zsh-lint disable=missingIconsLoad\necho "$ICONS[tab]"\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$output" != *'"code":"missingIconsLoad"'* ]]
}
# }}}

# FAIL cases {{{
@test "ICONS[ without icons-load-definitions: violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'echo "$ICONS[tab]"\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$output" == *'"code":"missingIconsLoad"'* ]]
}

@test "\${(k)ICONS} without icons-load-definitions: violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'for k in "${(k)ICONS}"; do echo "$k"; done\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$output" == *'"code":"missingIconsLoad"'* ]]
}

@test "shebang script with ICONS[ and no loader: violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '#!/usr/bin/env zsh\nset -e\necho "$ICONS[tab]"\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$output" == *'"code":"missingIconsLoad"'* ]]
}

@test "violation reported at first trigger line" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# comment\necho "$ICONS[tab]"\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$output" == *'"line":2'* ]]
}
# }}}
