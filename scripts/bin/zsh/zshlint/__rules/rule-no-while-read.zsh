# Custom Rule: zshlintRule_noWhileRead
# Detects while ... read loops; prefer ${(f)var} ZSH-native iteration
# Rule Output: file▮90004▮warning▮line▮message
# shellcheck disable=SC2016
zshlintRule_noWhileRead() {
  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line

  for line in ${(f)content}; do
    (( ++lineno ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    [[ "$line" =~ 'while.*[[:space:]]read([^[:alnum:]_]|$)' ]] || continue
    printf '%s%s90004%swarning%s%d%sPrefer ${(f)var} over while read loops\n' \
      "$file" "$_SEP" "$_SEP" "$_SEP" "$lineno" "$_SEP"
  done
}
