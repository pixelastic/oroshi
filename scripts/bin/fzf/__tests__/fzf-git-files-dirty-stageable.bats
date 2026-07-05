bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_git_dir
  bats_disable_worktree_aware

  # Create and commit a file
  echo "original" > "$BATS_GIT_DIR/test.txt"
  bats_git add test.txt
  bats_git commit --quiet -m "add test.txt"

  # Modify it to make it stageable
  echo "modified" > "$BATS_GIT_DIR/test.txt"

  # Mock terminal-dependent collaborators
  img-display() { :; }
  bat() { cat "${@[-1]}"; }
  bats_mock img-display bat
}

# fzf-preview

@test "preview: shows diff for modified file" {
  bats_run_zsh "cd $BATS_GIT_DIR && fzf-git-files-dirty-stageable --preview test.txt"
  [ "$status" -eq 0 ]
  [[ "$output" == *"modified"* ]]
}

@test "preview: shows file content for new untracked file" {
  echo "brand new content" > "$BATS_GIT_DIR/new.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && fzf-git-files-dirty-stageable --preview new.txt"
  [ "$status" -eq 0 ]
  [[ "$output" == *"brand new content"* ]]
}
