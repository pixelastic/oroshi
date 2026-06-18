bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../zsh-lint-custom.zsh'"
}

# PASS cases {{{
@test "no FILETYPES usage: no violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# nothing here\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *'"code":"missingFiletypesLoad"'* ]]
}

@test "FILETYPES[ with filetypes-load-definitions anywhere: no violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'filetypes-load-definitions\necho "$FILETYPES[md:color]"\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$output" != *'"code":"missingFiletypesLoad"'* ]]
}

@test "\${(k)FILETYPES} with filetypes-load-definitions: no violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'filetypes-load-definitions\nfor k in "${(k)FILETYPES}"; do echo "$k"; done\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$output" != *'"code":"missingFiletypesLoad"'* ]]
}

@test "FILETYPES[ only in a comment: no violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# use $FILETYPES[md:color] for display\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *'"code":"missingFiletypesLoad"'* ]]
}

@test "disable comment above first trigger line: no violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# zsh-lint disable=missingFiletypesLoad\necho "$FILETYPES[md:color]"\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$output" != *'"code":"missingFiletypesLoad"'* ]]
}
# }}}

# FAIL cases {{{
@test "FILETYPES[ without filetypes-load-definitions: violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'echo "$FILETYPES[md:color]"\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$output" == *'"code":"missingFiletypesLoad"'* ]]
}

@test "\${(k)FILETYPES} without filetypes-load-definitions: violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'for k in "${(k)FILETYPES}"; do echo "$k"; done\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$output" == *'"code":"missingFiletypesLoad"'* ]]
}

@test "violation reported at first trigger line" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# comment\necho "$FILETYPES[md:color]"\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$output" == *'"line":2'* ]]
}
# }}}
