# Custom Rule: batsLintRule_preferBatchMock
# Detects multiple bats_mock calls in the same @test block
# Rule Output: file▮code▮error▮line▮message
# Usage:
#   source rule-prefer-batch-mock.zsh
#   batsLintRule_preferBatchMock <file.bats>
batsLintRule_preferBatchMock() {
  local code='preferBatchMock'
  local msg='Merge all bats_mock calls into one: bats_mock fn1 fn2 ...'

  local file="$1"
  local content="$(<"$file")"
  local lineno=0
  local line
  local inTest=0
  local mockCount=0

  for line in "${(@f)content}"; do
    (( ++lineno ))

    if [[ "$line" =~ '^@test' || "$line" =~ '^setup\(\)' ]]; then
      inTest=1
      mockCount=0
      continue
    fi

    if [[ $inTest == "1" && "$line" =~ '^}' ]]; then
      inTest=0
      mockCount=0
      continue
    fi

    [[ $inTest != "1" ]] && continue
    [[ ! "$line" =~ '^[[:space:]]+bats_mock ' ]] && continue

    (( ++mockCount ))
    [[ $mockCount -le 1 ]] && continue

    printf '%s%s%s%serror%s%d%s%s\n' \
      "$file" "$_SEP" "$code" "$_SEP" "$_SEP" "$lineno" "$_SEP" "$msg"
  done
}
