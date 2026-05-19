load 'helper'

# Override run_zsh_fn to load functions from the worktree, not .oroshi
run_zsh_fn() {
  local func="${1}"
  local worktreeFnDir
  worktreeFnDir="$(realpath "${BATS_TEST_DIRNAME}/../../../config/term/zsh/functions/autoload/git/directory")"
  local worktreeFileFnDir
  worktreeFileFnDir="$(realpath "${BATS_TEST_DIRNAME}/../../../config/term/zsh/functions/autoload/git/file")"
  shift
  run zsh -c "fpath=(\"${worktreeFnDir}\" \"${worktreeFileFnDir}\" \${(s/:/)FPATH}); autoload -Uz ${func}; ${func} \"\$@\"" -- "$@"
}

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"
  git init "$TMP_DIRECTORY/my-repo"
  cd "$TMP_DIRECTORY/my-repo"
  git config user.email "test@test.com"
  git config user.name "Test"
  echo "hello" > tracked.txt
  echo "world" > tracked2.txt
  git add tracked.txt tracked2.txt
  git commit -m "init"
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "returns 0 for a clean worktree" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-directory-dirty-count
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}

@test "returns correct count for modified files" {
  cd "$TMP_DIRECTORY/my-repo"
  echo "change" >> tracked.txt
  echo "change" >> tracked2.txt
  run_zsh_fn git-directory-dirty-count
  [ "$status" -eq 0 ]
  [ "$output" = "2" ]
}

@test "counts staged files" {
  cd "$TMP_DIRECTORY/my-repo"
  echo "staged" > staged.txt
  git add staged.txt
  run_zsh_fn git-directory-dirty-count
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

@test "counts untracked files" {
  cd "$TMP_DIRECTORY/my-repo"
  echo "untracked" > untracked.txt
  run_zsh_fn git-directory-dirty-count
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

@test "accepts a path argument and counts from that path" {
  export OROSHI_WORKTREES_DIR="$TMP_DIRECTORY/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR"
  cd "$TMP_DIRECTORY/my-repo"
  git worktree add "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" -b fix/bug
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  echo "change" >> tracked.txt
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-directory-dirty-count "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}
