# Custom Rule: zshLintRule_noDashZ
# Detects -z flag inside [[ ]] tests; prefer == "" comparison
# Rule Output: file▮noDashZ▮error▮line▮message
# shellcheck disable=SC2016
zshLintRule_noDashZ() {
  local code='noDashZ'
  local msg='Prefer [[ "$var" == "" ]] over -z'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line

  for line in "${(@f)content}"; do
    (( ++lineno ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    [[ ! "$line" =~ '\[\[.*[[:space:]]-z([[:space:]]|"|\$)' ]] && continue
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
