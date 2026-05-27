bats_load_library 'helper'

# --- Basic ---

@test "multi-word sentence" {
  bats_run_function slugify "The Eternal Obelisk"
  [ "$output" = "theEternalObelisk" ]
}

@test "url with slashes and dots" {
  bats_run_function slugify "example.com/path"
  [ "$output" = "exampleComPath" ]
}

# --- Single separator types ---

@test "dot separator" {
  bats_run_function slugify "foo.bar"
  [ "$output" = "fooBar" ]
}

@test "dash separator" {
  bats_run_function slugify "foo-bar"
  [ "$output" = "fooBar" ]
}

@test "underscore separator" {
  bats_run_function slugify "foo_bar"
  [ "$output" = "fooBar" ]
}

# --- Mixed / edge separators ---

@test "mixed separators" {
  bats_run_function slugify "foo.bar-baz/qux"
  [ "$output" = "fooBarBazQux" ]
}

@test "consecutive separators collapsed" {
  bats_run_function slugify "foo---bar"
  [ "$output" = "fooBar" ]
}

@test "leading and trailing separators stripped" {
  bats_run_function slugify "-foo-bar-"
  [ "$output" = "fooBar" ]
}

# --- Numbers ---

@test "embedded number preserved" {
  bats_run_function slugify "h264 codec"
  [ "$output" = "h264Codec" ]
}

@test "leading number preserved" {
  bats_run_function slugify "404 error"
  [ "$output" = "404Error" ]
}

# --- No-op cases ---

@test "single lowercase word unchanged" {
  bats_run_function slugify "foo"
  [ "$output" = "foo" ]
}

@test "already camelCase preserved" {
  bats_run_function slugify "fooBar"
  [ "$output" = "fooBar" ]
}

# --- ALL CAPS ---

@test "all caps words are lowercased" {
  bats_run_function slugify "FOO BAR"
  [ "$output" = "fooBar" ]
}

# --- Edge cases ---

@test "empty string returns empty" {
  bats_run_function slugify ""
  [ "$output" = "" ]
}

@test "only special chars returns empty" {
  bats_run_function slugify "---"
  [ "$output" = "" ]
}
