# Custom Rule: zshlintRule_noExternalBasename
# Detects $(basename/dirname/realpath ...) subshell calls; prefer :t/:h/:a ZSH modifiers
# Rule Output: file▮noExternalBasename▮error▮line▮message
# shellcheck disable=SC2016
zshlintRule_noExternalBasename() {
  local code='noExternalBasename'
  local msg='Prefer :t/:h/:a modifiers over $(basename/dirname/realpath)'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line

  for line in "${(@f)content}"; do
    (( ++lineno ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    [[ ! "$line" =~ '\$\((basename|dirname|realpath)[[:space:](]' ]] && continue
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
