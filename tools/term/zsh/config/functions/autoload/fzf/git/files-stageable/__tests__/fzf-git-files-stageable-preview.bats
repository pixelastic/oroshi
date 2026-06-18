bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="fzf-git-files-stageable-preview"

  git-directory-root() { echo "$BATS_TMP_DIR"; }
  # Simulates diff output for a deleted file (non-empty so we hit the diff branch)
  git() { printf -- '-deleted line\n'; }
  img-display() { true; }
  fzf-fs-shared-preview-header() { echo "HEADER_CALLED"; }
  bats_mock git-directory-root git img-display fzf-fs-shared-preview-header
}

@test "no error when previewing a deleted file" {
  bats_run_zsh "$CURRENT deleted.zsh"
  bats_debug "$output"
  [ "$status" -eq 0 ]
  [[ "$output" != *"HEADER_CALLED"* ]]
  [[ "$output" == *"deleted line"* ]]
}

@test "shows header for existing file" {
  echo "content" > "$BATS_TMP_DIR/existing.zsh"
  bats_run_zsh "$CURRENT existing.zsh"
  [[ "$output" == *"HEADER_CALLED"* ]]
}
