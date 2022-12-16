@test "as argument" {
  run text-select-line "one\ntwo" 1
  [ "$output" = "one" ]
}

@test "piped in" {
  run bash -c 'echo "one\ntwo" | text-select-line 1'
  [ "$output" = "one" ]
}

