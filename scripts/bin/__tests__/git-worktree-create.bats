load 'helper'

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"
  export OROSHI_WORKTREES_DIR="$TMP_DIRECTORY/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR"
  git init "$TMP_DIRECTORY/my-repo"
  cd "$TMP_DIRECTORY/my-repo"
  git -C "$TMP_DIRECTORY/my-repo" commit --allow-empty -m "init"
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "creates worktree directory with correct name" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-create fix/bug
  [ "$status" -eq 0 ]
  [ -d "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" ]
}

@test "creates the branch if it does not exist" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-create fix/new-branch
  run git -C "$TMP_DIRECTORY/my-repo" branch --list fix/new-branch
  [ "$output" != "" ]
}

@test "does not fail if branch already exists" {
  git -C "$TMP_DIRECTORY/my-repo" branch fix/existing
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-create fix/existing
  [ "$status" -eq 0 ]
}

@test "cds into the created worktree" {
  cd "$TMP_DIRECTORY/my-repo"
  run zsh -c 'git-worktree-create fix/bug && echo "$PWD"'
  [ "$status" -eq 0 ]
  [ "$output" = "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" ]
}

@test "is idempotent — does not fail if worktree already exists" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-create fix/bug
  run_zsh_fn git-worktree-create fix/bug
  [ "$status" -eq 0 ]
}

@test "converts slashes to underscores in directory name" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-create feat/some/deep-branch
  [ -d "$OROSHI_WORKTREES_DIR/my-repo--feat_some_deep-branch" ]
}

@test "returns 1 outside any git repo" {
  cd "$TMP_DIRECTORY"
  run_zsh_fn git-worktree-create fix/bug
  [ "$status" -eq 1 ]
}

@test "strips leading dot from repo name in dot-prefixed repo folder" {
  git init "$TMP_DIRECTORY/.dot-repo"
  git -C "$TMP_DIRECTORY/.dot-repo" commit --allow-empty -m "init"
  cd "$TMP_DIRECTORY/.dot-repo"
  run_zsh_fn git-worktree-create fix/bug
  [ "$status" -eq 0 ]
  [ -d "$OROSHI_WORKTREES_DIR/dot-repo--fix_bug" ]
}

@test "runs yarn install when yarn.lock is present" {
  local bin_dir="$TMP_DIRECTORY/bin"
  mkdir -p "$bin_dir"
  printf '#!/bin/sh\nmkdir -p node_modules\n' > "$bin_dir/yarn"
  chmod +x "$bin_dir/yarn"
  export PATH="$bin_dir:$PATH"
  touch "$TMP_DIRECTORY/my-repo/yarn.lock"
  git -C "$TMP_DIRECTORY/my-repo" add .
  git -C "$TMP_DIRECTORY/my-repo" commit -m "add yarn.lock"
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-create fix/yarn
  [ "$status" -eq 0 ]
  [ -d "$OROSHI_WORKTREES_DIR/my-repo--fix_yarn/node_modules" ]
}

@test "does not run yarn install when yarn.lock is absent" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-create fix/no-yarn
  [ "$status" -eq 0 ]
  [ ! -d "$OROSHI_WORKTREES_DIR/my-repo--fix_no-yarn/node_modules" ]
}

@test "failing yarn install does not prevent worktree creation" {
  local bin_dir="$TMP_DIRECTORY/bin"
  mkdir -p "$bin_dir"
  printf '#!/bin/sh\nexit 1\n' > "$bin_dir/yarn"
  chmod +x "$bin_dir/yarn"
  export PATH="$bin_dir:$PATH"
  touch "$TMP_DIRECTORY/my-repo/yarn.lock"
  git -C "$TMP_DIRECTORY/my-repo" add .
  git -C "$TMP_DIRECTORY/my-repo" commit -m "add yarn.lock"
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-create fix/yarn
  [ "$status" -eq 0 ]
  [ -d "$OROSHI_WORKTREES_DIR/my-repo--fix_yarn" ]
}

@test "re-entering existing worktree does not re-run yarn install" {
  local bin_dir="$TMP_DIRECTORY/bin"
  local call_log="$TMP_DIRECTORY/yarn-calls"
  mkdir -p "$bin_dir"
  printf '#!/bin/sh\necho called >> %s\nmkdir -p node_modules\n' "$call_log" > "$bin_dir/yarn"
  chmod +x "$bin_dir/yarn"
  export PATH="$bin_dir:$PATH"
  touch "$TMP_DIRECTORY/my-repo/yarn.lock"
  git -C "$TMP_DIRECTORY/my-repo" add .
  git -C "$TMP_DIRECTORY/my-repo" commit -m "add yarn.lock"
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-create fix/yarn
  local calls_first
  calls_first="$(wc -l < "$call_log" 2>/dev/null || echo 0)"
  run_zsh_fn git-worktree-create fix/yarn
  local calls_second
  calls_second="$(wc -l < "$call_log" 2>/dev/null || echo 0)"
  [ "$calls_second" -eq "$calls_first" ]
}
