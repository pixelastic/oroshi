bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_disable_worktree_aware

  mkdir --parents "$BATS_TMP_DIR/fixture/sub" "$BATS_TMP_DIR/bin"
  touch "$BATS_TMP_DIR/fixture/a.js" "$BATS_TMP_DIR/fixture/sub/b.js"

  # Slow fake find: prints one line, then runs longer than the time limit
  cat > "$BATS_TMP_DIR/bin/find" <<'FAKE'
#!/bin/sh
echo "partial-result"
sleep 5
echo "late-result"
FAKE
  chmod +x "$BATS_TMP_DIR/bin/find"
}

@test "prints the same output as find for a fast search" {
  bats_run_zsh "cd '$BATS_TMP_DIR/fixture' && find-guarded . -name '*.js' | sort"
  [[ "$status" -eq 0 ]]
  [[ "$output" == $'./a.js\n./sub/b.js' ]]
}

@test "prints no marker for a fast search" {
  bats_run_zsh "cd '$BATS_TMP_DIR/fixture' && find-guarded . -name '*.js'"
  [[ "$output" != *"claude-guarded"* ]]
}

@test "keeps the find exit code" {
  bats_run_zsh "find-guarded '$BATS_TMP_DIR/missing'"
  [[ "$status" -eq 1 ]]
}

@test "stops a search longer than 2 seconds and exits 124" {
  bats_run_zsh "PATH='$BATS_TMP_DIR/bin':\$PATH find-guarded . -name '*.js'"
  [[ "$status" -eq 124 ]]
  [[ "$output" != *"late-result"* ]]
}

@test "keeps the output printed before the stop" {
  bats_run_zsh "PATH='$BATS_TMP_DIR/bin':\$PATH find-guarded . -name '*.js'"
  [[ "$output" == *"partial-result"* ]]
}

@test "marks the output as incomplete on stderr and names both ways out" {
  bats_run_zsh "PATH='$BATS_TMP_DIR/bin':\$PATH find-guarded . -name '*.js' 2>&1 >/dev/null"
  [[ "$output" == "[claude-guarded:timeout]"* ]]
  [[ "$output" == *"incomplete"* ]]
  [[ "$output" == *"/usr/bin/find"* ]]
  [[ "$output" == *"Narrow the search"* ]]
}

@test "does not stop a search that runs an action" {
  bats_run_zsh "PATH='$BATS_TMP_DIR/bin':\$PATH find-guarded . -exec echo {} \;"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"late-result"* ]]
}

@test "does not stop a search that deletes" {
  bats_run_zsh "PATH='$BATS_TMP_DIR/bin':\$PATH find-guarded . -name '*.tmp' -delete"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"late-result"* ]]
}
