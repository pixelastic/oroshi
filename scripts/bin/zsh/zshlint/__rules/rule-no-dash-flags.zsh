# Custom Rule: zshlintRule_noDashFlags
# Detects -z/-n flags inside [[ ]] tests; prefer == "" or != "" comparisons
# Rule Output: file▮noDashFlags▮error▮line▮message
# shellcheck disable=SC2016
zshlintRule_noDashFlags() {
  local code='noDashFlags'
  local msg='Prefer [[ "$var" == "" ]] over -z, and [[ "$var" != "" ]] over -n'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line

  for line in "${(@f)content}"; do
    (( ++lineno ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    [[ "$line" =~ '\[\[.*[[:space:]]-[zn]([[:space:]]|"|\$)' ]] || continue
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
