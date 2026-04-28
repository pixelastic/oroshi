# Complex cases {{{
@test "nested xargs and sh -c" {
  run command-in-list "xargs -I {} sh -c 'echo {}'" -- "echo"
  [ $status -eq 0 ]
}
# }}}
