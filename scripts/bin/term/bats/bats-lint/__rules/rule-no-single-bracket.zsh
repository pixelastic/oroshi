# Custom Rule: batsLintRule_noSingleBracket
# Detects [ ] assertions in BATS files; use [[ ]] instead
# Rule Output: file▮code▮error▮line▮message
# Usage:
#   source rule-no-single-bracket.zsh
#   batsLintRule_noSingleBracket <file.bats>
function batsLintRule_noSingleBracket() {
  local code='noSingleBracket'
  local msg='Use [[ ]] instead of [ ]'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line

  for line in "${(@f)content}"; do
    (( ++lineno ))
    # Skip comment lines
    [[ "$line" =~ '^[[:space:]]*#' ]] && continue
    # Skip @test title lines
    [[ "$line" =~ '^@test ' ]] && continue
    # Flag single bracket not followed by another bracket
    [[ ! "$line" =~ '^[[:space:]]*\[ [^\[]' ]] && continue
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
