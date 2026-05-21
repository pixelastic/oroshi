# Custom Rule: zshlintRule_localOrReturn
# Detects local declarations with || chained; local always returns 0 so the guard is silently ineffective
# Rule Output: file▮90002▮error▮line▮message
zshlintRule_localOrReturn() {
  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line
  local -a words

  for line in ${(f)content}; do
    (( ++lineno ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    [[ "$line" =~ ^[[:space:]]*'local'[[:space:]] ]] || continue

    # Shell-aware word splitting respects quotes; || inside a quoted value won't appear as a standalone token
    words=(${(z)line})
    (( ${words[(ie)||]} <= ${#words} )) || continue
    printf '%s%s90002%serror%s%d%slocal always returns 0; split into separate local and guard\n' \
      "$file" "$_SEP" "$_SEP" "$_SEP" "$lineno" "$_SEP"
  done
}
