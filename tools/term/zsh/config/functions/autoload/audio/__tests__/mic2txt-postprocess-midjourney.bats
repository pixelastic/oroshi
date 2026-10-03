bats_load_library 'helper'

setup() {
  bats_tmp_dir
  midjourney-prompt() {
    cat > "$BATS_TMP_DIR/stdin.txt"
    echo "a red cat --v 8.2"
  }
  bats_mock midjourney-prompt
}

@test "passes stdin to midjourney-prompt and prints its output" {
  bats_run_zsh "echo 'un chat roux' | mic2txt-postprocess-midjourney"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "a red cat --v 8.2" ]]
  [[ "$(cat "$BATS_TMP_DIR/stdin.txt")" == "un chat roux" ]]
}

@test "returns non-zero when midjourney-prompt fails" {
  midjourney-prompt() { return 1; }
  bats_mock midjourney-prompt

  bats_run_zsh "echo 'un chat roux' | mic2txt-postprocess-midjourney"
  [[ "$status" -ne 0 ]]
}
