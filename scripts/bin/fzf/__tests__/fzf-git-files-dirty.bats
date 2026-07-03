bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_git_dir

  # Create and commit a file
  echo "original" > "$BATS_GIT_DIR/test.txt"
  bats_git add test.txt
  bats_git commit --quiet -m "add test.txt"
}

@test "--source: returns empty in a clean repo" {
  bats_run_zsh "cd $BATS_GIT_DIR && fzf-git-files-dirty --source"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "--source: lists a modified tracked file" {
  echo "modified" > "$BATS_GIT_DIR/test.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && fzf-git-files-dirty --source"
  [ "$status" -eq 0 ]
  [[ "$output" == *"test.txt"* ]]
}

@test "--source: lists a deleted tracked file" {
  rm "$BATS_GIT_DIR/test.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && fzf-git-files-dirty --source"
  [ "$status" -eq 0 ]
  [[ "$output" == *"test.txt"* ]]
}

@test "--source: lists a staged-new file" {
  echo "new content" > "$BATS_GIT_DIR/new.txt"
  bats_git add new.txt
  bats_run_zsh "cd $BATS_GIT_DIR && fzf-git-files-dirty --source"
  [ "$status" -eq 0 ]
  [[ "$output" == *"new.txt"* ]]
}

@test "--source: lists an untracked file" {
  echo "untracked" > "$BATS_GIT_DIR/untracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && fzf-git-files-dirty --source"
  [ "$status" -eq 0 ]
  [[ "$output" == *"untracked.txt"* ]]
}
