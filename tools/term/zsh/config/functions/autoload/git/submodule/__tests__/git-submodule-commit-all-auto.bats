bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Default mocks: no dirty files, no submodules
  git-file-list-dirty-raw() { return 0; }
  git-submodule-list-raw() { return 0; }
  git-directory-dirty-count() { echo 0; }
  git-commit-create-all-auto() { echo "$@" >> "$BATS_TMP_DIR/commit-auto-calls.txt"; }
  git-commit-submodule() { echo "$@" >> "$BATS_TMP_DIR/commit-sub-calls.txt"; }
  bats_mock git-file-list-dirty-raw git-submodule-list-raw git-directory-dirty-count git-commit-create-all-auto git-commit-submodule
}

@test "no dirty submodules: returns 0, no commits" {
  bats_run_zsh "git-submodule-commit-all-auto"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/commit-auto-calls.txt" ]]
  [[ ! -f "$BATS_TMP_DIR/commit-sub-calls.txt" ]]
}

@test "one dirty submodule: commits inside it and commits pointer" {
  git-file-list-dirty-raw() { echo "private▮M"; }
  git-submodule-list-raw() { echo "private▮abc12345▮main"; }
  git-directory-dirty-count() { echo 3; }
  git-commit-create-all-auto() { echo "$@" >> "$BATS_TMP_DIR/commit-auto-calls.txt"; }
  git-commit-submodule() { echo "$@" >> "$BATS_TMP_DIR/commit-sub-calls.txt"; }
  bats_mock git-file-list-dirty-raw git-submodule-list-raw git-directory-dirty-count git-commit-create-all-auto git-commit-submodule

  bats_run_zsh "git-submodule-commit-all-auto"
  [[ "$status" -eq 0 ]]

  local autoCalls="$(cat "$BATS_TMP_DIR/commit-auto-calls.txt")"
  [[ "$autoCalls" == *"private"* ]]

  local subCalls="$(cat "$BATS_TMP_DIR/commit-sub-calls.txt")"
  [[ "$subCalls" == *"private"* ]]
}

@test "multiple dirty submodules: commits in each and commits pointers" {
  git-file-list-dirty-raw() {
    printf 'private▮M\nscripts/bin/img▮M\n'
  }
  git-submodule-list-raw() {
    printf 'private▮abc12345▮main\nscripts/bin/img▮def67890▮main\n'
  }
  git-directory-dirty-count() { echo 2; }
  git-commit-create-all-auto() { echo "$@" >> "$BATS_TMP_DIR/commit-auto-calls.txt"; }
  git-commit-submodule() { echo "$@" >> "$BATS_TMP_DIR/commit-sub-calls.txt"; }
  bats_mock git-file-list-dirty-raw git-submodule-list-raw git-directory-dirty-count git-commit-create-all-auto git-commit-submodule

  bats_run_zsh "git-submodule-commit-all-auto"
  [[ "$status" -eq 0 ]]

  local autoCalls="$(cat "$BATS_TMP_DIR/commit-auto-calls.txt")"
  [[ "$autoCalls" == *"private"* ]]
  [[ "$autoCalls" == *"scripts/bin/img"* ]]

  local subCalls="$(cat "$BATS_TMP_DIR/commit-sub-calls.txt")"
  [[ "$subCalls" == *"private"* ]]
  [[ "$subCalls" == *"scripts/bin/img"* ]]
}

@test "submodule with changed pointer but no dirty files: skipped" {
  # Submodule appears in dirty list (pointer changed) but has 0 dirty files inside
  git-file-list-dirty-raw() { echo "private▮M"; }
  git-submodule-list-raw() { echo "private▮abc12345▮main"; }
  git-directory-dirty-count() { echo 0; }
  bats_mock git-file-list-dirty-raw git-submodule-list-raw git-directory-dirty-count

  bats_run_zsh "git-submodule-commit-all-auto"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/commit-auto-calls.txt" ]]
  [[ ! -f "$BATS_TMP_DIR/commit-sub-calls.txt" ]]
}

@test "parent has dirty non-submodule files: left untouched" {
  git-file-list-dirty-raw() {
    printf 'private▮M\nREADME.md▮M\nsrc/index.ts▮A\n'
  }
  git-submodule-list-raw() { echo "private▮abc12345▮main"; }
  git-directory-dirty-count() { echo 1; }
  git-commit-create-all-auto() { echo "$@" >> "$BATS_TMP_DIR/commit-auto-calls.txt"; }
  git-commit-submodule() { echo "$@" >> "$BATS_TMP_DIR/commit-sub-calls.txt"; }
  bats_mock git-file-list-dirty-raw git-submodule-list-raw git-directory-dirty-count git-commit-create-all-auto git-commit-submodule

  bats_run_zsh "git-submodule-commit-all-auto"
  [[ "$status" -eq 0 ]]

  # Only private was committed, not README.md or src/index.ts
  local autoCalls="$(cat "$BATS_TMP_DIR/commit-auto-calls.txt")"
  [[ "$(wc -l < "$BATS_TMP_DIR/commit-auto-calls.txt")" -eq 1 ]]
  [[ "$autoCalls" == *"private"* ]]
}

@test "supports --repo flag" {
  local repoDir="$BATS_TMP_DIR/my-repo"
  mkdir -p "$repoDir"

  git-file-list-dirty-raw() { echo "private▮M"; }
  git-submodule-list-raw() { echo "private▮abc12345▮main"; }
  git-directory-dirty-count() { echo 1; }
  git-commit-create-all-auto() { echo "$@" >> "$BATS_TMP_DIR/commit-auto-calls.txt"; }
  git-commit-submodule() { echo "$@" >> "$BATS_TMP_DIR/commit-sub-calls.txt"; }
  bats_mock git-file-list-dirty-raw git-submodule-list-raw git-directory-dirty-count git-commit-create-all-auto git-commit-submodule
  bats_disable_worktree_aware

  bats_run_zsh "git-submodule-commit-all-auto --repo $repoDir"
  [[ "$status" -eq 0 ]]

  # Both calls receive the full path
  local autoCalls="$(cat "$BATS_TMP_DIR/commit-auto-calls.txt")"
  [[ "$autoCalls" == *"$repoDir/private"* ]]

  local subCalls="$(cat "$BATS_TMP_DIR/commit-sub-calls.txt")"
  [[ "$subCalls" == *"$repoDir/private"* ]]
}
