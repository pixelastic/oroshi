# Custom Rule: zshLintRule_noGroupedLocals
# Detects local declarations that define multiple variables on one line
# Rule Output: file▮noGroupedLocals▮error▮line▮message
zshLintRule_noGroupedLocals() {
  local code='noGroupedLocals'
  local msg='Declare each local variable on its own line'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line
  local rest
  local w
  local count
  local -a words

  for line in "${(@f)content}"; do
    (( ++lineno ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    [[ ! "$line" =~ ^[[:space:]]*'local'[[:space:]]+(.*) ]] && continue

    rest="${match[1]}"

    # Split using ZSH shell-aware word splitting (respects quotes and parens)
    words=(${(z)rest})

    # Strip leading option flags (-a, -r, -rA, etc.)
    while [[ ${#words} -gt 0 && "${words[1]}" =~ ^- ]]; do
      words=("${(@)words[2,-1]}")
    done

    # Count only tokens starting with a valid var-name char
    # Stop at array literal: standalone ( or varname=( means we've entered array values
    count=0
    for w in "${words[@]}"; do
      [[ "$w" == '#' ]] && break
      [[ "$w" =~ '^\(' ]] && break
      [[ "$w" =~ '^[a-zA-Z_][a-zA-Z0-9_]*=\(' ]] && { (( ++count )); break; }
      [[ "$w" =~ ^[a-zA-Z_] ]] && (( ++count ))
    done
    (( count > 1 )) || continue
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
