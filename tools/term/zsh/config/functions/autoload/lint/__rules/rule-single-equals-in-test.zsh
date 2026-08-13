# Custom Rule: zshLintRule_singleEqualsInTest
# Detects single = used for string comparison inside [[ ]]; prefer ==
# Rule Output: file▮singleEqualsInTest▮error▮line▮message
# shellcheck disable=SC2016
function zshLintRule_singleEqualsInTest() {
  local code='singleEqualsInTest'
  local msg='Prefer == over = for string comparison in [[ ]]'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line

  for line in "${(@f)content}"; do
    (( ++lineno ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    [[ ! "$line" =~ '\[\[.*[[:space:]]=[[:space:]]' ]] && continue
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
