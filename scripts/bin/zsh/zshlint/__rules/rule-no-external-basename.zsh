# Custom Rule: zshlintRule_noExternalBasename
# Detects $(basename/dirname/realpath ...) subshell calls; prefer :t/:h/:a ZSH modifiers
# Rule Output: file▮90003▮style▮line▮message
# shellcheck disable=SC2016
zshlintRule_noExternalBasename() {
  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line

  for line in "${(@f)content}"; do
    (( ++lineno ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    [[ "$line" =~ '\$\((basename|dirname|realpath)[[:space:](]' ]] || continue
    printf '%s%s90003%sstyle%s%d%sPrefer :t/:h/:a modifiers over $(basename/dirname/realpath)\n' \
      "$file" "$_SEP" "$_SEP" "$_SEP" "$lineno" "$_SEP"
  done
}
