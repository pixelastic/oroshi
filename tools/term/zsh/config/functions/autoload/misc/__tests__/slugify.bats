bats_load_library 'helper'

# --- Basic ---

setup() {
  CURRENT="$BATS_TEST_DIRNAME/../slugify"
}

@test "multi-word sentence" {
  bats_run_zsh "$CURRENT" "The Eternal Obelisk"
  [ "$output" = "theEternalObelisk" ]
}

@test "url with slashes and dots" {
  bats_run_zsh "$CURRENT" "example.com/path"
  [ "$output" = "exampleComPath" ]
}

# --- Single separator types ---

@test "dot separator" {
  bats_run_zsh "$CURRENT" "foo.bar"
  [ "$output" = "fooBar" ]
}

@test "dash separator" {
  bats_run_zsh "$CURRENT" "foo-bar"
  [ "$output" = "fooBar" ]
}

@test "underscore separator" {
  bats_run_zsh "$CURRENT" "foo_bar"
  [ "$output" = "fooBar" ]
}

# --- Mixed / edge separators ---

@test "mixed separators" {
  bats_run_zsh "$CURRENT" "foo.bar-baz/qux"
  [ "$output" = "fooBarBazQux" ]
}

@test "consecutive separators collapsed" {
  bats_run_zsh "$CURRENT" "foo---bar"
  [ "$output" = "fooBar" ]
}

@test "leading and trailing separators stripped" {
  bats_run_zsh "$CURRENT" "-foo-bar-"
  [ "$output" = "fooBar" ]
}

# --- Numbers ---

@test "embedded number preserved" {
  bats_run_zsh "$CURRENT" "h264 codec"
  [ "$output" = "h264Codec" ]
}

@test "leading number preserved" {
  bats_run_zsh "$CURRENT" "404 error"
  [ "$output" = "404Error" ]
}

# --- No-op cases ---

@test "single lowercase word unchanged" {
  bats_run_zsh "$CURRENT" "foo"
  [ "$output" = "foo" ]
}

@test "already camelCase preserved" {
  bats_run_zsh "$CURRENT" "fooBar"
  [ "$output" = "fooBar" ]
}

# --- ALL CAPS ---

@test "all caps words are lowercased" {
  bats_run_zsh "$CURRENT" "FOO BAR"
  [ "$output" = "fooBar" ]
}

# --- Edge cases ---

@test "empty string returns empty" {
  bats_run_zsh "$CURRENT" ""
  [ "$output" = "" ]
}

@test "only special chars returns empty" {
  bats_run_zsh "$CURRENT" "---"
  [ "$output" = "" ]
}
