bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../../zsh/__lib/shellcheck-lint.zsh'; source '${BATS_TEST_DIRNAME}/../__lib/bats-lint-shellcheck.zsh'"
}

@test "outputs [] and exits 0 for clean file" {
  local file="$BATS_TMP_DIR/test.bats"
  printf '# clean bats file\n' >"$file"
  bats_run_zsh "${sourcePrefix}; bats-lint-shellcheck $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "detects bash syntax error in bats file" {
  local file="$BATS_TMP_DIR/test.bats"
  printf 'echo $(\n' >"$file"
  bats_run_zsh "${sourcePrefix}; bats-lint-shellcheck $file"
  [[ "$status" -eq 1 ]]
  [[ "$output" != '[]' ]]
}

@test "violation has expected JSON shape" {
  local file="$BATS_TMP_DIR/test.bats"
  printf 'echo $HOME\n' >"$file"
  bats_run_zsh "${sourcePrefix}; bats-lint-shellcheck $file"
  run jq '.' <<<"$output"
  [[ "$output" == '[
  {
    "file": "'"$file"'",
    "code": "SC2086",
    "level": "info",
    "line": 1,
    "endLine": 1,
    "column": 6,
    "endColumn": 11,
    "message": "Double quote to prevent globbing and word splitting."
  }
]' ]]
}

@test "maps shellcheck level warning to warn" {
  local file="$BATS_TMP_DIR/test.bats"
  printf 'echo "$undefinedVar"\n' >"$file"
  bats_run_zsh "${sourcePrefix}; bats-lint-shellcheck $file"
  [[ "$status" -eq 1 ]]
  [[ "$(jq --raw-output '.[0].level' <<<"$output")" == 'warn' ]]
}

@test "outputs string codes and no fix field" {
  local file="$BATS_TMP_DIR/test.bats"
  printf 'echo $HOME\n' >"$file"
  bats_run_zsh "${sourcePrefix}; bats-lint-shellcheck $file"
  [[ "$(jq --raw-output '.[0].code' <<<"$output")" == 'SC2086' ]]
  [[ "$(jq '.[0] | has("fix")' <<<"$output")" == 'false' ]]
}

@test "filters SC2154 on bats magic variables" {
  local file="$BATS_TMP_DIR/test.bats"
  printf 'echo "$output" "$status" "${lines[0]}" "$line"\n' >"$file"
  bats_run_zsh "${sourcePrefix}; bats-lint-shellcheck $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "reports SC2154 on other variables" {
  local file="$BATS_TMP_DIR/test.bats"
  printf 'echo "$undefinedVar"\n' >"$file"
  bats_run_zsh "${sourcePrefix}; bats-lint-shellcheck $file"
  [[ "$status" -eq 1 ]]
  [[ "$(jq --raw-output '.[0].code' <<<"$output")" == 'SC2154' ]]
}

@test "applies the bats exclusions" {
  local file="$BATS_TMP_DIR/test.bats"
  printf "x='\$y'\nunused=1\nf() { local v=\"\$(date)\"; }\n" >"$file"
  bats_run_zsh "${sourcePrefix}; bats-lint-shellcheck $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "applies the SC2317 exclusion" {
  local file="$BATS_TMP_DIR/test.bats"
  printf 'exit 0\nf() { echo hi; }\n' >"$file"
  bats_run_zsh "${sourcePrefix}; bats-lint-shellcheck $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "applies the SC2030 and SC2031 exclusions" {
  local file="$BATS_TMP_DIR/test.bats"
  printf 'n=1\n(n=2)\necho "$n"\n' >"$file"
  bats_run_zsh "${sourcePrefix}; bats-lint-shellcheck $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}
