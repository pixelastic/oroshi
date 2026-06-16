bats_load_library 'helper'

# --- Default truncation (maxDisplay=4) ---

setup() {
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

@test "path longer than maxDisplay truncated to first/…/penultimate/last" {
  bats_run_zsh "simplify-path 'a/b/c/d/e'"
  [ "$output" = "a/…/d/e" ]
}

@test "path at maxDisplay unchanged" {
  bats_run_zsh "simplify-path 'a/b/c/d'"
  [ "$output" = "a/b/c/d" ]
}

@test "path shorter than maxDisplay unchanged" {
  bats_run_zsh "simplify-path 'a/b'"
  [ "$output" = "a/b" ]
}

@test "single segment unchanged" {
  bats_run_zsh "simplify-path 'a'"
  [ "$output" = "a" ]
}

# --- Custom maxDisplay ---

@test "maxDisplay=5 on 6-segment path yields first second/…/penultimate/last" {
  bats_run_zsh "simplify-path 'a/b/c/d/e/f' 5"
  [ "$output" = "a/b/…/e/f" ]
}

@test "maxDisplay=6 on 7-segment path yields first second/…/antepenultimate/penultimate/last" {
  bats_run_zsh "simplify-path 'a/b/c/d/e/f/g' 6"
  [ "$output" = "a/b/…/e/f/g" ]
}

# --- Clamping (values < 4 silently become 4) ---

@test "maxDisplay=3 silently falls back to 4" {
  bats_run_zsh "simplify-path 'a/b/c/d/e' 3"
  [ "$output" = "a/…/d/e" ]
}

# --- Slashes ---

@test "leading slash preserved" {
  bats_run_zsh "simplify-path '/a/b/c/d/e'"
  [ "$output" = "/a/…/d/e" ]
}

@test "trailing slash preserved" {
  bats_run_zsh "simplify-path 'a/b/c/d/e/'"
  [ "$output" = "a/…/d/e/" ]
}

# --- Home replacement ---

@test "home prefix replaced with tilde" {
  bats_run_zsh "simplify-path $HOME/a/b"
  # shellcheck disable=SC2088
  [ "$output" = '~/a/b' ]
}

@test "home prefix replaced with tilde on truncated path" {
  bats_run_zsh "simplify-path $HOME/a/b/c/d"
  # shellcheck disable=SC2088
  [ "$output" = '~/…/c/d' ]
}

# --- --reply flag ---

@test "--reply does not echo" {
  bats_run_zsh "simplify-path --reply 'a/b/c/d/e'"
  [ "$output" = "" ]
}

@test "--reply sets REPLY to simplified path" {
  local script="$BATS_TMP_DIR/reply-test.zsh"
  printf 'simplify-path --reply "a/b/c/d/e"\necho "$REPLY"\n' >"$script"
  bats_run_zsh "source $script"
  [ "$output" = "a/…/d/e" ]
}
