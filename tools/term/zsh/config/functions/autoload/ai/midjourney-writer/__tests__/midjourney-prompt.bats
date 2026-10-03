bats_load_library 'helper'

# Mocks claude-api and midjourney-fix, which are the collaborators of
# midjourney-prompt. claude-api logs one argument per line to
# $BATS_TMP_DIR/claude-api.log and prints a canned text. midjourney-fix prefixes
# its stdin with "fixed: " (and prints nothing on empty input, like the real one).
setup() {
  bats_tmp_dir
  REFERENCES_DIR="$OROSHI_ROOT/tools/ai/claude/config/skills/midjourney-writer/references"

  claude-api() {
    printf '%s\n' "$@" >"$BATS_TMP_DIR/claude-api.log"
    echo "a red cat on a roof"
  }
  midjourney-fix() {
    local prompt="$(cat)"
    [[ "$prompt" == "" ]] && return 1
    echo "fixed: $prompt"
  }
  clipboard-write() { echo "$@" >"$BATS_TMP_DIR/clipboard.log"; }
  bats_mock claude-api midjourney-fix clipboard-write
}

@test "prints the fixed prompt returned by claude-api" {
  bats_run_zsh "midjourney-prompt 'un chat roux'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "fixed: a red cat on a roof" ]]
}

@test "reads the description from stdin" {
  bats_run_zsh "midjourney-prompt" <<<'un chat roux sur un toit'
  [[ "$status" -eq 0 ]]
  grep --quiet --fixed-strings --line-regexp 'un chat roux sur un toit' "$BATS_TMP_DIR/claude-api.log"
}

@test "reads the description from the first argument" {
  bats_run_zsh "midjourney-prompt 'un chat roux sur un toit'"
  [[ "$status" -eq 0 ]]
  grep --quiet --fixed-strings --line-regexp 'un chat roux sur un toit' "$BATS_TMP_DIR/claude-api.log"
}

@test "sends both skill references in the system prompt" {
  bats_run_zsh "midjourney-prompt 'un chat roux'"
  local log="$(cat "$BATS_TMP_DIR/claude-api.log")"
  [[ "$log" == *"$(cat "$REFERENCES_DIR/prompting.md")"* ]]
  [[ "$log" == *"$(cat "$REFERENCES_DIR/parameters.md")"* ]]
}

@test "asks for the prompt only, without explanation or code fence" {
  bats_run_zsh "midjourney-prompt 'un chat roux'"
  local log="$(cat "$BATS_TMP_DIR/claude-api.log")"
  [[ "$log" == *"Output only the prompt"* ]]
}

@test "always uses haiku" {
  bats_run_zsh "midjourney-prompt 'un chat roux'"
  [[ "$status" -eq 0 ]]
  [[ "$(grep --after-context=1 --line-regexp -- '--model' "$BATS_TMP_DIR/claude-api.log" | sed -n 2p)" == "haiku" ]]
}

@test "does not let --model change the model" {
  bats_run_zsh "midjourney-prompt --model opus 'un chat roux'"
  [[ "$status" -eq 0 ]]
  [[ "$(grep --after-context=1 --line-regexp -- '--model' "$BATS_TMP_DIR/claude-api.log" | sed -n 2p)" == "haiku" ]]
}

@test "returns 1 when claude-api fails" {
  claude-api() { return 1; }
  bats_mock claude-api

  bats_run_zsh "midjourney-prompt 'un chat roux'"
  [[ "$status" -eq 1 ]]
  [[ "$output" == "" ]]
}

@test "returns 1 when claude-api returns an empty text" {
  claude-api() { echo ""; }
  bats_mock claude-api

  bats_run_zsh "midjourney-prompt 'un chat roux'"
  [[ "$status" -eq 1 ]]
  [[ "$output" == "" ]]
}

@test "does not call clipboard-write" {
  bats_run_zsh "midjourney-prompt 'un chat roux'"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/clipboard.log" ]]
}
