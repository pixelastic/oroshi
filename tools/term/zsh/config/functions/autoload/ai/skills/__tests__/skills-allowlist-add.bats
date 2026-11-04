bats_load_library 'helper'

# Point OROSHI_ROOT at a sandbox so the function writes to a throw-away allowlist
# HOME holds a decoy allowlist, so a write to the wrong root shows up
setup() {
  bats_tmp_dir
  ALLOWLIST_DIR="$BATS_TMP_DIR/tools/ai/claude/config/hooks"
  ALLOWLIST_FILE="$ALLOWLIST_DIR/allow-list.json"
  mkdir -p "$ALLOWLIST_DIR"
  echo '["git status"]' >"$ALLOWLIST_FILE"

  DECOY_HOME="$BATS_TMP_DIR/home"
  DECOY_FILE="$DECOY_HOME/.oroshi/tools/ai/claude/config/hooks/allow-list.json"
  mkdir -p "$(dirname "$DECOY_FILE")"
  echo '["decoy"]' >"$DECOY_FILE"
}

@test "leaves the allowlist under HOME untouched" {
  bats_run_zsh "HOME='$DECOY_HOME' OROSHI_ROOT='$BATS_TMP_DIR' skills-allowlist-add tree"
  [[ "$(jq --compact-output . "$DECOY_FILE")" == '["decoy"]' ]]
}

@test "adds one command to the allowlist" {
  bats_run_zsh "OROSHI_ROOT='$BATS_TMP_DIR' skills-allowlist-add tree"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output . "$ALLOWLIST_FILE")" == '["git status","tree"]' ]]
}

@test "keeps the file sorted" {
  bats_run_zsh "OROSHI_ROOT='$BATS_TMP_DIR' skills-allowlist-add awk"
  [[ "$(jq --compact-output . "$ALLOWLIST_FILE")" == '["awk","git status"]' ]]
}

@test "adds every argument in one call" {
  bats_run_zsh "OROSHI_ROOT='$BATS_TMP_DIR' skills-allowlist-add c a b"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output . "$ALLOWLIST_FILE")" == '["a","b","c","git status"]' ]]
}

@test "ignores an argument already in the allowlist" {
  bats_run_zsh "OROSHI_ROOT='$BATS_TMP_DIR' skills-allowlist-add 'git status' a"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output . "$ALLOWLIST_FILE")" == '["a","git status"]' ]]
}

@test "ignores duplicate arguments within the same call" {
  bats_run_zsh "OROSHI_ROOT='$BATS_TMP_DIR' skills-allowlist-add a a b a"
  [[ "$(jq --compact-output . "$ALLOWLIST_FILE")" == '["a","b","git status"]' ]]
}

@test "adds a quoted multi-word argument as one entry" {
  bats_run_zsh "OROSHI_ROOT='$BATS_TMP_DIR' skills-allowlist-add 'apt list' tree"
  [[ "$(jq --compact-output . "$ALLOWLIST_FILE")" == '["apt list","git status","tree"]' ]]
}

@test "sorts the file once, after all additions" {
  json-array-sort() {
    echo x >>"$BATS_TMP_DIR/sort-calls"
    cat -- "$1"
  }
  bats_mock json-array-sort

  bats_run_zsh "OROSHI_ROOT='$BATS_TMP_DIR' skills-allowlist-add a b c"
  [[ "$(wc --lines <"$BATS_TMP_DIR/sort-calls")" -eq 1 ]]
  [[ "$(jq 'length' "$ALLOWLIST_FILE")" -eq 4 ]]
}

@test "fails with a usage message when no argument is given" {
  bats_run_zsh "OROSHI_ROOT='$BATS_TMP_DIR' skills-allowlist-add"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"Usage: skills-allowlist-add"* ]]
}

@test "leaves the file untouched when no argument is given" {
  bats_run_zsh "OROSHI_ROOT='$BATS_TMP_DIR' skills-allowlist-add"
  [[ "$(cat "$ALLOWLIST_FILE")" == '["git status"]' ]]
}
