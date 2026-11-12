bats_load_library 'helper'

setup() {
  # Create an isolated git repo with one initial commit
  bats_git_dir 'test-repo'

  # A folder that is neither in the worktree nor under a free root (/tmp, /dev/shm, ~/local/tmp)
  export OUTSIDE_DIR="$(mktemp --directory /var/tmp/rm-guarded-XXXXXX)"
}

teardown() {
  /bin/rm -rf "$OUTSIDE_DIR"
}

# --- Committed file ---

@test "deletes committed file and exits 0" {
  echo "content" > "$BATS_GIT_DIR/committed.txt"
  bats_git add committed.txt
  bats_git commit -m "add committed.txt"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded committed.txt"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_GIT_DIR/committed.txt" ]]
}

# --- Untracked file ---

@test "refuses untracked file with error message" {
  echo "content" > "$BATS_GIT_DIR/untracked.txt"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded untracked.txt"
  [[ "$status" -eq 1 ]]
  [[ -e "$BATS_GIT_DIR/untracked.txt" ]]
  [[ "$output" == *"untracked.txt rejected"* ]]
  [[ "$output" == *"Not committed in HEAD"* ]]
  [[ "$output" == *"/bin/rm"* ]]
}

@test "prints the refusal marker line on stderr when a path is not committed" {
  echo "content" > "$BATS_GIT_DIR/untracked.txt"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded untracked.txt 2>&1 >/dev/null"
  [[ "$output" == *"[claude-guarded:refused] This deletion needs the user's approval. Retry the exact same command with /bin/rm in place of rm: the user will get an approval prompt, and nothing is deleted before they accept."* ]]
}

@test "prints the refusal marker line outside a git repository" {
  local noGitDir="$OUTSIDE_DIR/no-git"
  mkdir -p "$noGitDir"
  echo "content" > "$noGitDir/file.txt"

  bats_run_zsh "cd $noGitDir && rm-guarded file.txt 2>&1 >/dev/null"
  [[ "$output" == *"[claude-guarded:refused] This deletion needs the user's approval. Retry the exact same command with /bin/rm in place of rm: the user will get an approval prompt, and nothing is deleted before they accept."* ]]
}

@test "prints the refusal marker on exactly one line when several paths fail" {
  echo "a" > "$BATS_GIT_DIR/a.txt"
  echo "b" > "$BATS_GIT_DIR/b.txt"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded a.txt b.txt 2>&1 >/dev/null"
  local markerLines="$(grep --count '^\[claude-guarded:refused\]' <<< "$output")"
  [[ "$markerLines" -eq 1 ]]
}

@test "keeps the per-path rejection reasons next to the marker" {
  echo "content" > "$BATS_GIT_DIR/untracked.txt"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded untracked.txt 2>&1 >/dev/null"
  [[ "$output" == *"rm untracked.txt rejected. Reason: Not committed in HEAD."* ]]
}

@test "prints no marker when deleting a committed file" {
  echo "content" > "$BATS_GIT_DIR/committed.txt"
  bats_git add committed.txt
  bats_git commit -m "add committed.txt"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded committed.txt 2>&1"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *"[claude-guarded:refused]"* ]]
}

# --- Git-ignored file ---

@test "refuses git-ignored file" {
  echo "ignored.txt" > "$BATS_GIT_DIR/.gitignore"
  bats_git add .gitignore
  bats_git commit -m "add gitignore"
  echo "content" > "$BATS_GIT_DIR/ignored.txt"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded ignored.txt"
  [[ "$status" -eq 1 ]]
  [[ -e "$BATS_GIT_DIR/ignored.txt" ]]
}

# --- Staged but never committed file ---

@test "refuses staged-only file" {
  echo "content" > "$BATS_GIT_DIR/staged.txt"
  bats_git add staged.txt

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded staged.txt"
  [[ "$status" -eq 1 ]]
  [[ -e "$BATS_GIT_DIR/staged.txt" ]]
}

# --- File outside worktree ---

@test "refuses file outside worktree" {
  local outsideDir="$OUTSIDE_DIR/elsewhere"
  mkdir -p "$outsideDir"
  echo "content" > "$outsideDir/outside.txt"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded $outsideDir/outside.txt"
  [[ "$status" -eq 1 ]]
  [[ -e "$outsideDir/outside.txt" ]]
  [[ "$output" == *"outside.txt"* ]]
}

# --- No git repo ---

@test "refuses when not in a git repo" {
  local noGitDir="$OUTSIDE_DIR/no-git"
  mkdir -p "$noGitDir"
  echo "content" > "$noGitDir/file.txt"

  bats_run_zsh "cd $noGitDir && rm-guarded file.txt"
  [[ "$status" -eq 1 ]]
  [[ -e "$noGitDir/file.txt" ]]
}

# --- Multiple files, all committed ---

@test "deletes multiple committed files" {
  echo "a" > "$BATS_GIT_DIR/a.txt"
  echo "b" > "$BATS_GIT_DIR/b.txt"
  bats_git add a.txt b.txt
  bats_git commit -m "add a and b"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded a.txt b.txt"
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

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded good.txt bad.txt"
  [[ "$status" -eq 1 ]]
  [[ -e "$BATS_GIT_DIR/good.txt" ]]
  [[ -e "$BATS_GIT_DIR/bad.txt" ]]
}

# --- Flags passed through ---

@test "forwards flags to /bin/rm" {
  echo "content" > "$BATS_GIT_DIR/flagged.txt"
  bats_git add flagged.txt
  bats_git commit -m "add flagged.txt"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded -f flagged.txt"
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

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded -r mydir"
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

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded -r mydir"
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

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded -r mydir"
  [[ "$status" -eq 1 ]]
  [[ -d "$BATS_GIT_DIR/mydir" ]]
}

# --- Empty directory with -r ---

@test "deletes empty directory with -r and exits 0" {
  mkdir -p "$BATS_GIT_DIR/emptydir"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded -r emptydir"
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

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded -r file.txt mydir"
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

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded -r file.txt mydir"
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

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded -rf mydir"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_GIT_DIR/mydir" ]]
}

@test "-R triggers recursive directory check" {
  mkdir -p "$BATS_GIT_DIR/mydir"
  echo "a" > "$BATS_GIT_DIR/mydir/a.txt"
  bats_git add mydir
  bats_git commit -m "add mydir"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded -R mydir"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_GIT_DIR/mydir" ]]
}

@test "--recursive triggers recursive directory check" {
  mkdir -p "$BATS_GIT_DIR/mydir"
  echo "a" > "$BATS_GIT_DIR/mydir/a.txt"
  bats_git add mydir
  bats_git commit -m "add mydir"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded --recursive mydir"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_GIT_DIR/mydir" ]]
}

# --- Directory without recursive flag ---

@test "does not treat directory specially without recursive flag" {
  mkdir -p "$BATS_GIT_DIR/mydir"
  echo "a" > "$BATS_GIT_DIR/mydir/a.txt"
  bats_git add mydir
  bats_git commit -m "add mydir"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded mydir"
  [[ "$status" -eq 1 ]]
}

# --- Free roots: /tmp, /dev/shm, ~/local/tmp ---

@test "deletes a file under /tmp that is outside the worktree" {
  mkdir -p "$BATS_TMP_DIR/free"
  echo "content" > "$BATS_TMP_DIR/free/scratch.txt"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded $BATS_TMP_DIR/free/scratch.txt"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_TMP_DIR/free/scratch.txt" ]]
}

@test "deletes a file under /tmp outside a git repository" {
  mkdir -p "$BATS_TMP_DIR/free"
  echo "content" > "$BATS_TMP_DIR/free/scratch.txt"

  bats_run_zsh "cd $OUTSIDE_DIR && rm-guarded $BATS_TMP_DIR/free/scratch.txt"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_TMP_DIR/free/scratch.txt" ]]
}

@test "deletes a directory under /tmp recursively without a HEAD check" {
  mkdir -p "$BATS_TMP_DIR/free/dir"
  echo "content" > "$BATS_TMP_DIR/free/dir/a.txt"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded -rf $BATS_TMP_DIR/free/dir"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_TMP_DIR/free/dir" ]]
}

@test "deletes a file under /dev/shm" {
  [[ -d /dev/shm ]] || skip "no /dev/shm"
  local shmFile="/dev/shm/rm-guarded-$$.txt"
  echo "content" > "$shmFile"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded $shmFile"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$shmFile" ]]
}

@test "deletes a file under ~/local/tmp" {
  local fakeHome="$OUTSIDE_DIR/home"
  mkdir -p "$fakeHome/local/tmp"
  echo "content" > "$fakeHome/local/tmp/state.txt"

  bats_run_zsh "cd $BATS_GIT_DIR && HOME=$fakeHome rm-guarded $fakeHome/local/tmp/state.txt"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$fakeHome/local/tmp/state.txt" ]]
}

@test "refuses a free root itself" {
  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded /tmp"
  [[ "$status" -eq 1 ]]
  [[ -d /tmp ]]
  [[ "$output" == *"rm /tmp rejected"* ]]
}

@test "refuses a path that climbs out of /tmp with .." {
  echo "content" > "$OUTSIDE_DIR/climb.txt"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded /tmp/../var/tmp/${OUTSIDE_DIR:t}/climb.txt"
  [[ "$status" -eq 1 ]]
  [[ -e "$OUTSIDE_DIR/climb.txt" ]]
}

@test "refuses a path that goes through a symlink leading out of /tmp" {
  echo "content" > "$OUTSIDE_DIR/target.txt"
  mkdir -p "$BATS_TMP_DIR/free"
  ln -s "$OUTSIDE_DIR" "$BATS_TMP_DIR/free/escape"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded $BATS_TMP_DIR/free/escape/target.txt"
  [[ "$status" -eq 1 ]]
  [[ -e "$OUTSIDE_DIR/target.txt" ]]
}

@test "deletes a symlink under /tmp that points out of /tmp, as rm removes the link only" {
  echo "content" > "$OUTSIDE_DIR/target.txt"
  mkdir -p "$BATS_TMP_DIR/free"
  ln -s "$OUTSIDE_DIR/target.txt" "$BATS_TMP_DIR/free/link"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded $BATS_TMP_DIR/free/link"
  [[ "$status" -eq 0 ]]
  [[ ! -L "$BATS_TMP_DIR/free/link" ]]
  [[ -e "$OUTSIDE_DIR/target.txt" ]]
}

@test "refuses all paths when a free path is mixed with an uncommitted worktree path" {
  mkdir -p "$BATS_TMP_DIR/free"
  echo "content" > "$BATS_TMP_DIR/free/scratch.txt"
  echo "content" > "$BATS_GIT_DIR/untracked.txt"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded $BATS_TMP_DIR/free/scratch.txt untracked.txt"
  [[ "$status" -eq 1 ]]
  [[ -e "$BATS_TMP_DIR/free/scratch.txt" ]]
  [[ -e "$BATS_GIT_DIR/untracked.txt" ]]
}

@test "still refuses an uncommitted worktree file although the worktree sits under /tmp" {
  echo "content" > "$BATS_GIT_DIR/untracked.txt"

  bats_run_zsh "cd $BATS_GIT_DIR && rm-guarded untracked.txt"
  [[ "$status" -eq 1 ]]
  [[ -e "$BATS_GIT_DIR/untracked.txt" ]]
}
