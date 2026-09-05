bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  # Create a committed file
  echo "original" > "$BATS_GIT_DIR/tracked.txt"
  bats_git add tracked.txt
  bats_git commit --quiet -m "add tracked file"
}

# --- Single path, working directory ---

@test "exits 0 when file has uncommitted changes" {
  echo "modified" > "$BATS_GIT_DIR/tracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-has-changed tracked.txt"
  [[ "$status" -eq 0 ]]
}

@test "exits non-0 when file has no changes" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-has-changed tracked.txt"
  [[ "$status" -ne 0 ]]
}

# --- With --repo ---

@test "exits 0 when file has changes in --repo target" {
  echo "modified" > "$BATS_GIT_DIR/tracked.txt"
  bats_run_zsh "cd /tmp && git-file-has-changed tracked.txt --repo $BATS_GIT_DIR"
  [[ "$status" -eq 0 ]]
}

@test "exits non-0 when file has no changes in --repo target" {
  bats_run_zsh "cd /tmp && git-file-has-changed tracked.txt --repo $BATS_GIT_DIR"
  [[ "$status" -ne 0 ]]
}

# --- Multi-path ---

@test "exits 0 when first of two paths changed" {
  echo "extra" > "$BATS_GIT_DIR/other.txt"
  bats_git add other.txt
  bats_git commit --quiet -m "add other file"

  echo "modified" > "$BATS_GIT_DIR/tracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-has-changed tracked.txt other.txt"
  [[ "$status" -eq 0 ]]
}

@test "exits 0 when second of two paths changed" {
  echo "extra" > "$BATS_GIT_DIR/other.txt"
  bats_git add other.txt
  bats_git commit --quiet -m "add other file"

  echo "modified" > "$BATS_GIT_DIR/other.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-has-changed tracked.txt other.txt"
  [[ "$status" -eq 0 ]]
}

@test "exits non-0 when no multi-path files changed" {
  echo "extra" > "$BATS_GIT_DIR/other.txt"
  bats_git add other.txt
  bats_git commit --quiet -m "add other file"

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-has-changed tracked.txt other.txt"
  [[ "$status" -ne 0 ]]
}

# --- Directory path ---

@test "exits 0 when a file inside a watched directory changed" {
  mkdir -p "$BATS_GIT_DIR/subdir"
  echo "content" > "$BATS_GIT_DIR/subdir/nested.txt"
  bats_git add subdir/nested.txt
  bats_git commit --quiet -m "add nested file"

  echo "modified" > "$BATS_GIT_DIR/subdir/nested.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-has-changed subdir"
  [[ "$status" -eq 0 ]]
}

# --- With --from ---

@test "exits 0 when file changed since --from commit" {
  local commitRef="$(bats_git rev-parse HEAD)"
  echo "modified" > "$BATS_GIT_DIR/tracked.txt"
  bats_git add tracked.txt
  bats_git commit --quiet -m "modify tracked file"

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-has-changed tracked.txt --from $commitRef"
  [[ "$status" -eq 0 ]]
}

@test "exits non-0 when file did not change since --from commit" {
  local commitRef="$(bats_git rev-parse HEAD)"

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-has-changed tracked.txt --from $commitRef"
  [[ "$status" -ne 0 ]]
}

# --- With --from and --to ---

@test "exits 0 when file changed between --from and --to" {
  local fromRef="$(bats_git rev-parse HEAD)"
  echo "modified" > "$BATS_GIT_DIR/tracked.txt"
  bats_git add tracked.txt
  bats_git commit --quiet -m "modify tracked file"
  local toRef="$(bats_git rev-parse HEAD)"

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-has-changed tracked.txt --from $fromRef --to $toRef"
  [[ "$status" -eq 0 ]]
}

@test "exits non-0 when file did not change between --from and --to" {
  local fromRef="$(bats_git rev-parse HEAD)"
  echo "other" > "$BATS_GIT_DIR/unrelated.txt"
  bats_git add unrelated.txt
  bats_git commit --quiet -m "add unrelated file"
  local toRef="$(bats_git rev-parse HEAD)"

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-has-changed tracked.txt --from $fromRef --to $toRef"
  [[ "$status" -ne 0 ]]
}

# --- Multi-path with --from ---

@test "exits 0 when one of multiple paths changed since --from" {
  echo "extra" > "$BATS_GIT_DIR/other.txt"
  bats_git add other.txt
  bats_git commit --quiet -m "add other file"
  local commitRef="$(bats_git rev-parse HEAD)"

  echo "modified" > "$BATS_GIT_DIR/other.txt"
  bats_git add other.txt
  bats_git commit --quiet -m "modify other file"

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-has-changed tracked.txt other.txt --from $commitRef"
  [[ "$status" -eq 0 ]]
}
