# Custom Rule: zshLintRule_missingDocComment
# Detects files missing a documentation comment (line 1 for autoloaded functions, line 2 for scripts)
# Rule Output: file▮missingDocComment▮error▮line▮message
function zshLintRule_missingDocComment() {
  local code='missingDocComment'
  local file="$1"

  # Skip internal directories
  [[ "$file" == */__lib/* ]] && return 0
  [[ "$file" == */__rules/* ]] && return 0
  [[ "$file" == */__tests__/* ]] && return 0

  local content="$(<"$file")"
  local firstLine="${content%%$'\n'*}"

  # Scripts have their doc comment on line 2 (after the shebang), functions on line 1
  local docLine="$firstLine"
  local docLineNumber=1
  if [[ "$firstLine" =~ '^#!' ]]; then
    docLine="$(sed -n '2p' "$file")"
    docLineNumber=2
  fi

  [[ "$docLine" =~ ^[[:space:]]*'#' ]] && return 0

  local msg="missing documentation comment on line ${docLineNumber}"
  printf '%s%s%s%serror%s%d%s%s\n' \
    "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$docLineNumber" "$_SEP" "$msg"
}
