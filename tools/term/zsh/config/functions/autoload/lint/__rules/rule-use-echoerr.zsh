# Custom Rule: zshLintRule_useEchoerr
# Detects echo ... >&2; prefer echoerr
# Rule Output: file▮useEchoerr▮error▮line▮message
# shellcheck disable=SC2016
function zshLintRule_useEchoerr() {
  local code='useEchoerr'
  # zsh-lint disable=useEchoerr
  local msg='Use `echoerr` instead of `echo ... >&2`'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line

  for line in "${(@f)content}"; do
    (( ++lineno ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    [[ ! "$line" =~ '(^|[[:space:]])echo.*1?>&2' ]] && continue
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
