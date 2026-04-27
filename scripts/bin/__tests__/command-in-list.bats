# Success cases (exit 0)

@test "simple command matches pattern" {
  run command-in-list "git commit -m 'test'" -- "git commit" "echo"
  [ $status -eq 0 ]
}

# Separators

@test "pipe separator with both commands allowed" {
  run command-in-list "echo hello | grep world" -- "echo" "grep"
  [ $status -eq 0 ]
}

@test "double ampersand separator with both commands allowed" {
  run command-in-list "echo hello && echo world" -- "echo"
  [ $status -eq 0 ]
}

@test "double pipe separator with both commands allowed" {
  run command-in-list "echo hello || echo world" -- "echo"
  [ $status -eq 0 ]
}

@test "semicolon separator with both commands allowed" {
  run command-in-list "echo hello; echo world" -- "echo"
  [ $status -eq 0 ]
}

@test "xargs extracts and validates nested command" {
  run command-in-list "find . | xargs grep foo" -- "find" "grep"
  [ $status -eq 0 ]
}

@test "xargs with flags" {
  run command-in-list "xargs -n 10 cat" -- "cat" "echo"
  [ $status -eq 0 ]
}

@test "sh -c validates subcommands" {
  run command-in-list "sh -c 'echo hello; tail file'" -- "echo" "tail"
  [ $status -eq 0 ]
}

@test "nested xargs and sh -c" {
  run command-in-list "xargs -I {} sh -c 'echo {}'" -- "echo"
  [ $status -eq 0 ]
}

@test "sh -c with single allowed command" {
  run command-in-list "sh -c 'echo test'" -- "echo"
  [ $status -eq 0 ]
}

# Prefixes

@test "time prefix with allowed command" {
  run command-in-list "time echo hello" -- "echo"
  [ $status -eq 0 ]
}

# Variable definitions

@test "variable definition with allowed command" {
  run command-in-list "FOO=bar echo hello" -- "echo"
  [ $status -eq 0 ]
}

# Xargs edge cases

@test "xargs without arguments" {
  run command-in-list "find . | xargs" -- "find"
  [ $status -eq 0 ]
}

# Failure cases (exit 1)

@test "chained command with disallowed subcommand" {
  run command-in-list "git commit && git push" -- "git commit" "echo"
  [ $status -eq 1 ]
}

@test "xargs with disallowed command" {
  run command-in-list "xargs wget" -- "cat" "echo"
  [ $status -eq 1 ]
}

@test "sh -c with disallowed command" {
  run command-in-list "sh -c 'wget evil'" -- "echo" "tail"
  [ $status -eq 1 ]
}
