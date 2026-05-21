# Custom Rule: zshlintRule_noManualArgParsing
# Detects manual argument parsing patterns; suggests zparseopts instead
# Rule Output: file▮noManualArgParsing▮error▮line▮message
zshlintRule_noManualArgParsing() {
  local code='noManualArgParsing'
  local msg='Use zparseopts for parsing arguments'

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
      printf '%s%s%s%serror%s%d%s%s\n' \
        "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
      break
    done
  done
}
