bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
}

@test "accepts a path and runs submodule update in that directory" {
  git() { echo "$@" > "$BATS_TMP_DIR/git-args.txt"; }
  bats_mock git

  bats_run_zsh "git-submodule-update-all $BATS_GIT_DIR"
  [[ "$status" -eq 0 ]]

  local args="$(cat "$BATS_TMP_DIR/git-args.txt")"
  [[ "$args" == *"-C"* ]]
  [[ "$args" == *"$BATS_GIT_DIR"* ]]
  [[ "$args" == *"submodule"* ]]
  [[ "$args" == *"update"* ]]
}

@test "defaults to current directory when no argument given" {
  git() { echo "$@" > "$BATS_TMP_DIR/git-args.txt"; }
  bats_mock git

  bats_run_zsh "cd $BATS_GIT_DIR && git-submodule-update-all"
  [[ "$status" -eq 0 ]]

  local args="$(cat "$BATS_TMP_DIR/git-args.txt")"
  [[ "$args" == "-C . submodule update" ]]
}
