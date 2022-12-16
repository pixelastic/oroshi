@test "remove spaces before and after" {
  run text-trim "  Hello World  "
  [ "$output" = "Hello World" ]
}
