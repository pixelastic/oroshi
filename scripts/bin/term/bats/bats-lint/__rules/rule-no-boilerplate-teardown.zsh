# Custom Rule: batsLintRule_noBoilerplateTeardown
# Detects teardown() whose body is solely bats_cleanup — the helper provides a default
# Rule Output: file▮code▮error▮line▮message
# Usage:
#   source rule-no-boilerplate-teardown.zsh
#   batsLintRule_noBoilerplateTeardown <file.bats>
batsLintRule_noBoilerplateTeardown() {
  local code='noBoilerplateTeardown'
  local msg='Remove boilerplate teardown — the helper provides a default'

  local file="$1"
  local content="$(<"$file")"
  local -a lines=("${(@f)content}")
  local total=${#lines}
  local i=0

  while (( i < total )); do
    (( ++i ))
    local line="${lines[$i]}"

    # One-liner: teardown() { bats_cleanup; }
    if [[ "$line" =~ '^[[:space:]]*teardown\(\)[[:space:]]*\{[[:space:]]*bats_cleanup[[:space:]]*;?[[:space:]]*\}' ]]; then
      printf '%s%s%s%serror%s%d%s%s\n' \
        "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$i" "$_SEP" "$msg"
      continue
    fi

    # Not a multiline teardown opener
    [[ ! "$line" =~ '^[[:space:]]*teardown\(\)[[:space:]]*\{[[:space:]]*$' ]] && continue

    local teardownLine=$i
    local bodyStatements=0
    local onlyBatsCleanup=1

    # Scan body lines until closing brace
    while (( i < total )); do
      (( ++i ))
      line="${lines[$i]}"
      # Closing brace
      [[ "$line" =~ '^[[:space:]]*\}[[:space:]]*$' ]] && break
      # Skip blank lines
      [[ "$line" =~ '^[[:space:]]*$' ]] && continue
      (( ++bodyStatements ))
      # Any statement other than bats_cleanup clears the flag
      [[ ! "$line" =~ '^[[:space:]]*bats_cleanup[[:space:]]*;?[[:space:]]*$' ]] && onlyBatsCleanup=0
    done

    # Not a boilerplate teardown
    [[ $bodyStatements != "1" ]] && continue
    [[ $onlyBatsCleanup != "1" ]] && continue
    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$teardownLine" "$_SEP" "$msg"
  done
}
