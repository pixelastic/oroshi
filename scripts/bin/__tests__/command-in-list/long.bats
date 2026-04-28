# Long commands {{{
@test "allowed long commands" {
  run command-in-list "git log && echo 'hello world" -- "echo" "git log"
  [ $status -eq 0 ]
}
@test "allowed subcommand" {
  run command-in-list "git commit && echo 'hello world" -- "echo" "git log"
  [ $status -eq 1 ]
}
# }}}
