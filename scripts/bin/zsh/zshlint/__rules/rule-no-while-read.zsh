# Custom Rule: zshlintRule_noWhileRead
# Detects while ... read loops; prefer ${(f)var} ZSH-native iteration
# Rule Output: file▮noWhileRead▮error▮line▮message
# shellcheck disable=SC2016
zshlintRule_noWhileRead() {
  local code='noWhileRead'
  local msg='Use ${(f)var} instead of while/read loops'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line

  for line in "${(@f)content}"; do
    (( ++lineno ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    [[ ! "$line" =~ 'while.*[[:space:]]read([^[:alnum:]_]|$)' ]] && continue
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
