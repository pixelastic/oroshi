# Custom Rule: zshlintRule_noGroupedLocals
# Detects local declarations that define multiple variables on one line
# Rule Output: file▮90001▮warning▮line▮message
zshlintRule_noGroupedLocals() {
  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line
  local rest
  local -a words

  for line in ${(f)content}; do
    (( ++lineno ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    [[ "$line" =~ ^[[:space:]]*'local'[[:space:]]+(.*) ]] || continue

    rest="${match[1]}"

    # Split using ZSH shell-aware word splitting (respects quotes and parens)
    words=(${(z)rest})

    # Strip leading option flags (-a, -r, -rA, etc.)
    while [[ ${#words} -gt 0 && "${words[1]}" =~ ^- ]]; do
      words=("${(@)words[2,-1]}")
    done

    (( ${#words} > 1 )) || continue
    printf '%s%s90001%swarning%s%d%sDeclare each local variable on its own line\n' \
      "$file" "$_SEP" "$_SEP" "$_SEP" "$lineno" "$_SEP"
  done
}
