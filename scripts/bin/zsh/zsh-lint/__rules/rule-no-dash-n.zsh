# Custom Rule: zshLintRule_noDashN
# Detects -n flag inside [[ ]] tests; prefer != "" comparison
# Rule Output: file▮noDashN▮error▮line▮message
# shellcheck disable=SC2016
zshLintRule_noDashN() {
  local code='noDashN'
  local msg='Prefer [[ "$var" != "" ]] over -n'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line

  for line in "${(@f)content}"; do
    (( ++lineno ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    [[ ! "$line" =~ '\[\[[^]]*[[:space:]]-n([[:space:]]|"|\$)' ]] && continue
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
