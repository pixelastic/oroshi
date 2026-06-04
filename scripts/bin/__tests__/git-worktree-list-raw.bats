bats_load_library 'helper'

# Override run_zsh_fn to load functions from the worktree, not .oroshi
run_zsh_fn() {
  local func="${1}"
  local worktreeWorktreeFnDir="$(realpath "${BATS_TEST_DIRNAME}/../../../tools/term/zsh/config/functions/autoload/git/worktree")"
  local worktreeDirFnDir="$(realpath "${BATS_TEST_DIRNAME}/../../../tools/term/zsh/config/functions/autoload/git/directory")"
  local worktreeFileFnDir="$(realpath "${BATS_TEST_DIRNAME}/../../../tools/term/zsh/config/functions/autoload/git/file")"
  shift
  run zsh -c "fpath=(\"${worktreeWorktreeFnDir}\" \"${worktreeDirFnDir}\" \"${worktreeFileFnDir}\" \${(s/:/)FPATH}); autoload -Uz ${worktreeWorktreeFnDir}/*(.:t) ${worktreeDirFnDir}/*(.:t) ${worktreeFileFnDir}/*(.:t); ${func} \"\$@\"" -- "$@"
}

setup() {
  bats_tmp_dir
  export TMP_DIRECTORY="$BATS_TMP_DIR"
  export OROSHI_WORKTREES_DIR="$TMP_DIRECTORY/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR"

  git init "$TMP_DIRECTORY/my-repo"
  cd "$TMP_DIRECTORY/my-repo"
  git commit --allow-empty -m "init"
  git worktree add "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" -b fix/bug
  git worktree add "$OROSHI_WORKTREES_DIR/my-repo--feat_dark-mode" -b feat/dark-mode
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "lists worktrees with branch and path on each line" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-list-raw
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "feat/dark-mode▮$OROSHI_WORKTREES_DIR/my-repo--feat_dark-mode▮"* ]]
  [[ "${lines[1]}" == "fix/bug▮$OROSHI_WORKTREES_DIR/my-repo--fix_bug▮"* ]]
}

@test "excludes the Git Repo Main from output" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-list-raw
  for line in "${lines[@]}"; do
    [[ "$line" != *"$TMP_DIRECTORY/my-repo "* ]]
  done
}

@test "returns empty output when no worktrees exist" {
  git init "$TMP_DIRECTORY/clean-repo"
  cd "$TMP_DIRECTORY/clean-repo"
  git commit --allow-empty -m "init"
  run_zsh_fn git-worktree-list-raw
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "works from inside a linked worktree" {
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  run_zsh_fn git-worktree-list-raw
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
}

@test "output has 7 fields per line" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-list-raw
  [ "$status" -eq 0 ]
  local fieldCount
  fieldCount=$(awk -F'▮' '{print NF}' <<< "${lines[0]}")
  [ "$fieldCount" -eq 7 ]
}

@test "dirtyCount field is 0 for a clean worktree" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-list-raw
  [ "$status" -eq 0 ]
  local dirtyCount
  dirtyCount=$(awk -F'▮' '{print $3}' <<< "${lines[0]}")
  [ "$dirtyCount" = "0" ]
}

@test "dirtyCount field reflects uncommitted changes in a worktree" {
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  echo "dirty" > newfile.txt
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-list-raw
  [ "$status" -eq 0 ]
  local dirtyCount
  dirtyCount=$(awk -F'▮' '{print $3}' <<< "${lines[1]}")
  [ "$dirtyCount" = "1" ]
}

@test "ahead field is a plain integer" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-list-raw
  [ "$status" -eq 0 ]
  local ahead
  ahead=$(awk -F'▮' '{print $4}' <<< "${lines[0]}")
  [[ "$ahead" =~ ^[0-9]+$ ]]
}

@test "behind field is a plain integer" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-list-raw
  [ "$status" -eq 0 ]
  local behind
  behind=$(awk -F'▮' '{print $5}' <<< "${lines[0]}")
  [[ "$behind" =~ ^[0-9]+$ ]]
}
