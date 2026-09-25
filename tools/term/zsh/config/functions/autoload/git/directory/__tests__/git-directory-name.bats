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
  git-worktree-main() { echo "/home/user/repos/my-repo"; }
  bats_mock project-name git-github-project-name git-worktree-main

  bats_run_zsh "git-directory-name /some/path"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "github-repo" ]]
}

@test "returns directory basename when both project-name and git-github-project-name fail" {
  project-name() { return 1; }
  git-github-project-name() { return 1; }
  git-worktree-main() { echo "/home/user/repos/my-repo"; }
  bats_mock project-name git-github-project-name git-worktree-main

  bats_run_zsh "git-directory-name /some/path"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "my-repo" ]]
}

@test "strips all leading dots from basename fallback" {
  project-name() { return 1; }
  git-github-project-name() { return 1; }
  git-worktree-main() { echo "/home/user/repos/.oroshi"; }
  bats_mock project-name git-github-project-name git-worktree-main

  bats_run_zsh "git-directory-name /some/path"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "oroshi" ]]
}

@test "strips multiple leading dots from basename fallback" {
  project-name() { return 1; }
  git-github-project-name() { return 1; }
  git-worktree-main() { echo "/home/user/repos/..foo"; }
  bats_mock project-name git-github-project-name git-worktree-main

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
  git-worktree-main() { echo "/home/user/repos/my-repo"; }
  bats_mock project-name git-github-project-name git-worktree-main

  bats_run_zsh "git-directory-name /some/path"
  [[ "$status" -eq 0 ]]
  [[ "$output" = ".dotted-github" ]]
}

# --- Container projects ---

@test "skips registered project that contains the repo" {
  project-name() { echo "home"; }
  project-path() { echo "/home/user"; }
  git-worktree-main() { echo "/home/user/repos/fzf"; }
  git-github-project-name() { echo "fzf"; }
  bats_mock project-name project-path git-worktree-main git-github-project-name

  bats_run_zsh "git-directory-name /home/user/repos/fzf"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "fzf" ]]
}

@test "skips catch-all project at filesystem root" {
  project-name() { echo "root"; }
  project-path() { echo "/"; }
  git-worktree-main() { echo "/tmp/my-repo"; }
  git-github-project-name() { return 1; }
  bats_mock project-name project-path git-worktree-main git-github-project-name

  bats_run_zsh "git-directory-name /tmp/my-repo"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "my-repo" ]]
}

@test "keeps registered project located at the repo root" {
  project-name() { echo "my-project"; }
  project-path() { echo "/home/user/repos/my-repo"; }
  git-worktree-main() { echo "/home/user/repos/my-repo"; }
  bats_mock project-name project-path git-worktree-main

  bats_run_zsh "git-directory-name /home/user/repos/my-repo"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "my-project" ]]
}

@test "skips registered project located inside the repo" {
  project-name() { echo "my-package"; }
  project-path() { echo "/home/user/repos/monorepo/packages/my-package"; }
  git-worktree-main() { echo "/home/user/repos/monorepo"; }
  git-github-project-name() { return 1; }
  bats_mock project-name project-path git-worktree-main git-github-project-name

  bats_run_zsh "git-directory-name /home/user/repos/monorepo/packages/my-package"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "monorepo" ]]
}

@test "keeps container project outside any git repo" {
  project-name() { echo "home"; }
  project-path() { echo "/home/user"; }
  git-worktree-main() { return 1; }
  bats_mock project-name project-path git-worktree-main

  bats_run_zsh "git-directory-name /home/user/documents"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "home" ]]
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
