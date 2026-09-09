bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# --- Fallback chain ---

@test "returns registered project name when project-name succeeds" {
  project-name() { echo "my-project"; }
  bats_mock project-name

  bats_run_zsh "git-directory-name /some/path"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "my-project" ]]
}

@test "returns GitHub remote name when project-name fails but git-github-project-name succeeds" {
  project-name() { return 1; }
  git-github-project-name() { echo "github-repo"; }
  bats_mock project-name git-github-project-name

  bats_run_zsh "git-directory-name /some/path"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "github-repo" ]]
}

@test "returns directory basename when both project-name and git-github-project-name fail" {
  project-name() { return 1; }
  git-github-project-name() { return 1; }
  git-directory-root() { echo "/home/user/repos/my-repo"; }
  bats_mock project-name git-github-project-name git-directory-root

  bats_run_zsh "git-directory-name /some/path"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "my-repo" ]]
}

@test "strips all leading dots from basename fallback" {
  project-name() { return 1; }
  git-github-project-name() { return 1; }
  git-directory-root() { echo "/home/user/repos/.oroshi"; }
  bats_mock project-name git-github-project-name git-directory-root

  bats_run_zsh "git-directory-name /some/path"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "oroshi" ]]
}

@test "strips multiple leading dots from basename fallback" {
  project-name() { return 1; }
  git-github-project-name() { return 1; }
  git-directory-root() { echo "/home/user/repos/..foo"; }
  bats_mock project-name git-github-project-name git-directory-root

  bats_run_zsh "git-directory-name /some/path"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "foo" ]]
}

@test "does not strip dots from project-name result" {
  project-name() { echo ".dotted-project"; }
  bats_mock project-name

  bats_run_zsh "git-directory-name /some/path"
  [[ "$status" -eq 0 ]]
  [[ "$output" = ".dotted-project" ]]
}

@test "does not strip dots from git-github-project-name result" {
  project-name() { return 1; }
  git-github-project-name() { echo ".dotted-github"; }
  bats_mock project-name git-github-project-name

  bats_run_zsh "git-directory-name /some/path"
  [[ "$status" -eq 0 ]]
  [[ "$output" = ".dotted-github" ]]
}

# --- Interface ---

@test "defaults to PWD when no argument given" {
  project-name() {
    echo "$1" > "$BATS_TMP_DIR/received-path.txt"
    echo "from-pwd"
  }
  bats_mock project-name

  bats_run_zsh "cd /tmp && git-directory-name"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/received-path.txt")" = "/tmp" ]]
}

@test "accepts a path as positional argument" {
  project-name() {
    echo "$1" > "$BATS_TMP_DIR/received-path.txt"
    echo "from-arg"
  }
  bats_mock project-name

  bats_run_zsh "git-directory-name /custom/path"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/received-path.txt")" = "/custom/path" ]]
}
