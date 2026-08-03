bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Synchronous 3-process chain: bats_run_zsh(zsh) -> bash(middle) -> zsh(leaf)
  # The leaf calls process-tree-raw on itself

  # chain-leaf: zsh that calls process-tree-raw on its own PID
  cat > "$BATS_TMP_DIR/chain-leaf" <<'LEAF'
#!/usr/bin/env zsh
process-tree-raw $$
LEAF

  # chain-middle: bash that calls chain-leaf
  cat > "$BATS_TMP_DIR/chain-middle" <<MIDDLE
#!/usr/bin/env bash
zsh "$BATS_TMP_DIR/chain-leaf"
MIDDLE

  chmod +x "$BATS_TMP_DIR/chain-leaf" \
           "$BATS_TMP_DIR/chain-middle"
}

@test "first line contains zsh (leaf process)" {
  bats_run_zsh "bash $BATS_TMP_DIR/chain-middle"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" =~ ^[0-9]+▮zsh$ ]]
}

@test "second line contains bash (middle process)" {
  bats_run_zsh "bash $BATS_TMP_DIR/chain-middle"
  [[ "$status" -eq 0 ]]
  [[ "${lines[1]}" =~ ^[0-9]+▮bash$ ]]
}

@test "chain walk continues beyond controlled layers" {
  bats_run_zsh "bash $BATS_TMP_DIR/chain-middle"
  [[ "$status" -eq 0 ]]
  # At least 3 entries: leaf + middle + ancestors from bats runtime
  (( ${#lines[@]} >= 3 ))
}

@test "each line matches NUMBER▮NAME format" {
  bats_run_zsh "bash $BATS_TMP_DIR/chain-middle"
  [[ "$status" -eq 0 ]]
  for line in "${lines[@]}"; do
    [[ "$line" =~ ^[0-9]+▮.+$ ]]
  done
}

@test "no line contains PID 1" {
  bats_run_zsh "bash $BATS_TMP_DIR/chain-middle"
  [[ "$status" -eq 0 ]]
  for line in "${lines[@]}"; do
    [[ "$line" != "1▮"* ]]
  done
}

@test "--reply produces no stdout" {
  bats_run_zsh "process-tree-raw --reply $$"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "--reply sets REPLY to ancestor chain" {
  bats_run_zsh "process-tree-raw --reply $$ && echo \$REPLY"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"▮"* ]]
}

@test "defaults to current process when called without arguments" {
  bats_run_zsh "process-tree-raw"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" =~ ^[0-9]+▮.+$ ]]
}

@test "returns 1 for a bogus PID" {
  bats_run_zsh "process-tree-raw 9999999"
  [[ "$status" -eq 1 ]]
}
