bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/git/branch/git-branch-list-raw"

  # Remote repo: simulates origin with an initial commit
  git init --initial-branch=main --quiet "$BATS_TMP_DIR/remote"
  git -C "$BATS_TMP_DIR/remote" config user.email "bats@oroshi"
  git -C "$BATS_TMP_DIR/remote" config user.name "Bats"
  git -C "$BATS_TMP_DIR/remote" commit --allow-empty --quiet --message="base"

  # Local repo: clone of remote, main tracks origin/main
  git clone --quiet "$BATS_TMP_DIR/remote" "$BATS_TMP_DIR/local"
  git -C "$BATS_TMP_DIR/local" config user.email "bats@oroshi"
  git -C "$BATS_TMP_DIR/local" config user.name "Bats"

  # Local commit: puts main 1 ahead of origin
  git -C "$BATS_TMP_DIR/local" commit --allow-empty --quiet --message="local work"

  # Remote commit + fetch: puts main 1 behind origin as well → [ahead 1, behind 1]
  git -C "$BATS_TMP_DIR/remote" commit --allow-empty --quiet --message="remote work"
  git -C "$BATS_TMP_DIR/local" fetch --quiet origin

  export BATS_GIT_DIR="$BATS_TMP_DIR/local"
  cd "$BATS_GIT_DIR"
}

teardown() {
  bats_cleanup
}

@test "outputs one line per branch" {
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 1 ]
}

@test "branch line: name▮hash▮remote▮branch▮ahead▮behind▮date▮message▮" {
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "main▮"?*"▮origin▮main▮1▮1▮"?*"▮local work▮" ]]
}
