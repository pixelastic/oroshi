bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "runs submodule update in given directory" {
  git() { echo "$@" > "$BATS_TMP_DIR/git-args.txt"; }
  git-submodule-list-raw() { return 0; }
  bats_mock git git-submodule-list-raw

  bats_run_zsh "git-submodule-update-all $BATS_TMP_DIR"
  [[ "$status" -eq 0 ]]

  local args="$(cat "$BATS_TMP_DIR/git-args.txt")"
  [[ "$args" == *"-C"* ]]
  [[ "$args" == *"$BATS_TMP_DIR"* ]]
  [[ "$args" == *"submodule update"* ]]
}

@test "defaults to current directory" {
  git() { echo "$@" > "$BATS_TMP_DIR/git-args.txt"; }
  git-submodule-list-raw() { return 0; }
  bats_mock git git-submodule-list-raw
  bats_disable_worktree_aware

  bats_run_zsh "cd $BATS_TMP_DIR && git-submodule-update-all"
  [[ "$status" -eq 0 ]]

  local args="$(cat "$BATS_TMP_DIR/git-args.txt")"
  [[ "$args" == "-C . submodule update" ]]
}

@test "checks out the branch configured in .gitmodules" {
  git() { return 0; }
  git-submodule-list-raw() { echo "private▮abc12345▮"; }
  git-submodule-branch() { echo "develop"; }
  git-branch-switch() { echo "$@" >> "$BATS_TMP_DIR/switch-calls.txt"; }
  bats_mock git git-submodule-list-raw git-submodule-branch git-branch-switch

  bats_run_zsh "git-submodule-update-all /repo"
  [[ "$status" -eq 0 ]]

  local calls="$(cat "$BATS_TMP_DIR/switch-calls.txt")"
  [[ "$calls" == *"--no-dependencies --repo /repo/private develop"* ]]
}

@test "falls back to main when no branch configured in .gitmodules" {
  git() { return 0; }
  git-submodule-list-raw() { echo "private▮abc12345▮"; }
  git-submodule-branch() { echo "main"; }
  git-branch-switch() { echo "$@" >> "$BATS_TMP_DIR/switch-calls.txt"; }
  bats_mock git git-submodule-list-raw git-submodule-branch git-branch-switch

  bats_run_zsh "git-submodule-update-all /repo"
  [[ "$status" -eq 0 ]]

  local calls="$(cat "$BATS_TMP_DIR/switch-calls.txt")"
  [[ "$calls" == *"--no-dependencies --repo /repo/private main"* ]]
}

@test "checks out each submodule on its own configured branch" {
  git() { return 0; }
  git-submodule-list-raw() {
    printf 'alpha▮aaa12345▮\nbeta▮bbb98765▮\n'
  }
  git-submodule-branch() {
    [[ "$*" == *"alpha" ]] && echo "develop" && return 0
    [[ "$*" == *"beta" ]] && echo "release" && return 0
  }
  git-branch-switch() { echo "$@" >> "$BATS_TMP_DIR/switch-calls.txt"; }
  bats_mock git git-submodule-list-raw git-submodule-branch git-branch-switch

  bats_run_zsh "git-submodule-update-all /repo"
  [[ "$status" -eq 0 ]]

  local calls="$(cat "$BATS_TMP_DIR/switch-calls.txt")"
  [[ "$calls" == *"--no-dependencies --repo /repo/alpha develop"* ]]
  [[ "$calls" == *"--no-dependencies --repo /repo/beta release"* ]]
}

@test "fast-forwards configured branch to target commit after switch" {
  git() { echo "$@" >> "$BATS_TMP_DIR/git-calls.txt"; }
  git-submodule-list-raw() { echo "private▮abc12345▮"; }
  git-submodule-branch() { echo "develop"; }
  git-branch-switch() { return 0; }
  bats_mock git git-submodule-list-raw git-submodule-branch git-branch-switch

  bats_run_zsh "git-submodule-update-all /repo"
  [[ "$status" -eq 0 ]]

  local calls="$(cat "$BATS_TMP_DIR/git-calls.txt")"
  [[ "$calls" == *"-C /repo/private merge --quiet --ff-only abc12345"* ]]
}

@test "fast-forwards each submodule to its own target commit" {
  git() { echo "$@" >> "$BATS_TMP_DIR/git-calls.txt"; }
  git-submodule-list-raw() {
    printf 'alpha▮aaa11111▮\nbeta▮bbb22222▮\n'
  }
  git-submodule-branch() {
    [[ "$*" == *"alpha" ]] && echo "develop" && return 0
    [[ "$*" == *"beta" ]] && echo "release" && return 0
  }
  git-branch-switch() { return 0; }
  bats_mock git git-submodule-list-raw git-submodule-branch git-branch-switch

  bats_run_zsh "git-submodule-update-all /repo"
  [[ "$status" -eq 0 ]]

  local calls="$(cat "$BATS_TMP_DIR/git-calls.txt")"
  [[ "$calls" == *"-C /repo/alpha merge --quiet --ff-only aaa11111"* ]]
  [[ "$calls" == *"-C /repo/beta merge --quiet --ff-only bbb22222"* ]]
}

@test "silently ignores ff-only failure when branch has diverged" {
  git() {
    # Simulate merge --ff-only failure
    [[ "$*" == *"merge --ff-only"* ]] && return 1
    echo "$@" >> "$BATS_TMP_DIR/git-calls.txt"
  }
  git-submodule-list-raw() { echo "private▮abc12345▮"; }
  git-submodule-branch() { echo "develop"; }
  git-branch-switch() { return 0; }
  bats_mock git git-submodule-list-raw git-submodule-branch git-branch-switch

  bats_run_zsh "git-submodule-update-all /repo"
  [[ "$status" -eq 0 ]]
}

# Integration tests with real git repos

@test "submodule pointer advanced: ends up at target commit on configured branch" {
  # Parent repo with a submodule, upstream at $BATS_TMP_DIR/sub-upstream-sub
  bats_git_dir 'parent'
  bats_git_submodule "$BATS_GIT_DIR" 'sub'
  local upstream="$BATS_TMP_DIR/sub-upstream-sub"

  # Advance upstream with a new commit
  git -C "$upstream" commit --allow-empty --quiet -m "advance"
  local advancedCommit="$(git -C "$upstream" rev-parse HEAD)"

  # Fetch new commit into submodule and update parent's pointer
  git -C "$BATS_GIT_DIR/sub" fetch --quiet origin
  git -C "$BATS_GIT_DIR/sub" checkout --quiet FETCH_HEAD
  git -C "$BATS_GIT_DIR" add sub
  git -C "$BATS_GIT_DIR" commit --quiet -m "update sub pointer"

  # Simulate post-pull state: sub's main is behind the parent's pointer
  git -C "$BATS_GIT_DIR/sub" checkout --quiet main

  # Mock helpers with deep dependency chains; let real git + git-branch-switch run
  local targetHash="${advancedCommit:0:8}"
  bats_mock_env "TARGET_HASH" "$targetHash"
  git-submodule-list-raw() { echo "sub▮${TARGET_HASH}▮main"; }
  git-submodule-branch() { echo "main"; }
  bats_mock git-submodule-list-raw git-submodule-branch

  bats_run_zsh "git-submodule-update-all $BATS_GIT_DIR"
  [[ "$status" -eq 0 ]]

  # Submodule is at the commit the parent expects
  local actualCommit="$(git -C "$BATS_GIT_DIR/sub" rev-parse HEAD)"
  [[ "$actualCommit" == "$advancedCommit" ]]

  # Submodule is on the configured branch (not detached HEAD)
  local actualBranch="$(git -C "$BATS_GIT_DIR/sub" symbolic-ref --short HEAD)"
  [[ "$actualBranch" == "main" ]]

  # Configured branch points to the commit the parent expects
  local branchCommit="$(git -C "$BATS_GIT_DIR/sub" rev-parse main)"
  [[ "$branchCommit" == "$advancedCommit" ]]
}

@test "submodule already at correct commit: stays on branch, no change" {
  # Parent repo with a submodule already at the correct commit
  bats_git_dir 'parent'
  bats_git_submodule "$BATS_GIT_DIR" 'sub'

  local currentCommit="$(git -C "$BATS_GIT_DIR/sub" rev-parse HEAD)"
  local targetHash="${currentCommit:0:8}"

  # Mock helpers; submodule is already where it should be
  bats_mock_env "TARGET_HASH" "$targetHash"
  git-submodule-list-raw() { echo "sub▮${TARGET_HASH}▮main"; }
  git-submodule-branch() { echo "main"; }
  bats_mock git-submodule-list-raw git-submodule-branch

  bats_run_zsh "git-submodule-update-all $BATS_GIT_DIR"
  [[ "$status" -eq 0 ]]

  # Submodule still at correct commit
  local actualCommit="$(git -C "$BATS_GIT_DIR/sub" rev-parse HEAD)"
  [[ "$actualCommit" == "$currentCommit" ]]

  # Submodule still on the configured branch
  local actualBranch="$(git -C "$BATS_GIT_DIR/sub" symbolic-ref --short HEAD)"
  [[ "$actualBranch" == "main" ]]
}
