# Custom Rule: zshlintRule_singleEqualsInTest
# Detects single = used for string comparison inside [[ ]]; prefer ==
# Rule Output: file▮90006▮style▮line▮message
# shellcheck disable=SC2016
zshlintRule_singleEqualsInTest() {
  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line

  for line in "${(@f)content}"; do
    (( ++lineno ))
    [[ "$line" =~ ^[[:space:]]*'#' ]] && continue
    [[ "$line" =~ '\[\[.*[[:space:]]=[[:space:]]' ]] || continue
    printf '%s%s90006%sstyle%s%d%sPrefer == over = for string comparison in [[ ]]\n' \
      "$file" "$_SEP" "$_SEP" "$_SEP" "$lineno" "$_SEP"
  done
}
