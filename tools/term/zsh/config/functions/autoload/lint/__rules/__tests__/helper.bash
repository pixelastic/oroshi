# zsh-lint rule testing helpers
# Each test file must set RULE_FILE and RULE_FN at the top level

run_rule() {
  [[ -z "$BATS_TMP_DIR" ]] && bats_tmp_dir
  local file="$BATS_TMP_DIR/test.zsh"
  printf '%s\n' "$@" >"$file"
  run zsh -c "source '${RULE_FILE}'; ${RULE_FN} '${file}'"
}

expect_violation() {
  local code="$1"
  local line="$2"
  [[ "$output" == *"${code}"* ]]
  [[ "$output" == *"▮${line}▮"* ]]
}

expect_clean() {
  [[ -z "$output" ]]
}
