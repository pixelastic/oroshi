bats_load_library 'helper'

setup() {
  bats_tmp_dir

  mkdir -p "${BATS_TMP_DIR}/theming/env"
  printf '%s\n' \
    'COLOR_RED=1; COLOR_YELLOW=3; COLOR_GREEN=2; COLOR_GRAY=8' \
    'COLOR_AMBER_9=214; COLOR_ALIAS_GIT_BRANCH=17; COLOR_ALIAS_PUNCTUATION=8' \
    >"${BATS_TMP_DIR}/theming/env/colors.zsh"

  export ZSH_CONFIG_PATH="${BATS_TMP_DIR}"

  context-badge() { echo "BADGE"; }
  bats_mock context-badge
}

teardown() {
  bats_cleanup
}

statusline_json() {
  local dir="${1:-/some/dir}"
  local tokens="${2:-0}"
  local cost="${3:-0}"
  local session="${4:-test-session}"
  cat <<EOF
{
  "workspace": { "current_dir": "$dir" },
  "model": { "display_name": "test" },
  "cost": { "total_cost_usd": $cost },
  "context_window": {
    "current_usage": {
      "input_tokens": $tokens,
      "output_tokens": 0,
      "cache_creation_input_tokens": 0,
      "cache_read_input_tokens": 0
    },
    "used_percentage": 0
  },
  "session_id": "$session"
}
EOF
}

statusline_run() {
  statusline_json "$@" >"${BATS_TMP_DIR}/input.json"
  bats_run_script "${OROSHI_ROOT}/tools/ai/claude/config/statusline" <"${BATS_TMP_DIR}/input.json"
}

@test "renders badge, tokens, cost, and session" {
  statusline_run "/some/dir" 51000 0.05 "abc-123"
  [ "$status" -eq 0 ]
  local clean
  clean="$(bats_strip_ansi "$output")"
  [[ "$clean" == "BADGE 51k 5¢ [abc-123]" ]]
}

@test "formats token count with k suffix" {
  statusline_run "/some/dir" 1000 0 "x"
  [[ "$(bats_strip_ansi "$output")" == *"1k"* ]]

  statusline_run "/some/dir" 1500 0 "x"
  [[ "$(bats_strip_ansi "$output")" == *"1.5k"* ]]

  statusline_run "/some/dir" 51000 0 "x"
  [[ "$(bats_strip_ansi "$output")" == *"51k"* ]]
}

@test "formats cost in cents or dollars" {
  statusline_run "/some/dir" 0 0.05 "x"
  [[ "$(bats_strip_ansi "$output")" == *"5¢"* ]]

  statusline_run "/some/dir" 0 1.50 "x"
  [[ "$(bats_strip_ansi "$output")" == *'$1.50'* ]]
}
