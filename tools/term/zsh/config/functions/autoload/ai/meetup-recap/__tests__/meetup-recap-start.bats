bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "creates meetup-recap subdirectory" {
  bats_run_zsh "meetup-recap-start"
  [[ "$status" -eq 0 ]]
  [[ -d "/tmp/oroshi/claude/meetup-recap" ]]
}

@test "outputs valid JSON with draftPath key" {
  bats_run_zsh "meetup-recap-start"
  [[ "$status" -eq 0 ]]
  local draftPath="$(echo "$output" | jq --raw-output '.draftPath')"
  [[ "$draftPath" != "null" ]]
  [[ "$draftPath" == "/tmp/oroshi/claude/meetup-recap/"*.md ]]
}

@test "returns unique draftPaths on successive calls" {
  bats_run_zsh "meetup-recap-start"
  local first="$(echo "$output" | jq --raw-output '.draftPath')"

  bats_run_zsh "meetup-recap-start"
  local second="$(echo "$output" | jq --raw-output '.draftPath')"

  [[ "$first" != "$second" ]]
}
