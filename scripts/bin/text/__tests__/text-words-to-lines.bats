@test "as argument" {
  run text-words-to-lines "one two"
  [ "${lines[0]}" = "one" ]
  [ "${lines[1]}" = "two" ]
}

@test "piped in" {
  run bash -c 'echo "one two" | text-words-to-lines'
  [ "${lines[0]}" = "one" ]
  [ "${lines[1]}" = "two" ]
}

@test "discard whitespace" {
  run text-words-to-lines "   one    two   "
  [ "${lines[0]}" = "one" ]
  [ "${lines[1]}" = "two" ]
}
