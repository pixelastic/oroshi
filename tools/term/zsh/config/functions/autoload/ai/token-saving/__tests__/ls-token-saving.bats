bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_disable_worktree_aware

  # Fixture directory with a known mtime
  local fixture="$BATS_TMP_DIR/fixture"
  mkdir --parents "$fixture/subdir" "$BATS_TMP_DIR/other"
  echo "hello" > "$fixture/plain.txt"
  printf '#!/bin/sh\n' > "$fixture/script.sh"
  chmod +x "$fixture/script.sh"
  head --bytes=5000 /dev/zero > "$fixture/big.bin"
  ln --symbolic plain.txt "$fixture/link"
  touch "$fixture/.hidden"
  touch "$BATS_TMP_DIR/other/other.txt"
  touch --date=2001-02-03 "$fixture"/* "$fixture"/.hidden "$BATS_TMP_DIR/other/other.txt"
}

@test "lists each entry name" {
  bats_run_zsh "cd '$BATS_TMP_DIR/fixture' && ls-token-saving -la"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"plain.txt"* ]]
  [[ "$output" == *"big.bin"* ]]
}

@test "marks directories with a trailing slash" {
  bats_run_zsh "cd '$BATS_TMP_DIR/fixture' && ls-token-saving -la"
  [[ "$output" == *"subdir/"* ]]
}

@test "shows symlink targets" {
  bats_run_zsh "cd '$BATS_TMP_DIR/fixture' && ls-token-saving -la"
  [[ "$output" == *"link -> plain.txt"* ]]
}

@test "shows human-readable sizes" {
  bats_run_zsh "cd '$BATS_TMP_DIR/fixture' && ls-token-saving -la"
  [[ "$output" == *"4.9K big.bin"* ]]
}

@test "marks executable files" {
  bats_run_zsh "cd '$BATS_TMP_DIR/fixture' && ls-token-saving -la"
  [[ "$output" == *"script.sh*"* ]]
}

@test "hides permissions, owner, group and date" {
  bats_run_zsh "cd '$BATS_TMP_DIR/fixture' && ls-token-saving -la"
  [[ "$output" != *"rw-"* ]]
  [[ "$output" != *"$(id --user --name)"* ]]
  [[ "$output" != *"$(id --group --name)"* ]]
  [[ "$output" != *"2001"* ]]
  [[ "$output" != *"Feb"* ]]
}

@test "omits ., .. and the total line" {
  bats_run_zsh "cd '$BATS_TMP_DIR/fixture' && ls-token-saving -la"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *"total"* ]]
  local line
  for line in "${lines[@]}"; do
    [[ "$line" != *" ./" ]]
    [[ "$line" != *" ../" ]]
  done
}

@test "includes hidden entries when -a is passed" {
  bats_run_zsh "cd '$BATS_TMP_DIR/fixture' && ls-token-saving -la"
  [[ "$output" == *".hidden"* ]]
}

@test "hides hidden entries when -a is not passed" {
  bats_run_zsh "cd '$BATS_TMP_DIR/fixture' && ls-token-saving -l"
  [[ "$output" != *".hidden"* ]]
}

@test "lists several paths when several are passed" {
  bats_run_zsh "cd '$BATS_TMP_DIR' && ls-token-saving -la fixture other"
  [[ "$output" == *"fixture:"* ]]
  [[ "$output" == *"other:"* ]]
  [[ "$output" == *"plain.txt"* ]]
  [[ "$output" == *"other.txt"* ]]
}

@test "lists file arguments" {
  bats_run_zsh "cd '$BATS_TMP_DIR/fixture' && ls-token-saving -la plain.txt"
  [[ "$output" == *"6 plain.txt"* ]]
}

@test "prints the recovery footer" {
  bats_run_zsh "cd '$BATS_TMP_DIR/fixture' && ls-token-saving -la"
  [[ "$output" == *"[token-saving: set OROSHI_DISABLE_TOKEN_SAVING=1 for raw output]" ]]
}

@test "exits non-zero for a missing path" {
  bats_run_zsh "ls-token-saving -la '$BATS_TMP_DIR/missing'"
  [[ "$status" -ne 0 ]]
}

@test "runs ls unchanged when OROSHI_DISABLE_TOKEN_SAVING=1" {
  bats_run_zsh "cd '$BATS_TMP_DIR/fixture' && OROSHI_DISABLE_TOKEN_SAVING=1 ls-token-saving -la"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"total"* ]]
  [[ "$output" == *"rw-"* ]]
  [[ "$output" != *"token-saving"* ]]
}
