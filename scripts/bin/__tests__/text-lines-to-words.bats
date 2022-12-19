@test "as argument" {
  run text-lines-to-words "one\ntwo and three"
  [ "$output" = 'one two\ and\ three' ]
}

@test "piped in" {
  run bash -c 'echo "one\ntwo and three" | text-lines-to-words'
  [ "$output" = 'one two\ and\ three' ]
}

@test "with double quotes" {
  run text-lines-to-words 'one\ntwo "and three"'
  [ "$output" = 'one two\ \"and\ three\"' ]
}

@test "with single quotes" {
  run text-lines-to-words "one\ntwo 'and three'"
  [ "$output" = "one two\ \'and\ three\'" ]
}
