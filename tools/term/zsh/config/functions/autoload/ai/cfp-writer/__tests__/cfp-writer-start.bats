bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "creates cfp-writer subdirectory" {
  bats_run_zsh "cfp-writer-start"
  [[ "$status" -eq 0 ]]
  [[ -d "/tmp/oroshi/claude/cfp-writer" ]]
}

@test "outputs valid JSON with draftPath key" {
  bats_run_zsh "cfp-writer-start"
  [[ "$status" -eq 0 ]]
  local draftPath="$(echo "$output" | jq --raw-output '.draftPath')"
  [[ "$draftPath" != "null" ]]
  [[ "$draftPath" == "/tmp/oroshi/claude/cfp-writer/"*.md ]]
}

@test "returns unique draftPaths on successive calls" {
  bats_run_zsh "cfp-writer-start"
  local first="$(echo "$output" | jq --raw-output '.draftPath')"

  bats_run_zsh "cfp-writer-start"
  local second="$(echo "$output" | jq --raw-output '.draftPath')"

  [[ "$first" != "$second" ]]
}
