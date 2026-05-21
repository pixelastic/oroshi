# Custom Rule: zshlintRule_noManualArgParsing
# Detects manual argument parsing patterns; suggests zparseopts instead
# Rule Output: file▮90005▮warning▮line▮message
zshlintRule_noManualArgParsing() {
  local file="$1"
  # shellcheck disable=SC2016
  local -a patterns=(
    'case "\$1"'
    'while getopts'
  )
  local content="$(<"$file")"
  local lineno=0
  local line
  local pattern
  for line in "${(@f)content}"; do
    (( ++lineno ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    for pattern in $patterns; do
      [[ "$line" =~ $pattern ]] || continue
      printf '%s%s90005%swarning%s%d%sUse zparseopts for parsing arguments\n' \
        "$file" "$_SEP" "$_SEP" "$_SEP" "$lineno" "$_SEP"
      break
    done
  done
}
