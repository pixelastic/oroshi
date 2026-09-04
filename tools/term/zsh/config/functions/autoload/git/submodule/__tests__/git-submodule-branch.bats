bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "returns the branch configured in .gitmodules" {
  git-config-get() { echo "develop"; }
  bats_mock git-config-get

  bats_run_zsh "git-submodule-branch private"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "develop" ]]
}

@test "falls back to main when no branch configured" {
  git-config-get() { return 1; }
  bats_mock git-config-get

  bats_run_zsh "git-submodule-branch private"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "main" ]]
}

@test "passes --repo to git-config-get" {
  git-config-get() {
    echo "$@" > "$BATS_TMP_DIR/config-args.txt"
    echo "release"
  }
  bats_mock git-config-get

  bats_run_zsh "git-submodule-branch --repo /other/repo private"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "release" ]]

  local args="$(cat "$BATS_TMP_DIR/config-args.txt")"
  [[ "$args" == *"--file .gitmodules"* ]]
  [[ "$args" == *"--repo /other/repo"* ]]
}
