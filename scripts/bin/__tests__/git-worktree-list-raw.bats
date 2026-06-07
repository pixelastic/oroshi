bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$OROSHI_ZSH_AUTOLOAD/git/worktree/git-worktree-list-raw"
  export TMP_DIRECTORY="$BATS_TMP_DIR"
  export OROSHI_WORKTREES_DIR="$TMP_DIRECTORY/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR"

  git init "$TMP_DIRECTORY/my-repo"
  cd "$TMP_DIRECTORY/my-repo" || return 1
  git commit --allow-empty -m "init"
  git worktree add "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" -b fix/bug
  git worktree add "$OROSHI_WORKTREES_DIR/my-repo--feat_dark-mode" -b feat/dark-mode
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "lists worktrees with branch and path on each line" {
  cd "$TMP_DIRECTORY/my-repo"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "feat/dark-mode▮$OROSHI_WORKTREES_DIR/my-repo--feat_dark-mode▮"* ]]
  [[ "${lines[1]}" == "fix/bug▮$OROSHI_WORKTREES_DIR/my-repo--fix_bug▮"* ]]
}

@test "excludes the Git Repo Main from output" {
  cd "$TMP_DIRECTORY/my-repo"
  bats_run_zsh "$CURRENT"
  for line in "${lines[@]}"; do
    [[ "$line" != *"$TMP_DIRECTORY/my-repo "* ]]
  done
}

@test "returns empty output when no worktrees exist" {
  git init "$TMP_DIRECTORY/clean-repo"
  cd "$TMP_DIRECTORY/clean-repo"
  git commit --allow-empty -m "init"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "works from inside a linked worktree" {
  local script="$BATS_TMP_DIR/from-wt.zsh"
  printf 'cd "%s"\ngit-worktree-list-raw\n' "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" >"$script"
  bats_run_zsh "$script"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
}

@test "output has 7 fields per line" {
  cd "$TMP_DIRECTORY/my-repo"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  local fieldCount
  fieldCount=$(awk -F'▮' '{print NF}' <<< "${lines[0]}")
  [ "$fieldCount" -eq 7 ]
}

@test "dirtyCount field is 0 for a clean worktree" {
  cd "$TMP_DIRECTORY/my-repo"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  local dirtyCount
  dirtyCount=$(awk -F'▮' '{print $3}' <<< "${lines[0]}")
  [ "$dirtyCount" = "0" ]
}

@test "dirtyCount field reflects uncommitted changes in a worktree" {
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  echo "dirty" > newfile.txt
  cd "$TMP_DIRECTORY/my-repo"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  local dirtyCount
  dirtyCount=$(awk -F'▮' '{print $3}' <<< "${lines[1]}")
  [ "$dirtyCount" = "1" ]
}

@test "ahead field is a plain integer" {
  cd "$TMP_DIRECTORY/my-repo"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  local ahead
  ahead=$(awk -F'▮' '{print $4}' <<< "${lines[0]}")
  [[ "$ahead" =~ ^[0-9]+$ ]]
}

@test "behind field is a plain integer" {
  cd "$TMP_DIRECTORY/my-repo"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  local behind
  behind=$(awk -F'▮' '{print $5}' <<< "${lines[0]}")
  [[ "$behind" =~ ^[0-9]+$ ]]
}
