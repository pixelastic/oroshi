load '../../../../../../../scripts/bin/__tests__/helper'

# --- Basic ---

@test "multi-word sentence" {
  run_zsh_fn slugify "The Eternal Obelisk"
  [ "$output" = "theEternalObelisk" ]
}

@test "url with slashes and dots" {
  run_zsh_fn slugify "example.com/path"
  [ "$output" = "exampleComPath" ]
}

# --- Single separator types ---

@test "dot separator" {
  run_zsh_fn slugify "foo.bar"
  [ "$output" = "fooBar" ]
}

@test "dash separator" {
  run_zsh_fn slugify "foo-bar"
  [ "$output" = "fooBar" ]
}

@test "underscore separator" {
  run_zsh_fn slugify "foo_bar"
  [ "$output" = "fooBar" ]
}

# --- Mixed / edge separators ---

@test "mixed separators" {
  run_zsh_fn slugify "foo.bar-baz/qux"
  [ "$output" = "fooBarBazQux" ]
}

@test "consecutive separators collapsed" {
  run_zsh_fn slugify "foo---bar"
  [ "$output" = "fooBar" ]
}

@test "leading and trailing separators stripped" {
  run_zsh_fn slugify "-foo-bar-"
  [ "$output" = "fooBar" ]
}

# --- Numbers ---

@test "embedded number preserved" {
  run_zsh_fn slugify "h264 codec"
  [ "$output" = "h264Codec" ]
}

@test "leading number preserved" {
  run_zsh_fn slugify "404 error"
  [ "$output" = "404Error" ]
}

# --- No-op cases ---

@test "single lowercase word unchanged" {
  run_zsh_fn slugify "foo"
  [ "$output" = "foo" ]
}

@test "already camelCase preserved" {
  run_zsh_fn slugify "fooBar"
  [ "$output" = "fooBar" ]
}

# --- ALL CAPS ---

@test "all caps words are lowercased" {
  run_zsh_fn slugify "FOO BAR"
  [ "$output" = "fooBar" ]
}

# --- Edge cases ---

@test "empty string returns empty" {
  run_zsh_fn slugify ""
  [ "$output" = "" ]
}

@test "only special chars returns empty" {
  run_zsh_fn slugify "---"
  [ "$output" = "" ]
}
