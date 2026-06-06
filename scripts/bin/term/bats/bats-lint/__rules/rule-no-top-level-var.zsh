# Custom Rule: batsLintRule_noTopLevelVar
# Detects uppercase variable assignments at file top level (outside any function/setup).
# All variable definitions must be inside setup(), not at the top of the file.
# Rule Output: file▮code▮error▮line▮message
# Usage:
#   source rule-no-top-level-var.zsh
#   batsLintRule_noTopLevelVar <file.bats>
batsLintRule_noTopLevelVar() {
  local code='noTopLevelVar'
  local msg='Variable definitions must be inside setup(), not at file top level'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line

  for line in "${(@f)content}"; do
    (( ++lineno ))
    # Only flag uppercase variable assignments starting at column 0 (no indent)
    [[ ! "$line" =~ '^[A-Z_][A-Z0-9_]*=' ]] && continue
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
