@test "as argument" {
  run text-substring "Hello" 1 3
  [ "$output" = "ell" ]
}

@test "piped in" {
  run bash -c 'echo "Hello" | text-substring 1 3'
  [ "$output" = "ell" ]
}

@test "negative index" {
  run text-substring "Hello" -3
  [ "$output" = "llo" ]
}

@test "no upper bound" {
  run text-substring "Hello" 1
  [ "$output" = "ello" ]
}
