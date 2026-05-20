@test "as argument" {
  run text-split "one, two" ", "
  [ "${lines[0]}" = "one" ]
  [ "${lines[1]}" = "two" ]
}

@test "piped in" {
  run bash -c 'echo "one, two" | text-split ", "'
  [ "${lines[0]}" = "one" ]
  [ "${lines[1]}" = "two" ]
}

