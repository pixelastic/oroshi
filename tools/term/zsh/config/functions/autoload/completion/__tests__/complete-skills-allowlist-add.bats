bats_load_library 'helper'

# Point OROSHI_ROOT at a sandbox so the helper reads a throw-away allowlist
# HOME holds a decoy allowlist that hides every candidate, so a read from the wrong root shows up
setup() {
  bats_tmp_dir
  ALLOWLIST_DIR="$BATS_TMP_DIR/tools/ai/claude/config/hooks"
  ALLOWLIST_FILE="$ALLOWLIST_DIR/allow-list.json"
  mkdir -p "$ALLOWLIST_DIR"
  echo '[]' >"$ALLOWLIST_FILE"

  DECOY_HOME="$BATS_TMP_DIR/home"
  DECOY_FILE="$DECOY_HOME/.oroshi/tools/ai/claude/config/hooks/allow-list.json"
  mkdir -p "$(dirname "$DECOY_FILE")"
  echo '["apt","curl","git","jq"]' >"$DECOY_FILE"

  ctrl-b() {
    printf 'apt\ncurl\ngit\njq\n'
  }
  bats_mock ctrl-b
}

@test "ignores the allowlist under HOME" {
  bats_run_zsh "HOME='$DECOY_HOME' OROSHI_ROOT='$BATS_TMP_DIR' complete-skills-allowlist-add"
  [[ "$status" -eq 0 ]]
  [[ "$output" == $'apt\ncurl\ngit\njq' ]]
}

@test "prints every candidate when the allowlist is empty" {
  bats_run_zsh "HOME='$DECOY_HOME' OROSHI_ROOT='$BATS_TMP_DIR' complete-skills-allowlist-add"
  [[ "$status" -eq 0 ]]
  [[ "$output" == $'apt\ncurl\ngit\njq' ]]
}

@test "prints every candidate when the allowlist is missing" {
  rm "$ALLOWLIST_FILE"

  bats_run_zsh "HOME='$DECOY_HOME' OROSHI_ROOT='$BATS_TMP_DIR' complete-skills-allowlist-add"
  [[ "$status" -eq 0 ]]
  [[ "$output" == $'apt\ncurl\ngit\njq' ]]
}

@test "omits candidates already in the allowlist" {
  echo '["curl","jq"]' >"$ALLOWLIST_FILE"

  bats_run_zsh "HOME='$DECOY_HOME' OROSHI_ROOT='$BATS_TMP_DIR' complete-skills-allowlist-add"
  [[ "$status" -eq 0 ]]
  [[ "$output" == $'apt\ngit' ]]
}

@test "keeps apt when only apt list is in the allowlist" {
  echo '["apt list"]' >"$ALLOWLIST_FILE"

  bats_run_zsh "HOME='$DECOY_HOME' OROSHI_ROOT='$BATS_TMP_DIR' complete-skills-allowlist-add"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "apt" ]]
}

@test "prints one candidate per line" {
  bats_run_zsh "HOME='$DECOY_HOME' OROSHI_ROOT='$BATS_TMP_DIR' complete-skills-allowlist-add"
  [[ "${#lines[@]}" -eq 4 ]]
}

@test "prints nothing when every candidate is allowlisted" {
  echo '["apt","curl","git","jq"]' >"$ALLOWLIST_FILE"

  bats_run_zsh "HOME='$DECOY_HOME' OROSHI_ROOT='$BATS_TMP_DIR' complete-skills-allowlist-add"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
