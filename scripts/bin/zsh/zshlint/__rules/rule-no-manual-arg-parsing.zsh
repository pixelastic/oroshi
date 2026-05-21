# Custom Rule: zshlintRule_noManualArgParsing
# Detects manual argument parsing patterns; suggests zparseopts instead
# Rule Output: file▮noManualArgParsing▮warning▮line▮message
zshlintRule_noManualArgParsing() {
  local file="$1"
  # shellcheck disable=SC2016
  local -a patterns=(
    'case "\$1"'
    # Split in two strings to not match itself...
    'while get''opts'
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
      printf '%s%snoManualArgParsing%swarning%s%d%sUse zparseopts for parsing arguments\n' \
        "$file" "$_SEP" "$_SEP" "$_SEP" "$lineno" "$_SEP"
      break
    done
  done
}
