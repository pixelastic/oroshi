bats_load_library 'helper'

setup() {
  bats_tmp_dir
  mkdir -p "$BATS_TMP_DIR/src/__tests__"
  echo 'echo foo' > "$BATS_TMP_DIR/src/foo.zsh"
  echo '@test "foo" { true; }' > "$BATS_TMP_DIR/src/__tests__/foo.bats"
  echo 'echo bar' > "$BATS_TMP_DIR/src/bar.zsh"
  echo '@test "bar" { true; }' > "$BATS_TMP_DIR/src/__tests__/bar.bats"

  # Record each bats call, one argument per line
  bats() { printf '%s\n' "$@" >> "$BATS_TMP_DIR/calls.txt"; }
  bats_mock bats
}

# ─── RETURN EARLY ─────────────────────────────────────────────────────────────

@test "exits 0 with no arguments, without calling bats" {
  bats_run_zsh "zsh-test"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
  [[ ! -f "$BATS_TMP_DIR/calls.txt" ]]
}

@test "exits 0 without calling bats when source has no test" {
  echo 'echo baz' > "$BATS_TMP_DIR/src/baz.zsh"

  bats_run_zsh "zsh-test $BATS_TMP_DIR/src/baz.zsh"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/calls.txt" ]]
}

@test "exits 0 without calling bats when file is not ZSH" {
  echo 'console.log(1)' > "$BATS_TMP_DIR/src/foo.js"

  bats_run_zsh "zsh-test $BATS_TMP_DIR/src/foo.js"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/calls.txt" ]]
}

# ─── RESOLUTION ───────────────────────────────────────────────────────────────

@test "runs the bats test of a ZSH source file" {
  bats_run_zsh "zsh-test $BATS_TMP_DIR/src/foo.zsh"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" = "$BATS_TMP_DIR/src/__tests__/foo.bats" ]]
}

@test "runs a bats file directly" {
  bats_run_zsh "zsh-test $BATS_TMP_DIR/src/__tests__/foo.bats"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" = "$BATS_TMP_DIR/src/__tests__/foo.bats" ]]
}

@test "runs a test once when both source and test file are given" {
  bats_run_zsh "zsh-test $BATS_TMP_DIR/src/foo.zsh $BATS_TMP_DIR/src/__tests__/foo.bats"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" = "$BATS_TMP_DIR/src/__tests__/foo.bats" ]]
}

@test "runs all tests in a single bats call" {
  bats_run_zsh "zsh-test $BATS_TMP_DIR/src/foo.zsh $BATS_TMP_DIR/src/bar.zsh"
  [[ "$status" -eq 0 ]]
  local expected="$BATS_TMP_DIR/src/__tests__/foo.bats"$'\n'"$BATS_TMP_DIR/src/__tests__/bar.bats"
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" = "$expected" ]]
}

# ─── DIRECTORY ────────────────────────────────────────────────────────────────

@test "expands a directory and runs every resolved test once" {
  bats_run_zsh "zsh-test $BATS_TMP_DIR/src/"
  [[ "$status" -eq 0 ]]
  local calls="$(sort "$BATS_TMP_DIR/calls.txt")"
  local expected="$BATS_TMP_DIR/src/__tests__/bar.bats"$'\n'"$BATS_TMP_DIR/src/__tests__/foo.bats"
  [[ "$calls" = "$expected" ]]
}

# ─── EXIT CODE ────────────────────────────────────────────────────────────────

@test "exits non-zero when bats fails" {
  bats() { return 1; }
  bats_mock bats

  bats_run_zsh "zsh-test $BATS_TMP_DIR/src/__tests__/foo.bats"
  [[ "$status" -ne 0 ]]
}
