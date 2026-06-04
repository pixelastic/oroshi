# Custom Rule: zshLintRule_noOrGuard
# Detects [[ ]] || return/exit/continue; prefer [[ ! ]] && return/exit/continue
# Rule Output: file▮noOrGuard▮error▮line▮message
# shellcheck disable=SC2016
zshLintRule_noOrGuard() {
  local code='noOrGuard'
  # zsh-lint-disable noOrGuard
  local msg='Prefer [[ ! condition ]] && return over [[ condition ]] || return'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line

  for line in "${(@f)content}"; do
    (( ++lineno ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    [[ ! "$line" =~ '\]\][[:space:]]*\|\|[[:space:]]*(return|exit|continue)' ]] && continue
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
