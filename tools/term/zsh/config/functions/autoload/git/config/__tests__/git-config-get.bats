bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "returns config value" {
  git() { echo "origin"; }
  bats_mock git

  bats_run_zsh "git-config-get branch.main.remote"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "origin" ]]
}

@test "returns 1 when config key not found" {
  git() { return 1; }
  bats_mock git

  bats_run_zsh "git-config-get nonexistent.key"
  [[ "$status" -ne 0 ]]
}

@test "reads from specific file with --file" {
  git() {
    echo "$@" > "$BATS_TMP_DIR/git-args.txt"
    echo "develop"
  }
  bats_mock git

  bats_run_zsh "git-config-get --file .gitmodules submodule.private.branch"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "develop" ]]

  local args="$(cat "$BATS_TMP_DIR/git-args.txt")"
  [[ "$args" == *"--file .gitmodules"* ]]
}

@test "targets a specific repo with --repo" {
  git() {
    echo "$@" > "$BATS_TMP_DIR/git-args.txt"
    echo "value"
  }
  bats_mock git

  bats_run_zsh "git-config-get --repo /other/repo some.key"
  [[ "$status" -eq 0 ]]

  local args="$(cat "$BATS_TMP_DIR/git-args.txt")"
  [[ "$args" == *"-C /other/repo"* ]]
}

@test "combines --repo and --file" {
  git() {
    echo "$@" > "$BATS_TMP_DIR/git-args.txt"
    echo "release"
  }
  bats_mock git

  bats_run_zsh "git-config-get --repo /my/repo --file .gitmodules submodule.lib.branch"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "release" ]]

  local args="$(cat "$BATS_TMP_DIR/git-args.txt")"
  [[ "$args" == *"-C /my/repo"* ]]
  [[ "$args" == *"--file .gitmodules"* ]]
}
