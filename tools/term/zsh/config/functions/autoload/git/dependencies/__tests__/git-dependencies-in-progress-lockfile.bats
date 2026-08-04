bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env OROSHI_TMP_FOLDER "$BATS_TMP_DIR"
}

@test "fails when language argument is missing" {
  bats_run_zsh "git-dependencies-in-progress-lockfile"
  [[ "$status" -ne 0 ]]
}

@test "returns path under OROSHI_TMP_FOLDER/git-dependencies-update/" {
  context-slug() { echo "my-repo"; }
  bats_mock context-slug

  bats_run_zsh "git-dependencies-in-progress-lockfile node"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$BATS_TMP_DIR/git-dependencies-update/"* ]]
}

@test "filename ends with --node.lock for language node" {
  context-slug() { echo "my-repo"; }
  bats_mock context-slug

  bats_run_zsh "git-dependencies-in-progress-lockfile node"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--node.lock" ]]
}

@test "filename ends with --ruby.lock for language ruby" {
  context-slug() { echo "my-repo"; }
  bats_mock context-slug

  bats_run_zsh "git-dependencies-in-progress-lockfile ruby"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--ruby.lock" ]]
}

@test "uses target repo context slug with --repo" {
  context-slug() { echo "other-repo--feature"; }
  bats_mock context-slug

  bats_run_zsh "git-dependencies-in-progress-lockfile node --repo /some/path"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"/other-repo--feature--node.lock" ]]
}

@test "writes to REPLY with --reply" {
  context-slug() { echo "my-repo"; }
  bats_mock context-slug

  bats_run_zsh "git-dependencies-in-progress-lockfile node --reply; echo \$REPLY"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"my-repo--node.lock" ]]
}

@test "no stdout when --reply is set" {
  context-slug() { echo "my-repo"; }
  bats_mock context-slug

  bats_run_zsh 'git-dependencies-in-progress-lockfile node --reply; echo "---"; echo $REPLY'
  local lines=("${lines[@]}")
  # First line should be the separator, not the lockfile path (no stdout before it)
  [[ "${lines[0]}" == "---" ]]
}

@test "creates parent directory if missing" {
  context-slug() { echo "my-repo"; }
  bats_mock context-slug

  bats_run_zsh "git-dependencies-in-progress-lockfile node"
  [[ "$status" -eq 0 ]]
  [[ -d "$BATS_TMP_DIR/git-dependencies-update" ]]
}
