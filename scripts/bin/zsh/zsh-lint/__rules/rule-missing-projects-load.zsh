# Custom Rule: zshLintRule_missingProjectsLoad
# Detects functions/scripts that access $PROJECTS[] without calling projects-load-definitions
# Rule Output: file▮missingProjectsLoad▮error▮line▮message
zshLintRule_missingProjectsLoad() {
  local code='missingProjectsLoad'
  local msg="add 'projects-load-definitions' at top of file (after argument parsing if any)"

  local file="$1"
  local content="$(<"$file")"

  # Skip if projects-load-definitions is already present
  [[ "$content" =~ 'projects-load-definitions' ]] && return 0

  # Find first trigger line: PROJECTS[ subscript or ${(k)PROJECTS} key enumeration
  # Skip comment lines
  local lineNum=0
  local firstTriggerLine=0
  local line
  for line in "${(@f)content}"; do
    (( ++lineNum ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    if [[ "$line" =~ '\$\{?PROJECTS\[' || "$line" =~ '\$\{(\([^)]*\))?PROJECTS\}?' ]]; then
      firstTriggerLine=$lineNum
      break
    fi
  done

  # No trigger lines found → no violation
  [[ $firstTriggerLine -eq 0 ]] && return 0

  printf '%s%s%s%serror%s%d%s%s\n' \
    "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$firstTriggerLine" "$_SEP" "$msg"
}
