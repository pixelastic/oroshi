bats_load_library 'helper'

# --- Truncation ---

@test "long path truncated to first/…/n-1/last" {
  bats_run_function simplify-path "a/b/c/d/e"
  [ "$output" = "a/…/d/e" ]
}

# --- No-op (at or under threshold) ---

@test "path at max depth unchanged" {
  bats_run_function simplify-path "a/b/c/d"
  [ "$output" = "a/b/c/d" ]
}

@test "short path unchanged" {
  bats_run_function simplify-path "a/b"
  [ "$output" = "a/b" ]
}

@test "single segment unchanged" {
  bats_run_function simplify-path "a"
  [ "$output" = "a" ]
}

# --- Slashes ---

@test "leading slash preserved" {
  bats_run_function simplify-path "/a/b/c/d/e"
  [ "$output" = "/a/…/d/e" ]
}

@test "trailing slash preserved" {
  bats_run_function simplify-path "a/b/c/d/e/"
  [ "$output" = "a/…/d/e/" ]
}

# --- Home replacement ---

@test "home prefix replaced with tilde" {
  bats_run_function simplify-path "$HOME/a/b"
  [ "$output" = "~/a/b" ]
}

# --- Custom maxDepth ---

@test "custom maxDepth=2 truncates 3-segment path" {
  bats_run_function simplify-path "a/b/c" 2
  [ "$output" = "a/…/b/c" ]
}

@test "custom maxDepth=2 keeps 2-segment path unchanged" {
  bats_run_function simplify-path "a/b" 2
  [ "$output" = "a/b" ]
}

# --- --reply flag ---

@test "--reply does not echo" {
  bats_run_function simplify-path --reply "a/b/c/d/e"
  [ "$output" = "" ]
}

@test "--reply sets REPLY to simplified path" {
  run zsh -c 'simplify-path --reply "a/b/c/d/e"; echo "$REPLY"'
  [ "$output" = "a/…/d/e" ]
}
