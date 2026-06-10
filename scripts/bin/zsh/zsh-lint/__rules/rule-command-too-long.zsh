# Custom Rule: zshLintRule_commandTooLong
# Flags command invocations exceeding 100 characters
# Rule Output: file▮commandTooLong▮error▮line▮message
# shellcheck disable=SC2016
zshLintRule_commandTooLong() {
  local code='commandTooLong'
  local msg='Command too long (max 100 chars). Try splitting on pipes or arguments.'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line

  for line in "${(@f)content}"; do
    (( ++lineno ))
    # Skip lines within the limit
    [[ ${#line} -le 100 ]] && continue
    # Skip comments
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    # Skip [[ conditionals
    [[ "$line" =~ ^[[:space:]]*'\[\[' ]] && continue
    # Skip if statements
    [[ "$line" =~ ^[[:space:]]*'if ' ]] && continue
    # Skip local declarations
    [[ "$line" =~ ^[[:space:]]*'local ' ]] && continue
    # Skip bare assignments (identifier=value)
    [[ "$line" =~ ^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*= ]] && continue
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
