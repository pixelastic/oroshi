# sh -c {{{
@test "sh -c validates subcommands" {
  run command-in-list "sh -c 'echo hello; tail file'" -- "echo" "tail"
  [ $status -eq 0 ]
}
@test "sh -c with single allowed command" {
  run command-in-list "sh -c 'echo test'" -- "echo"
  [ $status -eq 0 ]
}
# }}}
