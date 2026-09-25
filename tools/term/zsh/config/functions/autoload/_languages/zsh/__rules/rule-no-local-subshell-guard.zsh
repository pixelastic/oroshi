# Custom Rule: zshLintRule_noLocalSubshellGuard
# Detects || true inside $(...) on local lines; local masks the exit code so the guard is redundant
# Rule Output: file▮noLocalSubshellGuard▮error▮line▮message
# shellcheck disable=SC2016
function zshLintRule_noLocalSubshellGuard() {
  local code='noLocalSubshellGuard'
  local msg='local masks exit code of $(); remove || true'
  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line

  for line in "${(@f)content}"; do
    (( ++lineno ))
    # Skip comments
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    # Only local declarations
    [[ ! "$line" =~ ^[[:space:]]*'local'[[:space:]] ]] && continue
    # Must contain $( ... || true ... )
    [[ ! "$line" =~ '\$\(.*\|\|[[:space:]]*true.*\)' ]] && continue

    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
