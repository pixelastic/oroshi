# Custom Rule: zshLintRule_noDoubleNegative
# Detects double negatives in [[ ]] tests: [[ ! "$var" != "" ]] should be [[ "$var" == "" ]]
# Rule Output: file▮noDoubleNegative▮error▮line▮message
# shellcheck disable=SC2016
zshLintRule_noDoubleNegative() {
  local code='noDoubleNegative'
  # zsh-lint disable=noDoubleNegative
  local msg='Double negative: prefer [[ "$var" == "" ]] over [[ ! "$var" != "" ]]'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line
  local doubleNegPattern='\[\[.*[[:space:]]![[:space:]].*!='

  for line in "${(@f)content}"; do
    (( ++lineno ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    [[ ! "$line" =~ "$doubleNegPattern" ]] && continue
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
