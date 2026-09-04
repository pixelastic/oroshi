bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'

  # Create a bare remote and push main
  BARE_REMOTE="$BATS_TMP_DIR/bare-remote.git"
  git init --bare "$BARE_REMOTE" --quiet
  bats_git remote add origin "$BARE_REMOTE"
  bats_git push --quiet --set-upstream origin main
}

@test "returns 0▮0 when branch matches remote" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-branch-remote-distance-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "0▮0" ]]
}

@test "returns ahead count when local has unpushed commits" {
  bats_git commit --allow-empty --quiet -m "local work"
  bats_git commit --allow-empty --quiet -m "more local work"

  bats_run_zsh "cd $BATS_GIT_DIR && git-branch-remote-distance-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "2▮0" ]]
}

@test "returns behind count when remote has new commits" {
  # Push a commit from a separate clone so the bare remote advances
  local clone="$BATS_TMP_DIR/clone"
  git clone --quiet "$BARE_REMOTE" "$clone"
  git -C "$clone" config user.email "bats@oroshi"
  git -C "$clone" config user.name "Bats"
  git -C "$clone" commit --allow-empty --quiet -m "remote work"
  git -C "$clone" push --quiet origin main

  # Fetch so our repo knows about the new remote commit
  bats_git fetch --quiet origin

  bats_run_zsh "cd $BATS_GIT_DIR && git-branch-remote-distance-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "0▮1" ]]
}

@test "accepts branch name as positional argument" {
  bats_git checkout --quiet -b fix/bug
  bats_git commit --allow-empty --quiet -m "bug fix"
  bats_git push --quiet --set-upstream origin fix/bug

  bats_run_zsh "cd $BATS_GIT_DIR && git-branch-remote-distance-raw main"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "0▮0" ]]
}

@test "supports --repo flag" {
  bats_git commit --allow-empty --quiet -m "local work"

  bats_run_zsh "git-branch-remote-distance-raw --repo $BATS_GIT_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "1▮0" ]]
}

@test "returns 1 for nonexistent branch" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-branch-remote-distance-raw nonexistent"
  [[ "$status" -eq 1 ]]
}
