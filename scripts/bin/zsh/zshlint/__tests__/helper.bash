# zshlint rule testing helpers
# Each test file must set RULE_FILE and RULE_FN at the top level

export _SEP=$'\u25ae'

run_rule() {
  local file="$(bats_tmp)/test.zsh"
  printf '%s\n' "$@" > "$file"
  run zsh -c "source '${RULE_FILE}'; ${RULE_FN} '${file}'"
}

expect_violation() {
  local code="$1"
  local line="$2"
  [[ "$output" == *"${code}"* ]]
  [[ "$output" == *"${_SEP}${line}${_SEP}"* ]]
}

expect_clean() {
  [[ -z "$output" ]]
}
