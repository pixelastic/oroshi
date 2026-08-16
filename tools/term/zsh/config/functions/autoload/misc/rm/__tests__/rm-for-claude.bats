bats_load_library 'helper'

setup() {
  # Create an isolated git repo with one initial commit
  bats_git_dir 'test-repo'
}

# --- Committed file ---

@test "deletes committed file and exits 0" {
  echo "content" > "$BATS_GIT_DIR/committed.txt"
  bats_git add committed.txt
  bats_git commit -m "add committed.txt"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-for-claude committed.txt"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_GIT_DIR/committed.txt" ]]
}

# --- Untracked file ---

@test "refuses untracked file with error message" {
  echo "content" > "$BATS_GIT_DIR/untracked.txt"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-for-claude untracked.txt"
  [[ "$status" -eq 1 ]]
  [[ -e "$BATS_GIT_DIR/untracked.txt" ]]
  [[ "$output" == *"untracked.txt rejected"* ]]
  [[ "$output" == *"Not committed in HEAD"* ]]
  [[ "$output" == *"/bin/rm"* ]]
}

# --- Git-ignored file ---

@test "refuses git-ignored file" {
  echo "ignored.txt" > "$BATS_GIT_DIR/.gitignore"
  bats_git add .gitignore
  bats_git commit -m "add gitignore"
  echo "content" > "$BATS_GIT_DIR/ignored.txt"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-for-claude ignored.txt"
  [[ "$status" -eq 1 ]]
  [[ -e "$BATS_GIT_DIR/ignored.txt" ]]
}

# --- Staged but never committed file ---

@test "refuses staged-only file" {
  echo "content" > "$BATS_GIT_DIR/staged.txt"
  bats_git add staged.txt

  bats_run_zsh "cd $BATS_GIT_DIR && rm-for-claude staged.txt"
  [[ "$status" -eq 1 ]]
  [[ -e "$BATS_GIT_DIR/staged.txt" ]]
}

# --- File outside worktree ---

@test "refuses file outside worktree" {
  local outsideDir="$BATS_TMP_DIR/elsewhere"
  mkdir -p "$outsideDir"
  echo "content" > "$outsideDir/outside.txt"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-for-claude $outsideDir/outside.txt"
  [[ "$status" -eq 1 ]]
  [[ -e "$outsideDir/outside.txt" ]]
  [[ "$output" == *"outside.txt"* ]]
}

# --- No git repo ---

@test "refuses when not in a git repo" {
  local noGitDir="$BATS_TMP_DIR/no-git"
  mkdir -p "$noGitDir"
  echo "content" > "$noGitDir/file.txt"

  bats_run_zsh "cd $noGitDir && rm-for-claude file.txt"
  [[ "$status" -eq 1 ]]
  [[ -e "$noGitDir/file.txt" ]]
}

# --- Multiple files, all committed ---

@test "deletes multiple committed files" {
  echo "a" > "$BATS_GIT_DIR/a.txt"
  echo "b" > "$BATS_GIT_DIR/b.txt"
  bats_git add a.txt b.txt
  bats_git commit -m "add a and b"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-for-claude a.txt b.txt"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_GIT_DIR/a.txt" ]]
  [[ ! -e "$BATS_GIT_DIR/b.txt" ]]
}

# --- Multiple files, one uncommitted (no partial deletion) ---

@test "refuses all files when one is uncommitted" {
  echo "committed" > "$BATS_GIT_DIR/good.txt"
  bats_git add good.txt
  bats_git commit -m "add good.txt"
  echo "untracked" > "$BATS_GIT_DIR/bad.txt"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-for-claude good.txt bad.txt"
  [[ "$status" -eq 1 ]]
  [[ -e "$BATS_GIT_DIR/good.txt" ]]
  [[ -e "$BATS_GIT_DIR/bad.txt" ]]
}

# --- Flags passed through ---

@test "forwards flags to /bin/rm" {
  echo "content" > "$BATS_GIT_DIR/flagged.txt"
  bats_git add flagged.txt
  bats_git commit -m "add flagged.txt"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-for-claude -f flagged.txt"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_GIT_DIR/flagged.txt" ]]
}
