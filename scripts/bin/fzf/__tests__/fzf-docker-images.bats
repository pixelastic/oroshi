bats_load_library 'helper'

setup() {
  bats_tmp_dir

  mkdir -p "$BATS_TMP_DIR/tools/docker/docker/config/data/src"
  printf 'ubuntu▮Ubuntu is a Debian-based Linux OS.\n' >  "$BATS_TMP_DIR/tools/docker/docker/config/data/src/images-remote.txt"
  printf 'alpine▮A minimal Docker image based on Alpine Linux.\n' >> "$BATS_TMP_DIR/tools/docker/docker/config/data/src/images-remote.txt"
  bats_mock_env "OROSHI_ROOT" "$BATS_TMP_DIR"
}

teardown() {
  bats_cleanup
}

# fzf-source

@test "fzf-source: outputs candidates from cache file" {
  bats_run_zsh "fzf-docker-images --source"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "ubuntu▮"* ]]
  [[ "${lines[1]}" == "alpine▮"* ]]
}

@test "fzf-source: handles empty cache file gracefully" {
  printf '' > "$BATS_TMP_DIR/tools/docker/docker/config/data/src/images-remote.txt"
  bats_run_zsh "fzf-docker-images --source"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

# fzf-postprocess

@test "fzf-postprocess: extracts image name from selection" {
  bats_run_zsh "printf 'ubuntu▮Ubuntu is a Debian-based Linux OS.\n' | fzf-docker-images --postprocess"
  [ "$output" = "ubuntu" ]
}

@test "fzf-postprocess: outputs nothing on empty stdin" {
  bats_run_zsh "printf '' | fzf-docker-images --postprocess"
  [ "$output" = "" ]
}

# fzf-preview

@test "preview: exits gracefully without fzf-preview defined" {
  bats_run_zsh "fzf-docker-images --preview"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
