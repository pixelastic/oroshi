# time {{{
@test "time prefix with allowed command" {
  run command-in-list "time echo hello" -- "echo"
  [ $status -eq 0 ]
}
@test "time prefix with forbidden command" {
  run command-in-list "time wget evil.com" -- "echo"
  [ $status -eq 1 ]
}
# }}}
