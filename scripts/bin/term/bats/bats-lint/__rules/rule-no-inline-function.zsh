# Custom Rule: batsLintRule_noInlineFunction
# Detects function bodies with 2+ instructions inlined on a single line
# Rule Output: file▮code▮error▮line▮message
# Usage:
#   source rule-no-inline-function.zsh
#   batsLintRule_noInlineFunction <file.bats>
batsLintRule_noInlineFunction() {
  local code='noInlineFunction'
  local msg='Multi-instruction function body must be multi-line'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line

  for line in "${(@f)content}"; do
    (( ++lineno ))
    # Skip lines that are not single-line function definitions
    [[ ! "$line" =~ '^\s*[a-zA-Z_][a-zA-Z0-9_-]*\s*\(\)\s*\{.*\}\s*$' ]] && continue
    # Honour inline disable comment
    [[ "$line" =~ '# bats-lint-disable noInlineFunction' ]] && continue
    # Extract the body between the first { and the last }
    local body="${line#*\{}"
    body="${body%\}*}"
    # Count non-empty instructions (split by ;)
    local -a parts=("${(@s:;:)body}")
    local count=0
    local part
    for part in "${parts[@]}"; do
      [[ "${part//[[:space:]]/}" != "" ]] && (( ++count ))
    done
    # Flag if more than one instruction
    (( count <= 1 )) && continue
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
