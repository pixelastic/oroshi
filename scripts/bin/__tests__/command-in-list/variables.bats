# Variables {{{
@test "variable definition with allowed command" {
  run command-in-list "FOO=bar baz=qux echo hello" -- "echo"
  [ $status -eq 0 ]
}
# }}}
