# Custom Rule: zshLintRule_localOrReturn
# Detects local declarations with || chained; local always returns 0 so the guard is silently ineffective
# Rule Output: file▮localOrReturn▮error▮line▮message
zshLintRule_localOrReturn() {
  local file="$1"
  local code='localOrReturn'
  local msg='local always returns 0; split into separate local and guard'
  local content="$(<"$file")"
  local lineno=0
  local line
  local -a words

  for line in "${(@f)content}"; do
    (( ++lineno ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    [[ ! "$line" =~ ^[[:space:]]*'local'[[:space:]] ]] && continue

    # Shell-aware word splitting respects quotes; || inside a quoted value won't appear as a standalone token
    words=(${(z)line})
    (( ${words[(ie)||]} <= ${#words} )) || continue
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
