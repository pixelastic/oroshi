# Separators {{{
@test "|" {
  run command-in-list "echo hello | grep world" -- "echo" "grep"
  [ $status -eq 0 ]
}

@test "&&" {
  run command-in-list "echo hello && grep world" -- "echo" "grep"
  [ $status -eq 0 ]
}

@test "||" {
  run command-in-list "echo hello || grep world" -- "echo" "grep"
  [ $status -eq 0 ]
}

@test ";" {
  run command-in-list "echo hello; grep world" -- "echo" "grep"
  [ $status -eq 0 ]
}

@test "| || && ;" {
  run command-in-list "echo hello | grep world && wget evil || true; pwd" -- "echo" "grep" "true" "pwd"
  [ $status -eq 1 ]
}
# }}}
