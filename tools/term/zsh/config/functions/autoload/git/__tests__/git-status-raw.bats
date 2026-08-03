bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  echo "hello" > "$BATS_GIT_DIR/tracked.txt"
  bats_git add tracked.txt
  bats_git commit --quiet -m "add tracked"
}

# Clean repo
@test "returns empty output for a clean repo" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-status-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

# Single file statuses
@test "lists untracked files as A" {
  echo "new" > "$BATS_GIT_DIR/untracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-status-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "untracked.txt▮ ▮A" ]]
}

@test "lists unstaged modified files as M" {
  echo "modified" > "$BATS_GIT_DIR/tracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-status-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "tracked.txt▮ ▮M" ]]
}

@test "lists unstaged deleted files as D" {
  rm "$BATS_GIT_DIR/tracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-status-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "tracked.txt▮ ▮D" ]]
}

@test "lists staged new files as A" {
  echo "new" > "$BATS_GIT_DIR/staged.txt"
  bats_git add staged.txt
  bats_run_zsh "cd $BATS_GIT_DIR && git-status-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "staged.txt▮A▮ " ]]
}

@test "lists staged modifications as M" {
  echo "modified" > "$BATS_GIT_DIR/tracked.txt"
  bats_git add tracked.txt
  bats_run_zsh "cd $BATS_GIT_DIR && git-status-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "tracked.txt▮M▮ " ]]
}

@test "lists staged deletions as D" {
  bats_git rm --quiet tracked.txt
  bats_run_zsh "cd $BATS_GIT_DIR && git-status-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "tracked.txt▮D▮ " ]]
}

# Spaces in paths
@test "lists file with spaces in directory name without quotes" {
  mkdir -p "$BATS_GIT_DIR/my dir"
  echo "new" > "$BATS_GIT_DIR/my dir/file.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-status-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "my dir/file.txt▮ ▮A" ]]
}

@test "lists file with spaces in filename without quotes" {
  echo "new" > "$BATS_GIT_DIR/my file.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-status-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "my file.txt▮ ▮A" ]]
}

# Multiple files
@test "lists multiple dirty files, one per line" {
  echo "modified" > "$BATS_GIT_DIR/tracked.txt"
  echo "new" > "$BATS_GIT_DIR/untracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-status-raw"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]
}

# Path argument
@test "accepts a path argument and lists dirty files from that path" {
  bats_disable_worktree_aware
  local otherDir="$BATS_TMP_DIR/other-repo"
  git init --quiet "$otherDir"
  git -C "$otherDir" commit --quiet --allow-empty -m "init"
  echo "new" > "$otherDir/newfile.txt"
  bats_run_zsh "git-status-raw '$otherDir'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "newfile.txt▮ ▮A" ]]
}

@test "returns empty output for a clean path argument" {
  bats_disable_worktree_aware
  local otherDir="$BATS_TMP_DIR/other-repo"
  git init --quiet "$otherDir"
  git -C "$otherDir" commit --quiet --allow-empty -m "init"
  bats_run_zsh "git-status-raw '$otherDir'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

# Output format
@test "columns are filepath▮X▮Y separated by ▮" {
  echo "new" > "$BATS_GIT_DIR/file.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-status-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"▮"* ]]
  [[ "$output" == "file.txt▮ ▮A" ]]
}
