# Custom Rule: zshLintRule_noChainedAnd
# Detects [[ ]] && cmd && cmd — prefer if/then/fi for chained commands
# Rule Output: file▮noChainedAnd▮error▮line▮message
# shellcheck disable=SC2016
zshLintRule_noChainedAnd() {
  local code='noChainedAnd'
  # zsh-lint disable=noChainedAnd
  local msg='Prefer if/then/fi over chained [[ cond ]] && cmd1 && cmd2'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line

  for line in "${(@f)content}"; do
    (( ++lineno ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    [[ ! "$line" =~ '\]\].*&&.*&&' ]] && continue
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
