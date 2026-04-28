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

# Variables {{{
@test "variable definition with allowed command" {
  run command-in-list "FOO=bar echo hello" -- "echo"
  [ $status -eq 0 ]
}
# }}}

# xargs {{{
# @test "xargs extracts and validates nested command" {
#   run command-in-list "find . | xargs grep foo" -- "find" "grep"
#   [ $status -eq 0 ]
# }
#
# @test "xargs with flags" {
#   run command-in-list "xargs -n 10 cat" -- "cat" "echo"
#   [ $status -eq 0 ]
# }
# @test "xargs without arguments" {
#   run command-in-list "find . | xargs" -- "find"
#   [ $status -eq 0 ]
# }
# }}}

# sh -c {{{
# @test "sh -c validates subcommands" {
#   run command-in-list "sh -c 'echo hello; tail file'" -- "echo" "tail"
#   [ $status -eq 0 ]
# }
# @test "sh -c with single allowed command" {
#   run command-in-list "sh -c 'echo test'" -- "echo"
#   [ $status -eq 0 ]
# }
# }}}

# while {{{
# }}}

# for {{{
# }}}

# time {{{
@test "time prefix with allowed command" {
  run command-in-list "time echo hello" -- "echo"
  [ $status -eq 0 ]
}
# }}}

# Complex cases {{{
# @test "nested xargs and sh -c" {
#   run command-in-list "xargs -I {} sh -c 'echo {}'" -- "echo"
#   [ $status -eq 0 ]
# }
# }}}

# Failure cases (exit 1)

@test "xargs with disallowed command" {
  run command-in-list "xargs wget" -- "cat" "echo"
  [ $status -eq 1 ]
}

@test "sh -c with disallowed command" {
  run command-in-list "sh -c 'wget evil'" -- "echo" "tail"
  [ $status -eq 1 ]
}
