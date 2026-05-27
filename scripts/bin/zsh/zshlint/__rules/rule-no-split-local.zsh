# Custom Rule: zshlintRule_noSplitLocal
# Detects bare local declaration immediately followed by assignment on next line
# Rule Output: file▮noSplitLocal▮error▮line▮message
zshlintRule_noSplitLocal() {
  local code='noSplitLocal'
  local msg='Combine local declaration and assignment on one line'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line
  local prevVar=""
  local prevLineno=0
  local -a words

  for line in "${(@f)content}"; do
    (( ++lineno ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue

    # Flag if current line assigns to the var bare-declared on the previous line
    if [[ -n "$prevVar" && "$line" =~ ^[[:space:]]*"${prevVar}"'[+]?=' ]]; then
      printf '%s%s%s%serror%s%d%s%s\n' \
        "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$prevLineno" "$_SEP" "$msg"
    fi

    # Reset — only keep tracking if this line is itself a bare local declaration
    prevVar=""

    [[ "$line" =~ ^[[:space:]]*'local'[[:space:]] ]] || continue

    # Parse words, strip 'local' and any option flags
    words=(${(z)line})
    words=("${(@)words[2,-1]}")
    while [[ ${#words} -gt 0 && "${words[1]}" =~ ^- ]]; do
      words=("${(@)words[2,-1]}")
    done

    # Bare declaration: exactly one word with no '=' sign
    [[ ${#words} -eq 1 && "${words[1]}" != *'='* ]] || continue
    prevVar="${words[1]}"
    prevLineno=$lineno
  done
}
