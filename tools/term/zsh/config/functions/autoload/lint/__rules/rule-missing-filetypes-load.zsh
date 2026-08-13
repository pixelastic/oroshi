# Custom Rule: zshLintRule_missingFiletypesLoad
# Detects functions/scripts that access $FILETYPES[] without calling filetypes-load-definitions
# Rule Output: file▮missingFiletypesLoad▮error▮line▮message
function zshLintRule_missingFiletypesLoad() {
  local code='missingFiletypesLoad'
  local msg="add 'filetypes-load-definitions' at top of file (after argument parsing if any)"

  local file="$1"
  local content="$(<"$file")"

  # Skip if filetypes-load-definitions is already present
  [[ "$content" =~ 'filetypes-load-definitions' ]] && return 0

  # Find first trigger line: FILETYPES[ subscript or ${(k)FILETYPES} key enumeration
  # Skip comment lines
  local lineNum=0
  local firstTriggerLine=0
  local line
  for line in "${(@f)content}"; do
    (( ++lineNum ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    if [[ "$line" =~ '\$\{?FILETYPES\[' || "$line" =~ '\$\{(\([^)]*\))?FILETYPES\}?' ]]; then
      firstTriggerLine=$lineNum
      break
    fi
  done

  # No trigger lines found → no violation
  [[ $firstTriggerLine -eq 0 ]] && return 0

  printf '%s%s%s%serror%s%d%s%s\n' \
    "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$firstTriggerLine" "$_SEP" "$msg"
}
