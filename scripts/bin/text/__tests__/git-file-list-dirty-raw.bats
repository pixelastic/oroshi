bats_load_library 'helper'

# Override run_zsh_fn to load functions from the worktree, not .oroshi
run_zsh_fn() {
  local func="${1}"
  local worktreeFnDir
  worktreeFnDir="$(realpath "${BATS_TEST_DIRNAME}/../../../../tools/term/zsh/config/functions/autoload/git/file")"
  shift
  run zsh -c "fpath=(\"${worktreeFnDir}\" \${(s/:/)FPATH}); autoload -Uz ${func}; ${func} \"\$@\"" -- "$@"
}

setup() {
  bats_tmp_dir
  export TMP_DIRECTORY="$BATS_TMP_DIR"
  git init "$TMP_DIRECTORY/my-repo"
  cd "$TMP_DIRECTORY/my-repo"
  git config user.email "test@test.com"
  git config user.name "Test"
  echo "hello" > tracked.txt
  git add tracked.txt
  git commit -m "init"
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "returns M:filepath for a modified tracked file" {
  cd "$TMP_DIRECTORY/my-repo"
  echo "change" >> tracked.txt
  run_zsh_fn git-file-list-dirty-raw
  [ "$status" -eq 0 ]
  [[ "$output" == *"M:tracked.txt"* ]]
}

@test "returns A:filepath for a new untracked file" {
  cd "$TMP_DIRECTORY/my-repo"
  echo "new" > untracked.txt
  run_zsh_fn git-file-list-dirty-raw
  [ "$status" -eq 0 ]
  [[ "$output" == *"A:untracked.txt"* ]]
}

@test "returns D:filepath for a deleted tracked file" {
  cd "$TMP_DIRECTORY/my-repo"
  rm tracked.txt
  run_zsh_fn git-file-list-dirty-raw
  [ "$status" -eq 0 ]
  [[ "$output" == *"D:tracked.txt"* ]]
}

@test "returns empty output for a clean directory" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-file-list-dirty-raw
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "accepts a path argument and lists dirty files in that path" {
  export OROSHI_WORKTREES_DIR="$TMP_DIRECTORY/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR"
  cd "$TMP_DIRECTORY/my-repo"
  git worktree add "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" -b fix/bug
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  echo "change" >> tracked.txt
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-file-list-dirty-raw "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  [ "$status" -eq 0 ]
  [[ "$output" == *"M:tracked.txt"* ]]
}

@test "returns empty output for a clean directory with path arg" {
  export OROSHI_WORKTREES_DIR="$TMP_DIRECTORY/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR"
  cd "$TMP_DIRECTORY/my-repo"
  git worktree add "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" -b fix/bug
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-file-list-dirty-raw "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
