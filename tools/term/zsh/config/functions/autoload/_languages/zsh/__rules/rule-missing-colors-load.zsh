# Custom Rule: zshLintRule_missingColorsLoad
# Detects functions/scripts that access $COLORS[] without calling colors-load-definitions
# Rule Output: file▮missingColorsLoad▮error▮line▮message
function zshLintRule_missingColorsLoad() {
  local code='missingColorsLoad'
  local msg="add 'colors-load-definitions' at top of file (after argument parsing if any)"

  local file="$1"
  local content="$(<"$file")"

  # Skip if colors-load-definitions is already present
  [[ "$content" =~ 'colors-load-definitions' ]] && return 0

  # Find first trigger line: COLORS[ subscript or ${(k)COLORS} key enumeration
  # Skip comment lines
  local lineNum=0
  local firstTriggerLine=0
  local line
  for line in "${(@f)content}"; do
    (( ++lineNum ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    if [[ "$line" =~ '\$\{?COLORS\[' || "$line" =~ '\$\{(\([^)]*\))?COLORS\}?' ]]; then
      firstTriggerLine=$lineNum
      break
    fi
  done

  # No trigger lines found → no violation
  [[ $firstTriggerLine -eq 0 ]] && return 0

  printf '%s%s%s%serror%s%d%s%s\n' \
    "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$firstTriggerLine" "$_SEP" "$msg"
}
