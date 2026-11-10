bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '${OROSHI_ROOT}/tools/term/zsh/config/functions/autoload/git/github/__lib/target-resolve.zsh'"
}

# Print the target the resolver put in $reply: its kind, then its id
resolve_target() {
  bats_run_zsh "$sourcePrefix && git-github-target-resolve $* && print -r -- \"\${reply[1]} \${reply[2]}\""
}

@test "returns issue when only --issueId is given" {
  resolve_target --issueId 42
  [[ "$status" -eq 0 ]]
  [[ "$output" == "issue 42" ]]
}

@test "returns pullrequest when only --pullrequestId is given" {
  resolve_target --pullrequestId 108
  [[ "$status" -eq 0 ]]
  [[ "$output" == "pullrequest 108" ]]
}

@test "fails when both are given" {
  resolve_target --issueId 42 --pullrequestId 108
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"not both"* ]]
}

@test "fails when none is given" {
  resolve_target
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"--issueId or --pullrequestId"* ]]
}
