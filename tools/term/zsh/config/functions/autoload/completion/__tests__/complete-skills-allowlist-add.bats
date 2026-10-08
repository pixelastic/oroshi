bats_load_library 'helper'

# Point HOME at a sandbox so the helper reads a throw-away allowlist
setup() {
  bats_tmp_dir
  ALLOWLIST_DIR="$BATS_TMP_DIR/.oroshi/tools/ai/claude/config/hooks"
  ALLOWLIST_FILE="$ALLOWLIST_DIR/allow-list.json"
  mkdir -p "$ALLOWLIST_DIR"
  echo '[]' >"$ALLOWLIST_FILE"

  ctrl-b() {
    printf 'apt\ncurl\ngit\njq\n'
  }
  bats_mock ctrl-b
}

@test "prints every candidate when the allowlist is empty" {
  bats_run_zsh "HOME='$BATS_TMP_DIR' complete-skills-allowlist-add"
  [[ "$status" -eq 0 ]]
  [[ "$output" == $'apt\ncurl\ngit\njq' ]]
}

@test "omits candidates already in the allowlist" {
  echo '["curl","jq"]' >"$ALLOWLIST_FILE"

  bats_run_zsh "HOME='$BATS_TMP_DIR' complete-skills-allowlist-add"
  [[ "$status" -eq 0 ]]
  [[ "$output" == $'apt\ngit' ]]
}

@test "keeps apt when only apt list is in the allowlist" {
  echo '["apt list"]' >"$ALLOWLIST_FILE"

  bats_run_zsh "HOME='$BATS_TMP_DIR' complete-skills-allowlist-add"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "apt" ]]
}

@test "prints one candidate per line" {
  bats_run_zsh "HOME='$BATS_TMP_DIR' complete-skills-allowlist-add"
  [[ "${#lines[@]}" -eq 4 ]]
}

@test "prints nothing when every candidate is allowlisted" {
  echo '["apt","curl","git","jq"]' >"$ALLOWLIST_FILE"

  bats_run_zsh "HOME='$BATS_TMP_DIR' complete-skills-allowlist-add"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
