bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../__lib/shellcheck-lint.zsh'"
}

# Print the given jq filter applied to the command output
jq_output() {
  printf '%s' "$output" | jq --raw-output "$1"
}

# --- Unified format ---

@test "converts the code of a finding to a string such as SC2016" {
  local file="$BATS_TMP_DIR/test.sh"
  printf "x='\$y'\n" >"$file"
  bats_run_zsh "${sourcePrefix}; shellcheck-lint --json $file"
  [[ "$(jq_output '[.[].code] | contains(["SC2016"])')" == 'true' ]]
  [[ "$(jq_output '[.[].code | type] | unique | join(",")')" == 'string' ]]
}

@test "maps shellcheck level warning to warn" {
  local file="$BATS_TMP_DIR/test.sh"
  printf 'ls $(echo a)\n' >"$file"
  bats_run_zsh "${sourcePrefix}; shellcheck-lint --json $file"
  [[ "$(jq_output '.[] | select(.code == "SC2046") | .level')" == 'warn' ]]
}

@test "maps shellcheck level style to hint" {
  local file="$BATS_TMP_DIR/test.sh"
  printf 'x=`date`\n' >"$file"
  bats_run_zsh "${sourcePrefix}; shellcheck-lint --json $file"
  [[ "$(jq_output '.[] | select(.code == "SC2006") | .level')" == 'hint' ]]
}

@test "keeps level error and info unchanged" {
  local file="$BATS_TMP_DIR/test.sh"
  printf "local x=1\nx='\$y'\n" >"$file"
  bats_run_zsh "${sourcePrefix}; shellcheck-lint --json $file"
  [[ "$(jq_output '.[] | select(.code == "SC2168") | .level')" == 'error' ]]
  [[ "$(jq_output '.[] | select(.code == "SC2016") | .level')" == 'info' ]]
}

@test "drops the fix field" {
  local file="$BATS_TMP_DIR/test.sh"
  printf 'x=`date`\n' >"$file"
  bats_run_zsh "${sourcePrefix}; shellcheck-lint --json $file"
  [[ "$(jq_output '[.[] | has("fix")] | any')" == 'false' ]]
}

# --- Inputs and exclusions ---

@test "reports every rule when no exclusion is given" {
  local file="$BATS_TMP_DIR/test.sh"
  printf "x='\$y'\n" >"$file"
  bats_run_zsh "${sourcePrefix}; shellcheck-lint --json $file"
  [[ "$(jq_output '[.[].code] | sort | join(",")')" == 'SC2016,SC2034' ]]
}

@test "does not report a rule listed in --exclude" {
  local file="$BATS_TMP_DIR/test.sh"
  printf "x='\$y'\n" >"$file"
  bats_run_zsh "${sourcePrefix}; shellcheck-lint --json --exclude SC2034 $file"
  [[ "$(jq_output '[.[].code] | join(",")')" == 'SC2016' ]]
}

@test "skips directories and prints [] when no file remains" {
  bats_run_zsh "${sourcePrefix}; shellcheck-lint --json $BATS_TMP_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "prints [] and returns 0 for a clean file" {
  local file="$BATS_TMP_DIR/test.sh"
  printf '# clean\n' >"$file"
  bats_run_zsh "${sourcePrefix}; shellcheck-lint --json $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

# --- Exit codes ---

@test "returns 1 when violations exist" {
  local file="$BATS_TMP_DIR/test.sh"
  printf "x='\$y'\n" >"$file"
  bats_run_zsh "${sourcePrefix}; shellcheck-lint --json $file"
  [[ "$status" -eq 1 ]]
}

@test "prints an error and returns 1 when shellcheck fails internally" {
  local file="$BATS_TMP_DIR/unreadable.sh"
  printf 'x=1\n' >"$file"
  chmod 000 "$file"
  bats_run_zsh "${sourcePrefix}; shellcheck-lint --json $file"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *'Error: shellcheck failed (exit 2)'* ]]
}
