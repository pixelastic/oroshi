bats_load_library 'helper'

setup() {
  # Create an isolated git repo with one initial commit
  bats_git_dir 'test-repo'
}

# --- Empty dir inside worktree ---

@test "deletes empty dir inside worktree and exits 0" {
  mkdir -p "$BATS_GIT_DIR/emptydir"

  bats_run_zsh "cd $BATS_GIT_DIR && rmdir-for-claude emptydir"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_GIT_DIR/emptydir" ]]
}

# --- Dir outside worktree ---

@test "refuses dir outside worktree with error message" {
  local outsideDir="$BATS_TMP_DIR/elsewhere"
  mkdir -p "$outsideDir/somedir"

  bats_run_zsh "cd $BATS_GIT_DIR && rmdir-for-claude $outsideDir/somedir"
  [[ "$status" -eq 1 ]]
  [[ -d "$outsideDir/somedir" ]]
  [[ "$output" == *"rejected"* ]]
  [[ "$output" == *"Not in current worktree"* ]]
  [[ "$output" == *"/bin/rmdir"* ]]
}

# --- No git repo ---

@test "refuses when not in a git repo" {
  local noGitDir="$BATS_TMP_DIR/no-git"
  mkdir -p "$noGitDir/somedir"

  bats_run_zsh "cd $noGitDir && rmdir-for-claude somedir"
  [[ "$status" -eq 1 ]]
  [[ -d "$noGitDir/somedir" ]]
}

# --- Multiple dirs, one outside worktree ---

@test "refuses all dirs when one is outside worktree" {
  mkdir -p "$BATS_GIT_DIR/gooddir"
  local outsideDir="$BATS_TMP_DIR/elsewhere"
  mkdir -p "$outsideDir/baddir"

  bats_run_zsh "cd $BATS_GIT_DIR && rmdir-for-claude gooddir $outsideDir/baddir"
  [[ "$status" -eq 1 ]]
  [[ -d "$BATS_GIT_DIR/gooddir" ]]
  [[ -d "$outsideDir/baddir" ]]
}

# --- Multiple dirs, all inside worktree ---

@test "deletes multiple empty dirs inside worktree" {
  mkdir -p "$BATS_GIT_DIR/dir1"
  mkdir -p "$BATS_GIT_DIR/dir2"

  bats_run_zsh "cd $BATS_GIT_DIR && rmdir-for-claude dir1 dir2"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_GIT_DIR/dir1" ]]
  [[ ! -e "$BATS_GIT_DIR/dir2" ]]
}
