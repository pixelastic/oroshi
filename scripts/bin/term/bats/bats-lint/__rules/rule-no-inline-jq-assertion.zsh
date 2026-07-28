# Custom Rule: batsLintRule_noInlineJqAssertion
# Detects inline echo "$output" | jq inside [[ ]] assertions
# Rule Output: file▮code▮error▮line▮message
# Usage:
#   source rule-no-inline-jq-assertion.zsh
#   batsLintRule_noInlineJqAssertion <file.bats>
function batsLintRule_noInlineJqAssertion() {
  local code='noInlineJqAssertion'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line
  local msg

  for line in "${(@f)content}"; do
    (( ++lineno ))
    # Skip comment lines
    [[ "$line" =~ '^[[:space:]]*#' ]] && continue
    # Must be inside [[ ]]
    [[ ! "$line" =~ '\[\[' ]] && continue
    # Must pipe $output to jq
    # shellcheck disable=SC2016
    [[ ! "$line" =~ 'echo[[:space:]]+"?\$output"?[[:space:]]*\|[[:space:]]*jq' ]] && continue
    # Skip jq -e (boolean exit code assertions)
    [[ "$line" =~ 'jq[[:space:]]+-e' ]] && continue

    # Determine which helper to suggest
    msg='Use expect_json instead of inline jq assertion'
    # jq (no -r) compared to null → [[ "$(echo "$output" | jq ".key")" == "null" ]]
    if [[ ! "$line" =~ 'jq[[:space:]]+-r' && "$line" =~ '==[[:space:]]*"?null"?' ]]; then
      msg='Use expect_json_null instead of inline jq assertion'
    fi
    # Unquoted RHS (not null) → [[ "$(echo "$output" | jq -r ".key")" == foo* ]]
    if [[ "$line" =~ '==[[:space:]]*[^"[:space:]]' && ! "$line" =~ '==[[:space:]]*"?null"?' ]]; then
      msg='Use expect_json_glob instead of inline jq assertion'
    fi

    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
