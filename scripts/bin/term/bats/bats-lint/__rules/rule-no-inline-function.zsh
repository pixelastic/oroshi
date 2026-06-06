# Custom Rule: batsLintRule_noInlineFunction
# Detects single-line function definitions that should be multi-line:
#   - line length > 90 characters, OR
#   - body has 2+ instructions
# Rule Output: file▮code▮error▮line▮message
# Usage:
#   source rule-no-inline-function.zsh
#   batsLintRule_noInlineFunction <file.bats>
batsLintRule_noInlineFunction() {
  local code='noInlineFunction'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line
  local part

  for line in "${(@f)content}"; do
    (( ++lineno ))
    # Skip lines that are not single-line function definitions
    [[ ! "$line" =~ '^\s*[a-zA-Z_][a-zA-Z0-9_-]*\s*\(\)\s*\{.*\}\s*$' ]] && continue
    # Flag if the line exceeds 90 characters
    if (( ${#line} > 90 )); then
      printf '%s%s%s%serror%s%d%s%s\n' \
        "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "Inline function too long (> 90 chars), split onto multiple lines"
      continue
    fi
    # Extract the body between the first { and the last }
    local body="${line#*\{}"
    body="${body%\}*}"
    # Count non-empty instructions (split by ;)
    local -a parts=("${(@s:;:)body}")
    local count=0
    for part in "${parts[@]}"; do
      [[ "${part//[[:space:]]/}" != "" ]] && (( ++count ))
    done
    # Flag if more than one instruction
    (( count <= 1 )) && continue
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "Multi-instruction function body must be multi-line"
  done
}
