# Custom Rule: zshLintRule_noFieldSubstring
# Forbids %%▮ and ##*▮ substring extraction; prefer array splitting
# Rule Output: file▮noFieldSubstring▮error▮line▮message
# zsh-lint disable-file=noFieldSubstring
# shellcheck disable=SC2016
function zshLintRule_noFieldSubstring() {
  local code='noFieldSubstring'
  local msg='Use array splitting: local -a split=(${(@s/▮/)var}) instead of %%▮ / ##*▮'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line

  for line in "${(@f)content}"; do
    (( ++lineno ))
    # Skip comments
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    # Only flag lines containing %%▮ or ##▮ (with or without wildcards)
    [[ ! "$line" =~ '%%▮|##\*?▮' ]] && continue
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
