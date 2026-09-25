# Custom Rule: zshLintRule_noAndBlock
# Detects [[ ]] && { — prefer if/then/fi for multi-instruction blocks
# Rule Output: file▮noAndBlock▮error▮line▮message
# shellcheck disable=SC2016
function zshLintRule_noAndBlock() {
  local code='noAndBlock'
  # zsh-lint disable=noAndBlock
  local msg='Prefer if/then/fi over [[ cond ]] && { ... } for multi-instruction blocks'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line

  for line in "${(@f)content}"; do
    (( ++lineno ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    # zsh-lint disable=noChainedAnd
    [[ ! "$line" =~ '\]\][[:space:]]*&&[[:space:]]*\{' ]] && continue
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
