bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$OROSHI_ZSH_AUTOLOAD/fzf/git/files-stageable/fzf-git-files-stageable-preview"

  git-directory-root() { echo "$BATS_TMP_DIR"; }
  # Simulates diff output for a deleted file (non-empty so we hit the diff branch)
  git() { printf -- '-deleted line\n'; }
  img-display() { true; }
  fzf-fs-shared-preview-header() { echo "HEADER_CALLED"; }
  bats_mock git-directory-root git img-display fzf-fs-shared-preview-header
}

teardown() {
  bats_cleanup
}

@test "no error when previewing a deleted file" {
  bats_run_zsh "$CURRENT" "deleted.zsh"
  [ "$status" -eq 0 ]
}

@test "skips header for deleted file" {
  bats_run_zsh "$CURRENT" "deleted.zsh"
  [[ "$output" != *"HEADER_CALLED"* ]]
}

@test "shows diff content for deleted file" {
  bats_run_zsh "$CURRENT" "deleted.zsh"
  [[ "$output" == *"deleted line"* ]]
}

@test "shows header for existing file" {
  echo "content" > "$BATS_TMP_DIR/existing.zsh"
  bats_run_zsh "$CURRENT" "existing.zsh"
  [[ "$output" == *"HEADER_CALLED"* ]]
}
