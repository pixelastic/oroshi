@test "as argument" {
  run text-remove-empty-lines "\n\none\n\ntwo\n"
  [ "${lines[0]}" = "one" ]
  [ "${lines[1]}" = "two" ]
}

@test "piped in" {
  run bash -c 'echo "\n\none\n\ntwo\n" | text-remove-empty-lines'
  [ "${lines[0]}" = "one" ]
  [ "${lines[1]}" = "two" ]
}

