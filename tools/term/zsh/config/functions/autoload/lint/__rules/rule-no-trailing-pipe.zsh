# Custom Rule: zshLintRule_noTrailingPipe
# Detects pipe at end of line; prefer Google Shell Style with pipe at start of next line
#
# Bad:
#   cat foo |
#     grep bar
#
# Good:
#   cat foo \
  #     | grep bar
#
# Rule Output: file▮noTrailingPipe▮error▮line▮message
# shellcheck disable=SC2016
function zshLintRule_noTrailingPipe() {
  local code='noTrailingPipe'
  local msg='Trailing pipe: move | to start of next line (Google Shell Style)'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line

  for line in "${(@f)content}"; do
    (( ++lineno ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    [[ ! "$line" =~ ' \|[[:space:]]*$' ]] && continue
    # Exclude || (logical OR)
    [[ "$line" =~ '\|\|[[:space:]]*$' ]] && continue
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
