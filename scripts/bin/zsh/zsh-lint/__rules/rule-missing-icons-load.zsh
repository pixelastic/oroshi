# Custom Rule: zshLintRule_missingIconsLoad
# Detects functions/scripts that access $ICONS[] without calling icons-load-definitions
# Rule Output: file▮missingIconsLoad▮error▮line▮message
zshLintRule_missingIconsLoad() {
  local code='missingIconsLoad'
  local msg="add 'icons-load-definitions' at top of file (after argument parsing if any)"

  local file="$1"
  local content="$(<"$file")"

  # Skip if icons-load-definitions is already present
  [[ "$content" =~ 'icons-load-definitions' ]] && return 0

  # Find first trigger line: ICONS[ subscript or ${(k)ICONS} key enumeration
  # Skip comment lines
  local lineNum=0
  local firstTriggerLine=0
  local line
  for line in "${(@f)content}"; do
    (( ++lineNum ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    if [[ "$line" =~ 'ICONS\[' || "$line" =~ '\$\{(\([^)]*\))?ICONS\}?' ]]; then
      firstTriggerLine=$lineNum
      break
    fi
  done

  # No trigger lines found → no violation
  [[ $firstTriggerLine -eq 0 ]] && return 0

  printf '%s%s%s%serror%s%d%s%s\n' \
    "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$firstTriggerLine" "$_SEP" "$msg"
}
