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

# --- Directory with all committed files ---

@test "deletes directory with all committed files and exits 0" {
  mkdir -p "$BATS_GIT_DIR/mydir"
  echo "a" > "$BATS_GIT_DIR/mydir/a.txt"
  echo "b" > "$BATS_GIT_DIR/mydir/b.txt"
  bats_git add mydir
  bats_git commit -m "add mydir"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-for-claude -r mydir"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_GIT_DIR/mydir" ]]
}

# --- Directory with one untracked file ---

@test "refuses directory with untracked file" {
  mkdir -p "$BATS_GIT_DIR/mydir"
  echo "committed" > "$BATS_GIT_DIR/mydir/a.txt"
  bats_git add mydir
  bats_git commit -m "add mydir"
  echo "untracked" > "$BATS_GIT_DIR/mydir/untracked.txt"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-for-claude -r mydir"
  [[ "$status" -eq 1 ]]
  [[ -d "$BATS_GIT_DIR/mydir" ]]
  [[ "$output" == *"untracked.txt"* ]]
}

# --- Directory with git-ignored file ---

@test "refuses directory with git-ignored file" {
  echo "*.log" > "$BATS_GIT_DIR/.gitignore"
  mkdir -p "$BATS_GIT_DIR/mydir"
  echo "committed" > "$BATS_GIT_DIR/mydir/a.txt"
  bats_git add .gitignore mydir
  bats_git commit -m "add mydir and gitignore"
  echo "ignored" > "$BATS_GIT_DIR/mydir/build.log"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-for-claude -r mydir"
  [[ "$status" -eq 1 ]]
  [[ -d "$BATS_GIT_DIR/mydir" ]]
}

# --- Empty directory with -r ---

@test "deletes empty directory with -r and exits 0" {
  mkdir -p "$BATS_GIT_DIR/emptydir"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-for-claude -r emptydir"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_GIT_DIR/emptydir" ]]
}

# --- Mixed: committed file + committed directory ---

@test "deletes mixed committed file and committed directory" {
  echo "file" > "$BATS_GIT_DIR/file.txt"
  mkdir -p "$BATS_GIT_DIR/mydir"
  echo "a" > "$BATS_GIT_DIR/mydir/a.txt"
  bats_git add file.txt mydir
  bats_git commit -m "add file and dir"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-for-claude -r file.txt mydir"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_GIT_DIR/file.txt" ]]
  [[ ! -e "$BATS_GIT_DIR/mydir" ]]
}

# --- Mixed: committed file + directory with untracked file ---

@test "refuses all when directory has untracked file in mixed command" {
  echo "file" > "$BATS_GIT_DIR/file.txt"
  mkdir -p "$BATS_GIT_DIR/mydir"
  echo "committed" > "$BATS_GIT_DIR/mydir/a.txt"
  bats_git add file.txt mydir
  bats_git commit -m "add file and dir"
  echo "untracked" > "$BATS_GIT_DIR/mydir/bad.txt"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-for-claude -r file.txt mydir"
  [[ "$status" -eq 1 ]]
  [[ -e "$BATS_GIT_DIR/file.txt" ]]
  [[ -d "$BATS_GIT_DIR/mydir" ]]
}

# --- Recursive flag variants ---

@test "-rf triggers recursive directory check" {
  mkdir -p "$BATS_GIT_DIR/mydir"
  echo "a" > "$BATS_GIT_DIR/mydir/a.txt"
  bats_git add mydir
  bats_git commit -m "add mydir"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-for-claude -rf mydir"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_GIT_DIR/mydir" ]]
}

@test "-R triggers recursive directory check" {
  mkdir -p "$BATS_GIT_DIR/mydir"
  echo "a" > "$BATS_GIT_DIR/mydir/a.txt"
  bats_git add mydir
  bats_git commit -m "add mydir"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-for-claude -R mydir"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_GIT_DIR/mydir" ]]
}

@test "--recursive triggers recursive directory check" {
  mkdir -p "$BATS_GIT_DIR/mydir"
  echo "a" > "$BATS_GIT_DIR/mydir/a.txt"
  bats_git add mydir
  bats_git commit -m "add mydir"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-for-claude --recursive mydir"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_GIT_DIR/mydir" ]]
}

# --- Directory without recursive flag ---

@test "does not treat directory specially without recursive flag" {
  mkdir -p "$BATS_GIT_DIR/mydir"
  echo "a" > "$BATS_GIT_DIR/mydir/a.txt"
  bats_git add mydir
  bats_git commit -m "add mydir"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-for-claude mydir"
  [[ "$status" -eq 1 ]]
}
