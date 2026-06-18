bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../zsh-lint-custom.zsh'"
}

# PASS cases {{{
@test "no PROJECTS usage: no violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# nothing here\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *'"code":"missingProjectsLoad"'* ]]
}

@test "PROJECTS[ with projects-load-definitions anywhere: no violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'projects-load-definitions\necho "$PROJECTS[oroshi:icon]"\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$output" != *'"code":"missingProjectsLoad"'* ]]
}

@test "\${(k)PROJECTS} with projects-load-definitions: no violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'projects-load-definitions\nfor k in "${(k)PROJECTS}"; do echo "$k"; done\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$output" != *'"code":"missingProjectsLoad"'* ]]
}

@test "PROJECTS[ without dollar sign (e.g. in jq string): no violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '"PROJECTS[\(.key)]=\(.value)"\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *'"code":"missingProjectsLoad"'* ]]
}

@test "PROJECTS[ only in a comment: no violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# use $PROJECTS[oroshi:icon] for display\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *'"code":"missingProjectsLoad"'* ]]
}

@test "disable comment above first trigger line: no violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# zsh-lint disable=missingProjectsLoad\necho "$PROJECTS[oroshi:icon]"\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$output" != *'"code":"missingProjectsLoad"'* ]]
}
# }}}

# FAIL cases {{{
@test "PROJECTS[ without projects-load-definitions: violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'echo "$PROJECTS[oroshi:icon]"\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$output" == *'"code":"missingProjectsLoad"'* ]]
}

@test "\${(k)PROJECTS} without projects-load-definitions: violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'for k in "${(k)PROJECTS}"; do echo "$k"; done\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$output" == *'"code":"missingProjectsLoad"'* ]]
}

@test "shebang script with PROJECTS[ and no loader: violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '#!/usr/bin/env zsh\nset -e\necho "$PROJECTS[oroshi:icon]"\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$output" == *'"code":"missingProjectsLoad"'* ]]
}

@test "violation reported at first trigger line" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# comment\necho "$PROJECTS[oroshi:icon]"\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$output" == *'"line":2'* ]]
}
# }}}
