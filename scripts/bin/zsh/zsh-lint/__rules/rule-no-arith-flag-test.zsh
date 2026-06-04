# Custom Rule: zshLintRule_noArithFlagTest
# Detects (( isXxx )) used to test zparseopts flag vars; prefer [[ $var == "1" ]]
# Rule Output: file▮noArithFlagTest▮error▮line▮message
# shellcheck disable=SC2016
zshLintRule_noArithFlagTest() {
  local code='noArithFlagTest'
  local msg='Prefer [[ $isXxx == "1" ]] over (( isXxx )) for flag tests'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line

  for line in "${(@f)content}"; do
    (( ++lineno ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    # Skip string assignments (local msg='...') to avoid false positives
    [[ "$line" =~ ^[[:space:]]*'local '[[:space:]]* ]] && continue
    # Match (( isXxx )) where isXxx is a bare boolean-flag var (no operator after it)
    [[ ! "$line" =~ '\(\([[:space:]]*is[A-Z][[:alnum:]]*[[:space:]]*\)\)' ]] && continue
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
