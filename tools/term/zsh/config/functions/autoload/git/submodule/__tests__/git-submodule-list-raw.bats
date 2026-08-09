bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "outputs ▮-separated fields: name, hash, branch" {
  git() {
    [[ "$1" == "submodule" ]] && echo " abc1234567890 mymodule (main)"
  }
  git-directory-root() { echo "/repo"; }
  path-relative() { echo "${1##*/}"; }
  sort-filepaths() { printf '%s\n' "$@"; }
  bats_mock git git-directory-root path-relative sort-filepaths

  bats_run_zsh "git-submodule-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "mymodule▮abc12345▮main" ]]
}

@test "handles multiple submodules" {
  git() {
    [[ "$1" == "submodule" ]] && printf ' aaa1234567890 alpha (main)\n bbb9876543210 beta (develop)\n'
  }
  git-directory-root() { echo "/repo"; }
  path-relative() { echo "${1##*/}"; }
  sort-filepaths() { printf '%s\n' "$@"; }
  bats_mock git git-directory-root path-relative sort-filepaths

  bats_run_zsh "git-submodule-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"alpha▮aaa12345▮main"* ]]
  [[ "$output" == *"beta▮bbb98765▮develop"* ]]
}

@test "handles detached HEAD with no branch" {
  git() {
    [[ "$1" == "submodule" ]] && echo " abc1234567890 mymodule"
  }
  git-directory-root() { echo "/repo"; }
  path-relative() { echo "${1##*/}"; }
  sort-filepaths() { printf '%s\n' "$@"; }
  bats_mock git git-directory-root path-relative sort-filepaths

  bats_run_zsh "git-submodule-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "mymodule▮abc12345▮" ]]
}

@test "returns nothing when no submodules" {
  git() { return 0; }
  git-directory-root() { echo "/repo"; }
  bats_mock git git-directory-root

  bats_run_zsh "git-submodule-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
