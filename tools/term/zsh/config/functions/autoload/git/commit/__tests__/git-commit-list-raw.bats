bats_load_library 'helper'

setup() {
  bats_git_dir 'repo'
}

@test "outputs shortHash▮relativeDate▮authorName▮subject for each commit" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-commit-list-raw"
  [[ "$status" -eq 0 ]]

  # bats_git_dir creates a repo with one initial commit
  local lastLine="${lines[-1]}"

  # Should have 4 fields separated by ▮
  IFS='▮' read -ra fields <<< "$lastLine"
  [[ "${#fields[@]}" -eq 4 ]]

  # Field 1: short commit hash (7-12 hex chars)
  [[ "${fields[0]}" =~ ^[0-9a-f]{7,12}$ ]]
  # Field 3: author name
  [[ "${fields[2]}" != "" ]]
  # Field 4: subject
  [[ "${fields[3]}" != "" ]]
}

@test "lists commits in reverse chronological order" {
  echo "second" > "$BATS_GIT_DIR/b.txt"
  bats_git add b.txt
  bats_git commit --quiet -m "second commit"

  bats_run_zsh "cd $BATS_GIT_DIR && git-commit-list-raw"
  [[ "$status" -eq 0 ]]
  # Most recent first
  [[ "${lines[0]}" == *"second commit"* ]]
}

@test "returns empty output for a repo with no commits" {
  bats_tmp_dir
  git -C "$BATS_TMP_DIR" init --quiet

  bats_run_zsh "cd $BATS_TMP_DIR && git-commit-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
