bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "outputs the Markdown returned by notion for a valid page ID" {
  notion() { echo "# My Note"; }
  bats_mock notion

  bats_run_zsh "phone-pickup-read abc-123"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "# My Note" ]]
}

@test "exits non-zero when called without arguments" {
  bats_run_zsh "phone-pickup-read"
  [[ "$status" -ne 0 ]]
}
